import ComposableArchitecture
import SwiftUI

struct TrackerView: View {
    let store: StoreOf<TrackerFeature>
    
    var body: some View {
        VStack(spacing: 30) {
            // Paused Banner
            if store.isPaused {
                HStack {
                    Image(systemName: "pause.circle.fill")
                    Text("AUTO_PAUSED")
                    Spacer()
                }
                .font(.subheadline)
                .padding()
                .background(Color.orange.opacity(0.2))
                .foregroundStyle(.orange)
                .cornerRadius(10)
                .accessibilityIdentifier("paused_banner")
            }
            
            // VAM Gauge Display
            VStack(spacing: 4) {
                Text("垂直升速")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                
                // Big Neon Numbers with Rolling Animation
                RollingNumberView(
                    value: Int(store.vam),
                    font: .system(size: 84, weight: .black, design: .rounded),
                    fontSize: 84,
                    minimumDigits: 4
                )
                .frame(height: 100)
                .foregroundStyle(dynamicColor)
                .shadow(color: dynamicColor.opacity(0.5), radius: 10)
                .shadow(color: dynamicColor.opacity(0.3), radius: 20)
                .accessibilityIdentifier("vam_value")
                
                Text("米/小时")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(40)
            .background(
                ZStack {
                    Circle()
                        .stroke(dynamicColor.opacity(0.1), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0, to: min(store.vam / RollingNumberConfiguration.peakVam, 1.0))
                        .stroke(
                            AngularGradient(
                                colors: [dynamicColor.opacity(0.5), dynamicColor],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: store.vam)
                }
            )
            .accessibilityIdentifier("vam_gauge")
            
            // Secondary Stats
            HStack(spacing: 32) {
                StatView(label: String(localized: "ALTITUDE"), value: String(format: NSLocalizedString("%.1f m", comment: ""), store.currentAltitude))
                    .accessibilityIdentifier("altitude_stat")
                
                // Haptic / Pocket Mode Toggle
                Button(action: {
                    store.send(.view(.hapticToggleTapped))
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: store.isHapticEnabled ? "hand.tap.fill" : "hand.tap")
                            .font(.title2)
                        Text(store.isHapticEnabled ? String(localized: "HAPTICS ON") : String(localized: "HAPTICS OFF"))
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(store.isHapticEnabled ? .cyan : .white.opacity(0.4))
                }
                .accessibilityIdentifier("haptic_toggle")
                
                if store.isTracking {
                    StatView(label: String(localized: "STATUS"), value: store.isPaused ? String(localized: "PAUSED") : String(localized: "ACTIVE"))
                        .accessibilityIdentifier("status_stat")
                }
            }
            
            landmarkProgressView
            
            Spacer()
            
            // Controls
            VStack(spacing: 12) {
                // Resume button (only when paused)
                if store.isPaused {
                    Button(action: {
                        store.send(.view(.resumeButtonTapped))
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("RESUME TRACKING")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .accessibilityIdentifier("resume_button")
                }
                
                // Start/Stop button
                Button(action: {
                    store.send(.view(store.isTracking ? .stopButtonTapped : .startButtonTapped))
                }) {
                    HStack {
                        Image(systemName: store.isTracking ? "stop.fill" : "play.fill")
                        Text(store.isTracking ? "STOP TRACKING" : "START TRACKING")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(store.isTracking ? Color.red : Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .accessibilityIdentifier("tracking_button")
            }
        }
        .padding()
        .overlay {
            if let landmarkName = store.lastUnlockedLandmarkName {
                UnlockedLandmarkOverlay(name: landmarkName)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: store.isPaused)
        .animation(.spring(), value: store.vam)
        .animation(.spring(), value: store.lastUnlockedLandmarkName)
    }
    
    @ViewBuilder
    private var landmarkProgressView: some View {
        if store.isTracking, let next = store.nextLandmark {
            VStack(spacing: 10) {
                // Target landmark info
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NEXT GOAL")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                        
                        HStack(spacing: 6) {
                            Image(systemName: next.systemImage)
                                .font(.system(size: 12))
                                .foregroundStyle(.cyan)
                            Text(LocalizedStringKey(next.name))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: NSLocalizedString("%.0f%%", comment: ""), store.progressToNextLandmark * 100))
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(dynamicColor)
                        Text(String(format: NSLocalizedString("at %.0fm", comment: ""), next.height))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, dynamicColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(store.progressToNextLandmark))
                            .shadow(color: dynamicColor.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.leading)
            .padding(.trailing, 60) // High clearance for the Vertical Axis
        }
    }
    
    private var dynamicColor: Color {
        if store.isPaused {
            return .orange
        } else if !store.isTracking {
            return .gray
        } else {
            // Smooth interpolation between Blue (0 VAM) and Pink (peak VAM)
            let ratio = min(max(store.vam / RollingNumberConfiguration.peakVam, 0), 1)
            return Color.interpolate(from: .blue, to: .pink, ratio: ratio)
        }
    }
}

// MARK: - Color Interpolation Extension

extension Color {
    /// Smoothly interpolate between two colors using HSB color space
    static func interpolate(from: Color, to: Color, ratio: Double) -> Color {
        // Convert to UIColor for component extraction
        let fromUI = UIColor(from)
        let toUI = UIColor(to)
        
        var fromH: CGFloat = 0, fromS: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toH: CGFloat = 0, toS: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0
        
        fromUI.getHue(&fromH, saturation: &fromS, brightness: &fromB, alpha: &fromA)
        toUI.getHue(&toH, saturation: &toS, brightness: &toB, alpha: &toA)
        
        // Interpolate each component
        let interpRatio = CGFloat(ratio)
        let h = fromH + (toH - fromH) * interpRatio
        let s = fromS + (toS - fromS) * interpRatio
        let b = fromB + (toB - fromB) * interpRatio
        let a = fromA + (toA - fromA) * interpRatio
        
        return Color(hue: Double(h), saturation: Double(s), brightness: Double(b), opacity: Double(a))
    }
}

struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
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
                // Deep dark background for contrast
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black.opacity(0.85))
                
                // Material layer on top
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                
                // Subtle gradient highlight
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

#Preview {
    ZStack {
        Color.black
        UnlockedLandmarkOverlay(name: "Eiffel Tower")
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
        }
    )
}

