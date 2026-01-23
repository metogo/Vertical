import ComposableArchitecture
import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.vertical.result", category: "ResultFeature")

@Reducer
struct ResultFeature {
    @ObservableState
    struct State: Equatable {
        let sessionId: String
        var readings: [SensorReading] = []
        var isLoading: Bool = false
        var totalClimb: Double = 0.0
        var isAMPKActivated: Bool = false
        var mitochondrialIndex: Double = 0.0
        var rerEstimation: Double = 0.85
        var autophagyDepth: Double = 0.0
        var isPrivacyModeEnabled: Bool = false
        
        /// Standard initializer
        init(sessionId: String, isAMPKActivated: Bool = false, mitochondrialIndex: Double = 0.0, rerEstimation: Double = 0.85, autophagyDepth: Double = 0.0) {
            self.sessionId = sessionId
            self.isAMPKActivated = isAMPKActivated
            self.mitochondrialIndex = mitochondrialIndex
            self.rerEstimation = rerEstimation
            self.autophagyDepth = autophagyDepth
        }
        
        /// Initializer with pre-loaded data (for simulator/testing)
        init(sessionId: String, readings: [SensorReading], totalClimb: Double, isAMPKActivated: Bool = false, mitochondrialIndex: Double = 0.0, rerEstimation: Double = 0.85, autophagyDepth: Double = 0.0) {
            self.sessionId = sessionId
            self.readings = readings
            self.totalClimb = totalClimb
            self.isAMPKActivated = isAMPKActivated
            self.mitochondrialIndex = mitochondrialIndex
            self.rerEstimation = rerEstimation
            self.autophagyDepth = autophagyDepth
            self.isLoading = false
        }
        
        /// Filtered readings based on privacy settings
        var visibleReadings: [SensorReading] {
            if isPrivacyModeEnabled && readings.count > 10 {
                // Remove first and last 10% of points to obscure start/end locations
                let clipCount = readings.count / 10
                let clipped = Array(readings[clipCount..<(readings.count - clipCount)])
                // Ensure we have at least 2 points for rendering
                return clipped.count >= 2 ? clipped : readings
            }
            return readings
        }
    }
    
    enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)
        
        enum ViewAction {
            case onAppear
            case closeButtonTapped
            case privacyToggleTapped
            case shareButtonTapped
        }
        
        enum InternalAction {
            case readingsLoaded([SensorReading])
        }
    }
    
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.shareClient) var shareClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.landmarkClient) var landmarkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                // Skip database fetch if data was already pre-loaded (simulator mode)
                if !state.readings.isEmpty {
                    state.isLoading = false
                    return .none
                }
                
                state.isLoading = true
                let sessionId = state.sessionId
                return .run { send in
                    do {
                        print("📊 ResultFeature: Fetching readings for session \(sessionId)")
                        let readings = try await databaseClient.fetchSession(sessionId)
                        print("📊 ResultFeature: Got \(readings.count) readings")
                        await send(.internal(.readingsLoaded(readings)))
                    } catch {
                        print("❌ ResultFeature: fetchSession error: \(error.localizedDescription)")
                        logger.error("Failed to fetch session readings: \(error.localizedDescription)")
                        await send(.internal(.readingsLoaded([])))
                    }
                }
                
            case .view(.closeButtonTapped):
                return .run { _ in await dismiss() }
                
            case let .internal(.readingsLoaded(readings)):
                state.isLoading = false
                state.readings = readings
                
                if !readings.isEmpty {
                    let altitudes = readings.map { $0.relativeAltitude }
                    let minAlt = altitudes.min() ?? 0
                    let maxAlt = altitudes.max() ?? 0
                    state.totalClimb = maxAlt - minAlt
                    
                    // Simple VAM estimation for the summary if needed, 
                    // though usually we'd track session max VAM during the session.
                }
                
                // Load session record to get AMPK status
                // (Already passed from tracker state in this flow)
                return .none
                
            case .view(.shareButtonTapped):
                let totalClimb = state.totalClimb
                let readingsCount = state.readings.count
                let isActive = state.isAMPKActivated
                let mito = state.mitochondrialIndex
                let rer = state.rerEstimation
                let autoph = state.autophagyDepth
                
                return .run { [shareClient, landmarkClient] send in
                    // Fetch landmarks to find which one was reached
                    let landmarks = (try? await landmarkClient.loadLandmarks()) ?? []
                    let highestReached = landmarks.last { $0.height <= totalClimb }?.name
                        
                    // Generate image on main actor
                    let image: UIImage? = await MainActor.run {
                        let cardView = CinematicCardView(
                            totalClimb: totalClimb, 
                            landmarkName: highestReached,
                            readingsCount: readingsCount,
                            isAMPKActivated: isActive,
                            mitochondrialIndex: mito,
                            rerEstimation: rer,
                            autophagyDepth: autoph
                        )
                        
                        let renderer = ImageRenderer(content: cardView)
                        renderer.scale = 3.0 // High res
                        return renderer.uiImage
                    }
                    
                    // Share using client
                    if let image = image {
                        await shareClient.shareImage(image)
                    }
                }
                
            case .view(.privacyToggleTapped):
                state.isPrivacyModeEnabled.toggle()
                return .none
            }
        }
    }
}

