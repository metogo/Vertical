import ComposableArchitecture
import SwiftUI
import Charts

struct StatsView: View {
    let store: StoreOf<StatsFeature>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header Stats - Apple Fitness Style
                    summarySection
                    
                    // Main Chart Section
                    chartSection
                    
                    // Trends / Insights Section
                    insightsSection
                    
                    // Metabolic Analysis Section
                    metabolicSection
                }
                .padding(.vertical)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(String(localized: "STATISTICS"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    chartTypeMenu
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
    @ViewBuilder
    private var chartTypeMenu: some View {
        Menu {
            Picker("CHART_TYPE", selection: Binding(
                get: { store.selectedChartType },
                set: { store.send(.chartTypeChanged($0)) }
            )) {
                ForEach(StatsFeature.State.ChartType.allCases, id: \.self) { type in
                    Label(LocalizedStringKey(type.rawValue), systemImage: type == .altitude ? "mountain.2.fill" : "bolt.heart.fill")
                        .tag(type)
                }
            }
        } label: {
            Image(systemName: store.selectedChartType == .altitude ? "mountain.2.fill" : "bolt.heart.fill")
                .foregroundStyle(store.selectedChartType == .altitude ? .cyan : .orange)
                .padding(8)
                .background(Circle().fill(Color.white.opacity(0.1)))
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Time Range Picker - Apple Segmented Style
            Picker("Time Range", selection: Binding(
                get: { store.selectedRange },
                set: { store.send(.timeRangeChanged($0)) }
            )) {
                ForEach(StatsFeature.State.TimeRange.allCases, id: \.self) { range in
                    Text(LocalizedStringKey(range.rawValue)).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Highlight Stat
            VStack(alignment: .leading, spacing: 4) {
                Text(store.selectedChartType == .altitude ? "TOTAL_CLIMB" : "METABOLIC_MINUTES")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    let value = store.selectedChartType == .altitude 
                        ? store.totalClimbInRange 
                        : store.chartData.reduce(0) { $0 + $1.intensity }
                    
                    Text("\(Int(value))")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(store.selectedChartType == .altitude ? .white : .orange)
                    Text(store.selectedChartType == .altitude ? "m" : "min")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var totalClimbSummary: some View {
        VStack(spacing: 4) {
            Text(store.selectedChartType == .altitude ? "TOTAL_CLIMB" : "METABOLIC_MINUTES")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(.white.opacity(0.4))
                .kerning(2)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                let value = store.selectedChartType == .altitude 
                    ? store.totalClimbInRange 
                    : store.chartData.reduce(0) { $0 + $1.intensity }
                
                Text("\(Int(value))")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(store.selectedChartType == .altitude ? .white : .orange)
                Text(store.selectedChartType == .altitude ? "m" : "min")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(store.selectedChartType == .altitude ? "ALTITUDE_PROGRESS" : "METABOLIC_INTENSITY")
                .font(.headline)
                .foregroundStyle(store.selectedChartType == .altitude ? .cyan : .orange)
            
            Chart {
                ForEach(store.chartData) { point in
                    let yValue = store.selectedChartType == .altitude ? point.value : point.intensity
                    
                    if store.selectedRange == .day || store.selectedRange == .week {
                        BarMark(
                            x: .value("Date", point.label),
                            y: .value("Value", yValue)
                        )
                        .foregroundStyle(store.selectedChartType == .altitude ? Color.cyan.gradient : Color.orange.gradient)
                        .cornerRadius(4)
                    } else {
                        AreaMark(
                            x: .value("Date", point.label),
                            y: .value("Value", yValue)
                        )
                        .foregroundStyle(store.selectedChartType == .altitude ? Color.cyan.opacity(0.1).gradient : Color.orange.opacity(0.1).gradient)
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Date", point.label),
                            y: .value("Value", yValue)
                        )
                        .foregroundStyle(store.selectedChartType == .altitude ? Color.cyan.gradient : Color.orange.gradient)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                }
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(.white.opacity(0.1))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel() {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TRENDS")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    InsightMiniCard(
                        title: "7_DAY_PULSE",
                        value: "142",
                        unit: String(localized: "m/avg"),
                        trend: "+12%",
                        trendPositive: true,
                        icon: "waveform.path.ecg",
                        color: .green
                    )
                    
                    InsightMiniCard(
                        title: "MITO_SCORE",
                        value: "84",
                        unit: String(localized: "pts"),
                        trend: "+5",
                        trendPositive: true,
                        icon: "bolt.fill",
                        color: .orange
                    )
                }
                
                InsightMiniCard(
                    title: "PEAK_INTENSITY",
                    value: String(localized: "AMPK_ZONE"),
                    unit: "",
                    trend: "85% HRR",
                    trendPositive: true,
                    icon: "flame.fill",
                    color: .pink
                )
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var metabolicSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("METABOLIC_QUALITY")
                .font(.headline)
                .foregroundStyle(.purple)
            
            VStack(spacing: 20) {
                GeometryReader { geo in
                    HStack(spacing: 4) {
                        DistributionBar(color: .blue, weight: 0.3, label: String(localized: "BASE"))
                            .frame(width: (geo.size.width - 12) * 0.3)
                        DistributionBar(color: .cyan, weight: 0.4, label: String(localized: "FAT_OX"))
                            .frame(width: (geo.size.width - 12) * 0.4)
                        DistributionBar(color: .pink, weight: 0.2, label: String(localized: "GLUCOSE"))
                            .frame(width: (geo.size.width - 12) * 0.2)
                        DistributionBar(color: .orange, weight: 0.1, label: String(localized: "AMPK"))
                            .frame(width: (geo.size.width - 12) * 0.1)
                    }
                }
                .frame(height: 20)
                .clipShape(Capsule())
                
                // Legend
                HStack(spacing: 12) {
                    LegendItem(color: .blue, label: String(localized: "RECOVERY"))
                    LegendItem(color: .cyan, label: String(localized: "FAT_BURN"))
                    LegendItem(color: .pink, label: String(localized: "PERFORMANCE"))
                    LegendItem(color: .orange, label: String(localized: "AMPK"))
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct InsightMiniCard: View {
    let title: LocalizedStringKey
    let value: String
    let unit: String
    let trend: String
    let trendPositive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Spacer()
                Text(trend)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(trendPositive ? .green : .red)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct DistributionBar: View {
    let color: Color
    let weight: Double
    let label: String
    
    var body: some View {
        Rectangle()
            .fill(color)
            .overlay(
                Text(label)
                    .font(.system(size: 6, weight: .black))
                    .foregroundStyle(.white.opacity(0.6))
                    .opacity(weight > 0.15 ? 1 : 0)
            )
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

#Preview {
    StatsView(
        store: Store(initialState: StatsFeature.State()) {
            StatsFeature()
        } withDependencies: {
            $0.databaseClient = .previewValue
        }
    )
}
