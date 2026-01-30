import ComposableArchitecture
import SwiftUI

struct TrackerView: View {
    let store: StoreOf<TrackerFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 120) // Significant breathing room at the top
            
            // Main content area
            VStack(spacing: 20) { // Increased spacing between cards
                // 1. Header: AMPK Status + Info
                headerSection
                
                // 2. Hero Altitude Display
                heroAltitudeSection
                
                // 3. Quick Stats Row
                quickStatsRow
                
                // 4. Next Landmark Progress
                landmarkProgressCard
                
                // 5. MetaVision Dashboard
                metaVisionDashboard
            }
            .padding(.horizontal, 16)
            
            Spacer(minLength: 16) // Smaller flexible space to push content slightly further down
            
            // Action button at bottom
            actionControls
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .overlay {
            bannerOverlays
            celebrationOverlay
            savingOverlay
        }
        .sheet(isPresented: Binding(
            get: { store.isScienceBoardPresented },
            set: { _ in store.send(.view(.infoButtonTapped)) }
        )) {
            ScienceBoardView(isAMPKActivated: store.isAMPKActivated)
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            // AMPK Status Badge
            HStack(spacing: 8) {
                Image(systemName: store.isAMPKActivated ? "flame.fill" : "bolt.heart.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(store.isAMPKActivated ? .orange : .white.opacity(0.4))
                
                Text(store.isAMPKActivated ? "AMPK_ACTIVATED" : "ACTIVATING_AMPK")
                    .font(.system(size: 11, weight: .black))
                    .kerning(1)
                    .foregroundStyle(store.isAMPKActivated ? .orange : .white.opacity(0.5))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(
                Capsule()
                    .fill(store.isAMPKActivated ? Color.orange.opacity(0.12) : Color.white.opacity(0.05))
                    .overlay(Capsule().stroke(store.isAMPKActivated ? Color.orange.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1))
            )
            
            Spacer()
            
            // Info Button
            Button { store.send(.view(.infoButtonTapped)) } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }
    
    // MARK: - Hero Altitude Section (No Clipping Circle)
    @ViewBuilder
    private var heroAltitudeSection: some View {
        let altitudeValue = Int(store.animatedAltitude)
        let digitCount = String(altitudeValue).count
        let fontSize: CGFloat = digitCount >= 4 ? 64 : 80
        let displayColor = store.isTracking ? dynamicColor : .cyan
        
        VStack(spacing: 8) {
            // Main Altitude Number
            RollingNumberView(
                value: altitudeValue,
                font: .system(size: fontSize, weight: .black, design: .rounded),
                fontSize: fontSize,
                minimumDigits: 3
            )
            .frame(height: fontSize * 1.1)
            .foregroundStyle(displayColor)
            .shadow(color: displayColor.opacity(0.6), radius: 20)
            
            // Unit Label
            Text(String(localized: "METERS"))
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .kerning(3)
            
            // VAM Progress Arc
            vamProgressBar
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(displayColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - VAM Progress Bar
    @ViewBuilder
    private var vamProgressBar: some View {
        let progress = min(store.vam / RollingNumberConfiguration.peakVam, 1.0)
        let displayColor = store.isTracking ? dynamicColor : .cyan
        
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    // Fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [displayColor.opacity(0.7), displayColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * CGFloat(progress), 0), height: 6)
                        .shadow(color: displayColor.opacity(0.6), radius: 8, x: 4, y: 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 50)
            
            // VAM Value
            HStack(spacing: 4) {
                Text(String(format: "%.0f", store.vam))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(displayColor)
                Text(String(localized: "METERS_PER_HOUR"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.top, 12)
    }
    
    // MARK: - Quick Stats Row
    @ViewBuilder
    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            // Haptics Toggle
            Button { store.send(.view(.hapticToggleTapped)) } label: {
                VStack(spacing: 5) {
                    Image(systemName: store.isHapticEnabled ? "hand.tap.fill" : "hand.tap")
                        .font(.system(size: 16))
                        .foregroundStyle(store.isHapticEnabled ? .cyan : .white.opacity(0.2))
                    Text(store.isHapticEnabled ? "HAPTICS_ON" : "HAPTICS_OFF")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(store.isHapticEnabled ? .cyan : .white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.04))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(store.isHapticEnabled ? .cyan.opacity(0.2) : .white.opacity(0.03), lineWidth: 1))
                )
            }
            
            // Status Card
            VStack(spacing: 5) {
                Circle()
                    .fill(store.isPaused ? Color.orange : (store.isTracking ? Color.green : Color.gray))
                    .frame(width: 8, height: 8)
                    .shadow(color: store.isPaused ? .orange.opacity(0.5) : (store.isTracking ? .green.opacity(0.5) : .clear), radius: 3)
                
                Text(store.isPaused ? String(localized: "PAUSED") : (store.isTracking ? String(localized: "ACTIVE") : String(localized: "STOPPED")))
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(store.isPaused ? .orange : (store.isTracking ? .green : .white.opacity(0.4)))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.03), lineWidth: 1))
            )
        }
    }
    
    // MARK: - Landmark Progress Card
    @ViewBuilder
    private var landmarkProgressCard: some View {
        if let next = store.nextLandmark {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(.cyan.opacity(0.1)).frame(width: 34, height: 34)
                        Image(systemName: next.systemImage)
                            .foregroundStyle(.cyan)
                            .font(.system(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("NEXT_TARGET")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white.opacity(0.4))
                            .kerning(1)
                        Text(LocalizedStringKey(next.name))
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(Int(store.progressToNextLandmark * 100))%")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(.cyan)
                        Text("\(Int(next.height))m")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [.cyan.opacity(0.7), .cyan], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(store.progressToNextLandmark), height: 4)
                            .shadow(color: .cyan.opacity(0.5), radius: 5, x: 3, y: 0)
                    }
                }
                .frame(height: 4)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.08), lineWidth: 1))
            )
        }
    }
    
    // MARK: - MetaVision Dashboard
    @ViewBuilder
    private var metaVisionDashboard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                // Metabolic Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke((store.isAMPKActivated ? Color.orange : Color.cyan).opacity(0.2), lineWidth: 1)
                        )
                    
                    MetabolicAvatarView(
                        intensity: store.hrrPercentage,
                        isAMPKActivated: store.isAMPKActivated
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .frame(width: 110, height: 140)
                .shadow(color: (store.isAMPKActivated ? Color.orange : Color.cyan).opacity(0.1), radius: 8)
                
                // Biological Indicators
                VStack(alignment: .leading, spacing: 12) {
                    MetabolicIndicator(label: "MITO_GEN", value: String(format: "%.1f", store.mitochondrialIndex), unit: "min", icon: "microbe.fill", color: .green, progress: store.hrrPercentage > 0.7 ? 0.8 : 0.2)
                    MetabolicIndicator(label: "RER_EST", value: String(format: "%.2f", store.rerEstimation), unit: "", icon: "lungs.fill", color: .blue, progress: (store.rerEstimation - 0.7) / 0.3)
                    MetabolicIndicator(label: "AUTOPHAGY", value: String(format: "%.1f", store.autophagyDepth), unit: "", icon: "leaf.fill", color: .purple, progress: min(store.autophagyDepth / 100.0, 1.0))
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Heart Rate HUD
            heartRateHud
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }
    
    // MARK: - Heart Rate HUD
    @ViewBuilder
    private var heartRateHud: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(store.heartRate > 0 ? (store.hrrPercentage > 0.8 ? Color.red : Color.green) : Color.white.opacity(0.1))
                    .frame(width: 8, height: 8)
                
                if store.heartRate > 0 {
                    Circle()
                        .stroke(store.hrrPercentage > 0.8 ? Color.red : Color.green, lineWidth: 2)
                        .frame(width: 14, height: 14)
                        .blur(radius: 2)
                }
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(Int(store.heartRate))")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(String(localized: "BPM"))
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white.opacity(0.3))
                    .kerning(1)
            }
        }
    }
    
    // MARK: - Action Controls
    @ViewBuilder
    private var actionControls: some View {
        VStack(spacing: 8) {
            if store.isPaused {
                ActionButton(title: "RESUME_TRACKING", icon: "play.fill", color: .green) {
                    store.send(.view(.resumeButtonTapped))
                }
            }
            
            ActionButton(
                title: store.isTracking ? "STOP_TRACKING" : "START_TRACKING",
                icon: store.isTracking ? "stop.fill" : "play.fill",
                color: store.isTracking ? .red : .blue
            ) {
                store.send(.view(store.isTracking ? .stopButtonTapped : .startButtonTapped))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.black
                .shadow(color: .black.opacity(0.5), radius: 10, y: -5)
        )
    }
    
    // MARK: - Banner Overlays
    @ViewBuilder
    private var bannerOverlays: some View {
        VStack {
            if store.isPaused {
                HStack {
                    Image(systemName: "pause.circle.fill")
                    Text("AUTO_PAUSED")
                    Spacer()
                }
                .font(.system(size: 11, weight: .black))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.orange.opacity(0.15))
                .foregroundStyle(.orange)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.orange.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 60)
            }
            
            if let landmark = store.lastUnlockedLandmarkName, store.celebrationLandmark == nil {
                UnlockedLandmarkOverlay(name: landmark)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var celebrationOverlay: some View {
        if let landmark = store.celebrationLandmark {
            LandmarkUnlockCelebrationView(landmark: landmark)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity
                ))
                .zIndex(20)
        }
    }
    
    @ViewBuilder
    private var savingOverlay: some View {
        if store.isSaving {
            ZStack {
                Color.black.opacity(0.8)
                VStack(spacing: 20) {
                    ProgressView().tint(.white).scaleEffect(1.5)
                    Text("SAVING_DATA")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.white)
                        .kerning(1)
                }
            }
            .ignoresSafeArea()
            .transition(.opacity)
        }
    }
    
    private var dynamicColor: Color {
        if store.isPaused { return .orange }
        if !store.isTracking { return .gray }
        let ratio = min(max(store.vam / RollingNumberConfiguration.peakVam, 0), 1)
        return Color.interpolate(from: .blue, to: .pink, ratio: ratio)
    }
}

