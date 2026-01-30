import ComposableArchitecture
import Foundation

@Reducer
struct StatsFeature {
    @ObservableState
    struct State: Equatable {
        enum TimeRange: String, CaseIterable, Equatable {
            case day = "D"
            case week = "W"
            case month = "M"
            case sixMonths = "6M"
            case year = "Y"
        }
        
        enum ChartType: String, CaseIterable, Equatable {
            case altitude = "ALTITUDE"
            case metabolic = "METABOLIC"
        }
        
        var selectedRange: TimeRange = .week
        var selectedChartType: ChartType = .altitude
        var sessions: [SessionRecord] = []
        var chartData: [ChartDataPoint] = []
        var isLoading: Bool = false
        
        var totalClimbInRange: Double {
            chartData.reduce(0) { $0 + $1.value }
        }
    }
    
    enum Action {
        case onAppear
        case timeRangeChanged(State.TimeRange)
        case chartTypeChanged(State.ChartType)
        case sessionsResponse([SessionRecord])
        case setError(String?)
    }
    
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    do {
                        let sessions = try await databaseClient.fetchSessions()
                        await send(.sessionsResponse(sessions))
                    } catch {
                        await send(.setError(error.localizedDescription))
                    }
                }
                
            case let .timeRangeChanged(range):
                state.selectedRange = range
                state.chartData = calculateChartData(sessions: state.sessions, range: range)
                return .none
                
            case let .chartTypeChanged(type):
                state.selectedChartType = type
                return .none
                
            case let .sessionsResponse(sessions):
                state.isLoading = false
                state.sessions = sessions
                state.chartData = calculateChartData(sessions: sessions, range: state.selectedRange)
                return .none
                
            case .setError:
                state.isLoading = false
                return .none
            }
        }
    }
    
    private func calculateChartData(sessions: [SessionRecord], range: State.TimeRange) -> [ChartDataPoint] {
        let now = Date()
        let calendar = Calendar.current
        
        switch range {
        case .day:
            // Group by hour for last 24h
            return (0..<24).map { hourOffset in
                let date = calendar.date(byAdding: .hour, value: -hourOffset, to: now)!
                let hourSessions = sessions.filter { calendar.isDate($0.startDate, equalTo: date, toGranularity: .hour) }
                let climb = hourSessions.reduce(0) { $0 + $1.totalClimb }
                let intensity = hourSessions.reduce(0) { $0 + $1.mitochondrialIndex }
                return ChartDataPoint(label: "\(calendar.component(.hour, from: date))h", value: climb, intensity: intensity, date: date)
            }.reversed()
            
        case .week:
            // Last 7 days
            return (0..<7).map { dayOffset in
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
                let daySessions = sessions.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
                let climb = daySessions.reduce(0) { $0 + $1.totalClimb }
                let intensity = daySessions.reduce(0) { $0 + $1.mitochondrialIndex }
                let label = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                return ChartDataPoint(label: label, value: climb, intensity: intensity, date: date)
            }.reversed()
            
        case .month:
            // Last 30 days grouped by week or day? Let's do 30 days for bar granularity
            return (0..<30).map { dayOffset in
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
                let daySessions = sessions.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
                let climb = daySessions.reduce(0) { $0 + $1.totalClimb }
                let intensity = daySessions.reduce(0) { $0 + $1.mitochondrialIndex }
                return ChartDataPoint(label: "\(calendar.component(.day, from: date))", value: climb, intensity: intensity, date: date)
            }.reversed()
            
        case .sixMonths:
            // Last 6 months
            return (0..<6).map { monthOffset in
                let date = calendar.date(byAdding: .month, value: -monthOffset, to: now)!
                let monthSessions = sessions.filter { calendar.isDate($0.startDate, equalTo: date, toGranularity: .month) }
                let climb = monthSessions.reduce(0) { $0 + $1.totalClimb }
                let intensity = monthSessions.reduce(0) { $0 + $1.mitochondrialIndex }
                let label = calendar.shortMonthSymbols[calendar.component(.month, from: date) - 1]
                return ChartDataPoint(label: label, value: climb, intensity: intensity, date: date)
            }.reversed()
            
        case .year:
            // Last 12 months
            return (0..<12).map { monthOffset in
                let date = calendar.date(byAdding: .month, value: -monthOffset, to: now)!
                let monthSessions = sessions.filter { calendar.isDate($0.startDate, equalTo: date, toGranularity: .month) }
                let climb = monthSessions.reduce(0) { $0 + $1.totalClimb }
                let intensity = monthSessions.reduce(0) { $0 + $1.mitochondrialIndex }
                let label = calendar.shortMonthSymbols[calendar.component(.month, from: date) - 1]
                return ChartDataPoint(label: label, value: climb, intensity: intensity, date: date)
            }.reversed()
        }
    }
}

struct ChartDataPoint: Equatable, Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let intensity: Double // e.g. mitochondrial index minutes
    let date: Date
}
