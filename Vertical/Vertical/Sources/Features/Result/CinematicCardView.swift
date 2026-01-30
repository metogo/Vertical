import SwiftUI

struct CinematicCardView: View {
    let totalClimb: Double
    let landmarkName: String?
    let readingsCount: Int
    let isAMPKActivated: Bool
    let mitochondrialIndex: Double
    let rerEstimation: Double
    let autophagyDepth: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Branding
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("VERTICAL")
                        .font(.system(size: 20, weight: .black))
                        .italic()
                        .foregroundStyle(.white)
                    Text("BIO-FEEDBACK REPORT")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.cyan.opacity(0.8))
                        .kerning(2)
                }
                Spacer()
                Image(systemName: "square.grid.3x3.topleft.filled")
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(24)
            
            // Central Visual: The "Core"
            ZStack {
                // Background Glow Layers
                Circle()
                    .fill(isAMPKActivated ? Color.orange.opacity(0.2) : Color.cyan.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                
                // Spiral Mesh Placeholder (2D representation of the 3D path)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 120))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [isAMPKActivated ? .orange : .cyan, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.3)
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", totalClimb))
                        .font(.system(size: 84, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: isAMPKActivated ? .orange : .cyan, radius: 20)
                    
                    Text("METERS CLIMBED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.white.opacity(0.4))
                        .kerning(4)
                }
            }
            .padding(.vertical, 40)
            
            // Achievement Section
            if let landmark = landmarkName {
                VStack(spacing: 8) {
                    Text("GOAL REACHED")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(isAMPKActivated ? .orange : .cyan)
                        .kerning(6)
                    
                    Text(landmark.uppercased())
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .italic()
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.05))
                .overlay(Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
            }
            
            // Metabolic Matrix
            HStack(spacing: 1) {
                CardStatMetric(label: "MITO", value: String(format: "%.1f", mitochondrialIndex), unit: "min", color: .green)
                CardStatMetric(label: "RER", value: String(format: "%.2f", rerEstimation), unit: "", color: .blue)
                CardStatMetric(label: "AUTO", value: String(format: "%.1f", autophagyDepth), unit: "pts", color: .purple)
            }
            .padding(.top, 24)
            
            Spacer()
            
            // Metabolic Badge
            if isAMPKActivated {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                    Text("AMPK METABOLIC MODE ACTIVE")
                        .font(.system(size: 9, weight: .black))
                        .kerning(1)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 24)
                .background(Capsule().fill(Color.orange))
                .foregroundStyle(.black)
                .padding(.bottom, 24)
            }
            
            // Footer
            HStack {
                VStack(alignment: .leading) {
                    Text("DATA SOURCE: HEALTHKIT")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                    Text(Date().formatted(date: .long, time: .shortened))
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.white.opacity(0.2))
                }
                Spacer()
                Text("#VERTICAL_CLIMB")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(24)
        }
        .frame(width: 400, height: 700)
        .background(
            ZStack {
                Color.black
                RadialGradient(colors: [isAMPKActivated ? .orange.opacity(0.1) : .cyan.opacity(0.1), .clear], center: .topLeading, startRadius: 0, endRadius: 300)
                RadialGradient(colors: [isAMPKActivated ? .yellow.opacity(0.05) : .purple.opacity(0.05), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 400)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct CardStatMetric: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundStyle(.white.opacity(0.4))
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(color)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CinematicCardView(
        totalClimb: 330, 
        landmarkName: "Eiffel Tower", 
        readingsCount: 1205, 
        isAMPKActivated: true,
        mitochondrialIndex: 4.2,
        rerEstimation: 0.72,
        autophagyDepth: 12.5
    )
}