// MARK: - Subcomponents (Keep existing ones)

struct MetabolicIndicator: View {
    let label: LocalizedStringKey
    let value: String
    let unit: LocalizedStringKey
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10)).foregroundStyle(color)
                Text(label).font(.system(size: 10, weight: .black)).foregroundStyle(.white.opacity(0.5)).kerning(0.5)
                Spacer()
                Text(value).font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text(unit).font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.3))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.05)).frame(height: 4)
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(max(0, min(progress, 1.0))), height: 4).shadow(color: color.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

struct ActionButton: View {
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(.white.opacity(0.15)).frame(width: 24, height: 24)
                    Image(systemName: icon).font(.system(size: 11, weight: .bold))
                }
                Text(title).font(.system(size: 14, weight: .black)).kerning(1.5)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [color.opacity(0.8), color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(LinearGradient(colors: [.white.opacity(0.5), .clear, color.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            )
            .shadow(color: color.opacity(0.3), radius: 10, y: 4)
        }
    }
}

// Keep existing helper extensions and views...
struct ScienceBoardView: View {
    let isAMPKActivated: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AMPK_SCIENCE_TITLE")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Rectangle().fill(LinearGradient(colors: [.orange, .clear], startPoint: .leading, endPoint: .trailing)).frame(height: 2).frame(width: 100)
                }
                
                HStack(spacing: 8) {
                    Circle().fill(isAMPKActivated ? Color.orange : Color.gray).frame(width: 8, height: 8).shadow(color: isAMPKActivated ? Color.orange.opacity(0.8) : Color.clear, radius: 4)
                    Text(isAMPKActivated ? "AMPK_STATUS_ACTIVE" : "AMPK_STATUS_INACTIVE").font(.system(size: 10, weight: .black)).foregroundStyle(isAMPKActivated ? .orange : .white.opacity(0.4)).kerning(1)
                }
                .padding(.vertical, 6).padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.05)))
                
                VStack(alignment: .leading, spacing: 20) {
                    ScienceSection(title: "WHAT_IS_AMPK", content: "AMPK_DESCRIPTION", icon: "bolt.fill", color: .orange)
                    ScienceSection(title: "WHY_CLIMB", content: "CLIMB_BENEFITS", icon: "chart.line.uptrend.xyaxis", color: .cyan)
                    ScienceSection(title: "DECODING_VISUALS", content: "VISUALS_GUIDE", icon: "eye.fill", color: .purple)
                }
                
                Text("SCIENCE_FOOTNOTE").font(.system(size: 10, weight: .bold)).foregroundStyle(.white.opacity(0.2)).padding(.top, 10)
            }
            .padding(30)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct ScienceSection: View {
    let title: LocalizedStringKey
    let content: LocalizedStringKey
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(color.opacity(0.1)).frame(width: 32, height: 32)
                    Image(systemName: icon).font(.system(size: 14)).foregroundStyle(color)
                }
                Text(title).font(.system(size: 16, weight: .black)).foregroundStyle(color)
            }
            Text(content).font(.system(size: 14, weight: .medium)).foregroundStyle(.white.opacity(0.7)).lineSpacing(6)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.03)).overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.05), lineWidth: 1)))
    }
}

