import ComposableArchitecture
import SwiftUI

struct TrackerView: View {
    let store: StoreOf<TrackerFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            // Paused Banner
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
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.orange.opacity(0.3), lineWidth: 1))
                .padding(.top, 8)
            }
            
            // Retroactive Session Banner
            if let floors = store.retroactiveSessionFloors {
                HStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HIDDEN_CLIMB_DETECTED")
                            .font(.system(size: 11, weight: .black))
                        Text("FOUND_FLOORS_OFFLINE \(floors)")
                            .font(.system(size: 10, weight: .bold))
                            .opacity(0.8)
                    }
                    
                    Spacer()
                    
                    Button { store.send(.view(.retroactiveDismissTapped)) } label: {
                        Text("SYNC")
                            .font(.system(size: 10, weight: .black))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                }
                .padding(12)
                .background(Color.blue.opacity(0.15))
                .foregroundStyle(.blue)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.blue.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
            }
            
            // 1. Primary Altitude Gauge
            VStack(spacing: 0) {
                Text(String(localized: "ALTITUDE"))
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white.opacity(0.4))
                    .kerning(4)
                
                RollingNumberView(
                    value: Int(store.currentAltitude),
                    font: .system(size: 88, weight: .black, design: .rounded),
                    fontSize: 88,
                    minimumDigits: 3
                )
                .frame(height: 100)
                .foregroundStyle(dynamicColor)
                .shadow(color: dynamicColor.opacity(0.6), radius: 15)
                .shadow(color: dynamicColor.opacity(0.3), radius: 30)
                
                Text(String(localized: "METERS"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .kerning(2)
            }
            .padding(24)
            .background(
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(dynamicColor.opacity(0.1), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: min(store.vam / RollingNumberConfiguration.peakVam, 1.0))
                        .stroke(
                            AngularGradient(
                                colors: [dynamicColor.opacity(0.2), dynamicColor],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: store.vam)
                }
            )
            .padding(.top, 10)
            
            // 2. Metabolic Stimulus Indicator
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: store.isAMPKActivated ? "flame.fill" : "bolt.heart.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(store.isAMPKActivated ? .orange : .white.opacity(0.4))
                        
                        Text(store.isAMPKActivated ? "AMPK_ACTIVATED" : "ACTIVATING_AMPK")
                            .font(.system(size: 10, weight: .black))
                            .kerning(1.5)
                            .foregroundStyle(store.isAMPKActivated ? .orange : .white.opacity(0.6))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(store.isAMPKActivated ? Color.orange.opacity(0.15) : Color.white.opacity(0.05))
                            .overlay(Capsule().stroke(store.isAMPKActivated ? Color.orange.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1))
                    )
                    
                    // Science Info Button
                    Button { store.send(.view(.infoButtonTapped)) } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                
                // Progress bar
                if !store.isAMPKActivated && store.isTracking {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 140, height: 3)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [.orange.opacity(0.6), .orange], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 140 * CGFloat(min(store.activeClimbDuration / 120.0, 1.0)), height: 3)
                            .shadow(color: .orange.opacity(0.5), radius: 4)
                    }
                    .animation(.linear, value: store.activeClimbDuration)
                }
            }
            .padding(.vertical, 8)
            
            // 3. Stats Dashboard Row
            HStack(spacing: 12) {
                StatCard(label: "VAM", value: String(format: "%.0f", store.vam), unit: "m/h", color: .pink)
                
                // Interactive Toggle Card
                Button { store.send(.view(.hapticToggleTapped)) } label: {
                    VStack(spacing: 4) {
                        Image(systemName: store.isHapticEnabled ? "hand.tap.fill" : "hand.tap")
                            .font(.title3)
                            .foregroundStyle(store.isHapticEnabled ? .cyan : .white.opacity(0.2))
                        Text(store.isHapticEnabled ? "HAPTICS_ON" : "HAPTICS_OFF")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(store.isHapticEnabled ? .cyan : .white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.03)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(store.isHapticEnabled ? .cyan.opacity(0.3) : .clear, lineWidth: 1))
                }
                
                StatCard(label: "STATUS", value: store.isPaused ? String(localized: "PAUSED") : String(localized: "ACTIVE"), unit: "", color: store.isPaused ? .orange : .cyan)
            }
            .padding(.horizontal)
            
            // 4. Landmark Progress (HUD Style)
            landmarkProgressCard
            
            // 5. 3D MetaVision Visualizer (Bottom Focus)
            metaVisionDashboard
            
            Spacer(minLength: 0)
            
            // 6. Action Controls
            VStack(spacing: 12) {
                if store.isPaused {
                    ActionButton(title: "RESUME_TRACKING", icon: "play.fill", color: .green) {
                        store.send(.view(.resumeButtonTapped))
                    }
                }
                
                ActionButton(title: store.isTracking ? "STOP_TRACKING" : "START_TRACKING", 
                             icon: store.isTracking ? "stop.fill" : "play.fill", 
                             color: store.isTracking ? .red : .blue) {
                    store.send(.view(store.isTracking ? .stopButtonTapped : .startButtonTapped))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.black.ignoresSafeArea())
        .overlay {
            if let landmarkName = store.lastUnlockedLandmarkName {
                UnlockedLandmarkOverlay(name: landmarkName)
                    .zIndex(10)
            }
        }
        .sheet(isPresented: Binding(
            get: { store.isScienceBoardPresented },
            set: { _ in store.send(.view(.infoButtonTapped)) }
        )) {
            ScienceBoardView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private var metaVisionDashboard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                // 3D Avatar Container
                ZStack {
                    // Solid dark background for 3D view
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(colors: [(store.isAMPKActivated ? Color.orange : Color.cyan).opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                        )
                    
                    MetabolicAvatarView(
                        intensity: store.hrrPercentage,
                        isAMPKActivated: store.isAMPKActivated
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    // Scanning HUD Overlay (More subtle)
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, (store.isAMPKActivated ? Color.orange : Color.cyan).opacity(0.15), .clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 30)
                            .offset(y: -4)
                    }
                }
                .frame(width: 140, height: 180)
                .shadow(color: (store.isAMPKActivated ? Color.orange : Color.cyan).opacity(0.15), radius: 15)
                
                // Detailed Biological Indicators
                VStack(alignment: .leading, spacing: 18) {
                    MetabolicIndicator(label: "MITO_GEN", value: String(format: "%.1f", store.mitochondrialIndex), unit: "min", icon: "microbe.fill", color: .green, progress: store.hrrPercentage > 0.7 ? 0.8 : 0.2)
                    MetabolicIndicator(label: "RER_EST", value: String(format: "%.2f", store.rerEstimation), unit: "", icon: "lungs.fill", color: .blue, progress: (store.rerEstimation - 0.7) / 0.3)
                    MetabolicIndicator(label: "AUTOPHAGY", value: String(format: "%.1f", store.autophagyDepth), unit: "", icon: "leaf.fill", color: .purple, progress: min(store.autophagyDepth / 100.0, 1.0))
                }
            }
            
            // Heart Rate HUD
            HStack(spacing: 4) {
                Circle()
                    .fill(store.heartRate > 0 ? (store.hrrPercentage > 0.8 ? Color.red : Color.green) : Color.gray)
                    .frame(width: 6, height: 6)
                    .shadow(color: (store.hrrPercentage > 0.8 ? Color.red : Color.green).opacity(0.5), radius: 3)
                
                Text("\(Int(store.heartRate))")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("BPM")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
                    .kerning(1)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.02))
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            }
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var landmarkProgressCard: some View {
        if let next = store.nextLandmark {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(.cyan.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: next.systemImage)
                        .foregroundStyle(.cyan)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEXT_TARGET")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.white.opacity(0.4))
                        .kerning(1)
                    Text(LocalizedStringKey(next.name))
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(store.progressToNextLandmark * 100))%")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.cyan)
                    Text("\(Int(next.height))m")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.1), lineWidth: 1)
                            // Background progress line
                            Capsule()
                                .fill(Color.cyan.opacity(0.2))
                                .frame(height: 2)
                                .padding(.horizontal, 16)
                                .offset(y: 28)
                            // Active progress line
                            GeometryReader { geo in
                                Capsule()
                                    .fill(Color.cyan)
                                    .frame(width: (geo.size.width - 32) * CGFloat(store.progressToNextLandmark), height: 2)
                                    .padding(.horizontal, 16)
                                    .offset(y: 28)
                                    .shadow(color: .cyan.opacity(0.8), radius: 4)
                            }
                        }
                    )
            )
            .padding(.horizontal)
        }
    }
    
    private var dynamicColor: Color {
        if store.isPaused { return .orange }
        if !store.isTracking { return .gray }
        let ratio = min(max(store.vam / RollingNumberConfiguration.peakVam, 0), 1)
        return Color.interpolate(from: .blue, to: .pink, ratio: ratio)
    }
}

