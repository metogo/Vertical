import SwiftUI

struct CinematicCardView: View {
    let totalClimb: Double
    let landmarkName: String?
    let readingsCount: Int
    let isAMPKActivated: Bool
    let mitochondrialIndex: Double
    let rerEstimation: Double
    let autophagyDepth: Double
    
    init(totalClimb: Double, landmarkName: String?, readingsCount: Int, isAMPKActivated: Bool, mitochondrialIndex: Double = 0.0, rerEstimation: Double = 0.85, autophagyDepth: Double = 0.0) {
        self.totalClimb = totalClimb
        self.landmarkName = landmarkName
        self.readingsCount = readingsCount
        self.isAMPKActivated = isAMPKActivated
        self.mitochondrialIndex = mitochondrialIndex
        self.rerEstimation = rerEstimation
        self.autophagyDepth = autophagyDepth
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo / Branding
            HStack {
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.title)
                    .foregroundStyle(isAMPKActivated ? .orange : .pink)
                Text("VERTICAL")
                    .font(.system(size: 24, weight: .black))
                    .italic()
                    .foregroundStyle(.white)
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            // Central Visual - Minimalist Spiral representation (2D for card)
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                (isAMPKActivated ? Color.orange : Color.blue).opacity(0.2), 
                                (isAMPKActivated ? Color.yellow : Color.pink).opacity(0.1)
                            ], 
                            startPoint: .top, 
                            endPoint: .bottom
                        ), 
                        lineWidth: 40
                    )
                    .frame(width: 180, height: 180)
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", totalClimb))
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("METERS_CLIMBED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.secondary)
                        .kerning(2)
                }
            }
            .padding(.vertical, 20)
            
            // Achievement
            if let landmark = landmarkName {
                VStack(spacing: 4) {
                    Text("GOAL_REACHED")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(isAMPKActivated ? .yellow : .pink)
                        .kerning(4)
                    
                    Text(LocalizedStringKey(landmark))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
                        .italic()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
            }
            
            // Metabolic Activation Badge
            if isAMPKActivated {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                    Text("AMPK_ACTIVATED")
                        .font(.system(size: 11, weight: .black))
                        .kerning(2)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundStyle(.black)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                )
                .shadow(color: .orange.opacity(0.6), radius: 15)
            }
            
            // Metabolic Summary Table (New for MetaVision)
            HStack(spacing: 20) {
                CardStatView(label: "MITO", value: String(format: "%.1f", mitochondrialIndex), icon: "microbe.fill", color: .green)
                CardStatView(label: "RER", value: String(format: "%.2f", rerEstimation), icon: "lungs.fill", color: .blue)
                CardStatView(label: "AUTO", value: String(format: "%.1f", autophagyDepth), icon: "leaf.fill", color: .purple)
            }
            .padding(16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
            
            Spacer()
            
            // Footer Branding
            HStack {
                Text("METAVISION_BIOFEEDBACK")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(.white.opacity(0.3))
                    .kerning(1)
                Spacer()
                Text("#AMPK_ACTIVATION")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(32)
        .frame(width: 400, height: 600)
        .background(
            ZStack {
                Color.black
                RadialGradient(
                    colors: [isAMPKActivated ? .orange.opacity(0.25) : .blue.opacity(0.2), .black],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 500
                )
                RadialGradient(
                    colors: [isAMPKActivated ? .yellow.opacity(0.15) : .pink.opacity(0.15), .black],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: 400
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(isAMPKActivated ? Color.orange.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

private struct CardStatView: View {
    let label: LocalizedStringKey
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.secondary)
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
    .padding()
    .background(Color.gray)
}