struct UnlockedLandmarkOverlay: View {
    let name: String
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)).frame(width: 80, height: 80).blur(radius: 20).opacity(0.5)
                Image(systemName: "checkmark.seal.fill").font(.system(size: 44)).foregroundStyle(.white).shadow(color: .cyan.opacity(0.5), radius: 10)
            }
            VStack(spacing: 4) {
                Text("UNLOCKED").font(.system(size: 12, weight: .black)).kerning(6).foregroundStyle(.white.opacity(0.7))
                Text(LocalizedStringKey(name)).font(.system(size: 28, weight: .black, design: .rounded)).textCase(.uppercase).foregroundStyle(.white).italic().shadow(color: .black.opacity(0.3), radius: 4)
            }
        }
        .padding(40)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32).fill(Color.black.opacity(0.85))
                RoundedRectangle(cornerRadius: 32).fill(.ultraThinMaterial).opacity(0.5)
                RoundedRectangle(cornerRadius: 32).fill(LinearGradient(colors: [.white.opacity(0.15), .clear, .cyan.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)).rotationEffect(.degrees(rotation))
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(LinearGradient(colors: [.white.opacity(0.5), .clear, .cyan.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: .black.opacity(0.5), radius: 30)
        .scaleEffect(1.1)
        .onAppear { withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { rotation = 360 } }
    }
}

extension Color {
    static func interpolate(from: Color, to: Color, ratio: Double) -> Color {
        let fromUI = UIColor(from)
        let toUI = UIColor(to)
        var fromH: CGFloat = 0, fromS: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toH: CGFloat = 0, toS: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0
        fromUI.getHue(&fromH, saturation: &fromS, brightness: &fromB, alpha: &fromA)
        toUI.getHue(&toH, saturation: &toS, brightness: &toB, alpha: &toA)
        let interpRatio = CGFloat(ratio)
        return Color(hue: Double(fromH + (toH - fromH) * interpRatio), saturation: Double(fromS + (toS - fromS) * interpRatio), brightness: Double(fromB + (toB - fromB) * interpRatio), opacity: Double(fromA + (toA - fromA) * interpRatio))
    }
}

extension LocalizedStringKey {
    var stringValue: String {
        let mirror = Mirror(reflecting: self)
        return mirror.descendant("key") as? String ?? ""
    }
}

#Preview {
    TrackerView(
        store: Store(initialState: TrackerFeature.State()) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient = .previewValue
            $0.locationClient = .previewValue
            $0.databaseClient = .previewValue
            $0.notificationClient = .previewValue
            $0.hapticClient = .previewValue
            $0.landmarkClient = .testValue
            $0.healthClient = .previewValue
        }
    )
}