// MARK: - Subcomponents

struct StatCard: View {
    let label: LocalizedStringKey
    let value: String
    let unit: LocalizedStringKey
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundStyle(.white.opacity(0.4))
                .kerning(1)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                if !unit.stringValue.isEmpty {
                    Text(unit)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.03)))
    }
}

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
                Text(label).font(.system(size: 9, weight: .black)).foregroundStyle(.white.opacity(0.5)).kerning(0.5)
                Spacer()
                Text(value).font(.system(size: 12, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text(unit).font(.system(size: 7, weight: .bold)).foregroundStyle(.white.opacity(0.3))
            }
            
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.05)).frame(height: 4)
                Capsule()
                    .fill(color)
                    .frame(width: 100 * CGFloat(progress), height: 4)
                    .shadow(color: color.opacity(0.5), radius: 4)
            }
            .frame(width: 120) // Slightly wider
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
                Image(systemName: icon)
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .kerning(1)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 10, y: 5)
        }
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

struct ScienceBoardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AMPK_SCIENCE_TITLE")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [.orange, .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 2)
                        .frame(width: 100)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    ScienceSection(title: "WHAT_IS_AMPK", content: "AMPK_DESCRIPTION", icon: "bolt.fill", color: .orange)
                    ScienceSection(title: "WHY_CLIMB", content: "CLIMB_BENEFITS", icon: "chart.line.uptrend.xyaxis", color: .cyan)
                    ScienceSection(title: "DECODING_VISUALS", content: "VISUALS_GUIDE", icon: "eye.fill", color: .purple)
                }
                
                Text("SCIENCE_FOOTNOTE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.top, 10)
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
                Text(title)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(color)
            }
            
            Text(content)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.05), lineWidth: 1))
        )
    }
}

struct UnlockedLandmarkOverlay: View {
    let name: String
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                    .opacity(0.5)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                    .shadow(color: .cyan.opacity(0.5), radius: 10)
            }
            
            VStack(spacing: 4) {
                Text("UNLOCKED")
                    .font(.system(size: 12, weight: .black))
                    .kerning(6)
                    .foregroundStyle(.white.opacity(0.7))
                
                Text(LocalizedStringKey(name))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .textCase(.uppercase)
                    .foregroundStyle(.white)
                    .italic()
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
        }
        .padding(40)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black.opacity(0.85))
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .clear, .cyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(rotation))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.5), .clear, .cyan.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 30)
        .scaleEffect(1.1)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
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
        let h = fromH + (toH - fromH) * interpRatio
        let s = fromS + (toS - fromS) * interpRatio
        let b = fromB + (toB - fromB) * interpRatio
        let a = fromA + (toA - fromA) * interpRatio
        return Color(hue: Double(h), saturation: Double(s), brightness: Double(b), opacity: Double(a))
    }
}
extension LocalizedStringKey {
    var stringValue: String {
        let mirror = Mirror(reflecting: self)
        return mirror.descendant("key") as? String ?? ""
    }
}
