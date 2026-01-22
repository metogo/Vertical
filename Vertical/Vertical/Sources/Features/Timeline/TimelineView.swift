import ComposableArchitecture
import SwiftUI

struct TimelineView: View {
    let store: StoreOf<TimelineFeature>
    
    private let config = TimelineConfiguration.self
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack(alignment: .trailing) {
                // The Spire Spine - A continuous vertical glowing line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.1), .cyan, .cyan.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1.5)
                    .glow(color: .cyan.opacity(0.5), radius: 4)
                    .padding(.trailing, 0) // Align to the very edge of the scale
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        ZStack(alignment: .trailing) {
                            // Optimized Scale - only render ticks at intervals
                            OptimizedRulerContent()
                            
                            // Landmarks with pre-computed positions
                            LandmarkLayer(landmarkPositions: store.landmarkPositions)
                            
                            // Current Altitude Indicator on the scale
                            CurrentAltitudeRulerMarker(altitude: store.currentAltitude)
                                .id("indicator")
                        }
                        .padding(.trailing, 1)
                        .padding(.vertical, screenHeight / 2)
                    }
                    .onAppear {
                        // Initial scroll to bottom (0m) on appear
                        proxy.scrollTo(0, anchor: .center)
                    }
                    .onChange(of: store.currentAltitude) { oldValue, newValue in
                        if store.isAutoFollowEnabled {
                            // Target the nearest major/minor tick to help ScrollView find the region
                            let nearestTick = Int(newValue / 10) * 10
                            
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                // First try to scroll to the exact indicator, fallback to nearest tick
                                proxy.scrollTo("indicator", anchor: .center)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("timeline_scroll_view")
                .frame(width: 80) // Constrain width to the edge
                
                // Auto-follow toggle button
                AutoFollowButton(isEnabled: store.isAutoFollowEnabled) {
                    store.send(.toggleAutoFollow)
                }
                .accessibilityIdentifier("auto_follow_button")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - Current Altitude Ruler Marker
private struct CurrentAltitudeRulerMarker: View {
    let altitude: Double
    private let config = TimelineConfiguration.self
    
    var body: some View {
        HStack(spacing: 0) {
            // Glowing Pointer
            Image(systemName: "arrowtriangle.left.fill")
                .font(.system(size: 10))
                .foregroundStyle(.white)
                .shadow(color: .cyan, radius: 5)
                .offset(x: 5)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white, .white.opacity(0)],
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                )
                .frame(width: 40, height: 2)
                .glow(color: .cyan, radius: 4)
        }
        .offset(y: CGFloat(config.maxAltitude - altitude) * config.pixelsPerMeter)
        .id("indicator")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Ensure initial alignment on load
            }
        }
    }
}

// MARK: - Optimized Ruler Content

private struct OptimizedRulerContent: View {
    private let config = TimelineConfiguration.self
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(tickValues, id: \.self) { altitude in
                RulerTick(altitude: altitude, isMajor: altitude % config.majorTickInterval == 0)
                    .frame(height: config.pixelsPerMeter * CGFloat(config.minorTickInterval))
                    .id(altitude)
            }
        }
    }
    
    private var tickValues: [Int] {
        Array(stride(from: Int(config.maxAltitude), through: 0, by: -config.minorTickInterval))
    }
}

private struct RulerTick: View {
    let altitude: Int
    let isMajor: Bool
    
    var body: some View {
        HStack(spacing: 4) { // Reduced spacing
            if isMajor {
                Text("\(altitude)")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.8), radius: 3)
                    .frame(width: 40, alignment: .trailing)
                
                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: 12, height: 1.5) // Slightly shorter major ticks
                    .glow(color: .cyan.opacity(0.5), radius: 2)
            } else {
                Spacer()
                Rectangle()
                    .fill(Color.cyan.opacity(0.3))
                    .frame(width: 6, height: 1)
            }
        }
        .padding(.trailing, 2)
    }
}

// MARK: - Landmark Layer

private struct LandmarkLayer: View {
    let landmarkPositions: [TimelineFeature.LandmarkPosition]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            ForEach(landmarkPositions) { position in
                LandmarkBadge(landmark: position.landmark)
                    .offset(y: position.offsetY)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 90) // Add extra trailing padding to avoid the Vertical Axis
                    .accessibilityIdentifier("landmark_\(position.landmark.name.lowercased().replacingOccurrences(of: " ", with: "_"))")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LandmarkBadge: View {
    let landmark: Landmark
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing, spacing: 1) {
                Text(LocalizedStringKey(landmark.name))
                    .font(.system(size: 10, weight: .black))
                    .textCase(.uppercase)
                    .foregroundStyle(.white)
                
                Text("\(Int(landmark.height))m")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.cyan)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                }
            )
            .shadow(color: .black.opacity(0.3), radius: 4)
            
            // Connecting line to scale
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.cyan.opacity(0.8), .cyan.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 18, height: 1.5)
        }
    }
}

// MARK: - Helper View Modifiers
extension View {
    func glow(color: Color, radius: CGFloat) -> some View {
        self
            .shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius / 2)
    }
}

// MARK: - Current Altitude Marker

private struct CurrentAltitudeMarker: View {
    let altitude: Double
    
    var body: some View {
        HStack(spacing: 0) {
            // Altitude Display
            VStack(alignment: .trailing, spacing: -2) {
                Text("\(Int(altitude))")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.6), radius: 8)
                Text("METERS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
                    .tracking(2)
            }
            
            // Horizontal indicator line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.cyan, .cyan.opacity(0)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 80, height: 2)
                .offset(x: 8)
        }
    }
}

// MARK: - Auto-Follow Button

private struct AutoFollowButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: isEnabled ? "location.fill" : "location")
                        .font(.headline)
                        .foregroundColor(isEnabled ? .blue : .white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.6)))
                }
                .padding(.trailing, 20)
                .padding(.bottom, 250)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TimelineView(
        store: Store(initialState: TimelineFeature.State(currentAltitude: 330)) {
            TimelineFeature()
        }
    )
}