struct ResultView: View {
    let store: StoreOf<ResultFeature>
    
    var body: some View {
        ZStack {
            // Consistent dark background
            Color.black.ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.05, blue: 0.15),
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    .black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if store.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                VStack(spacing: 20) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(LocalizedStringKey("SESSION SUMMARY"))
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(.cyan.opacity(0.8))
                                .kerning(2)
                            
                            Text(LocalizedStringKey("Epic Climb"))
                                .font(.system(size: 32, weight: .black))
                                .italic()
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button {
                                store.send(.view(.shareButtonTapped))
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            
                            Button {
                                store.send(.view(.closeButtonTapped))
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // 3D Visualization Container
                    ZStack {
                        SpiralContainerView(readings: store.visibleReadings)
                            .id(store.isPrivacyModeEnabled)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(.black.opacity(0.4))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.cyan.opacity(0.5), .purple.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: .cyan.opacity(0.15), radius: 20, x: 0, y: 10)
                        
                        VStack {
                            Spacer()
                            Text(LocalizedStringKey("DRAG TO ROTATE 3D DATA PATH"))
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.4))
                                .padding(.bottom, 24)
                                .kerning(1)
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(maxHeight: .infinity)
                    
                    // Stats Floor
                    HStack(spacing: 0) {
                        SummaryStatView(
                            label: "TOTAL_CLIMB",
                            value: String(format: "%.0f", store.totalClimb),
                            unit: "m"
                        )
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(height: 40)
                            .background(Color.white.opacity(0.1))
                        
                        SummaryStatView(
                            label: "READINGS",
                            value: "\(store.readings.count)",
                            unit: "pts"
                        )
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(height: 40)
                            .background(Color.white.opacity(0.1))
                        
                        VStack(spacing: 6) {
                            Text(LocalizedStringKey("METABOLIC"))
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(.white.opacity(0.4))
                                .kerning(1)
                            
                            HStack(spacing: 4) {
                                if store.isAMPKActivated {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.orange)
                                    Text(LocalizedStringKey("ACTIVATED"))
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(.orange)
                                } else {
                                    Text(LocalizedStringKey("NONE"))
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.white.opacity(0.03))
                    )
                    .padding(.horizontal, 24)
                    
                    // Detailed Metabolic Summary
                    VStack(spacing: 20) {
                        HStack {
                            Text(LocalizedStringKey("METABOLIC REPORT"))
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(.white.opacity(0.6))
                                .kerning(2)
                            Spacer()
                            if store.isAMPKActivated {
                                Label("AMPK_ACTIVATED", systemImage: "flame.fill")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(.orange)
                            }
                        }
                        
                        HStack(spacing: 30) {
                            MetabolicStatItem(
                                label: "MITO_GENERATION",
                                value: String(format: "%.1f", store.mitochondrialIndex),
                                unit: "min",
                                icon: "microbe.fill",
                                color: .green
                            )
                            
                            MetabolicStatItem(
                                label: "FAT_RER",
                                value: String(format: "%.2f", store.rerEstimation),
                                unit: "",
                                icon: "lungs.fill",
                                color: .blue
                            )
                            
                            MetabolicStatItem(
                                label: "AUTO_DEPTH",
                                value: String(format: "%.1f", store.autophagyDepth),
                                unit: "",
                                icon: "leaf.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    
                    // Privacy Toggle
                    Button {
                        store.send(.view(.privacyToggleTapped))
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: store.isPrivacyModeEnabled ? "eye.slash.fill" : "eye.fill")
                            Text(store.isPrivacyModeEnabled ? "PRIVACY_ON" : "PRIVACY_OFF")
                            
                            Text("•")
                                .opacity(0.5)
                            
                            Text(store.isPrivacyModeEnabled ? "START_END_HIDDEN" : "FULL_PATH_VISIBLE")
                                .font(.system(size: 9, weight: .bold))
                                .opacity(0.7)
                        }
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(store.isPrivacyModeEnabled ? .orange : .cyan)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(store.isPrivacyModeEnabled ? .orange.opacity(0.1) : .cyan.opacity(0.1))
                                Capsule()
                                    .stroke(store.isPrivacyModeEnabled ? .orange.opacity(0.5) : .cyan.opacity(0.5), lineWidth: 1.5)
                            }
                        )
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            store.send(.view(.onAppear))
        }
    }
}

private struct SummaryStatView: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(LocalizedStringKey(label))
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(.white.opacity(0.4))
                .kerning(1)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                
                Text(LocalizedStringKey(unit))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.cyan)
                    .opacity(0.8)
            }
        }
    }
}

private struct MetabolicStatItem: View {
    let label: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            
            VStack(spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                    if !unit.isEmpty {
                        Text(LocalizedStringKey(unit))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(LocalizedStringKey(label))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
