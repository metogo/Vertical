import SwiftUI

struct AchievementInfographicView: View {
    let totalClimb: Double
    let landmarks: [Landmark]
    
    // UI Theme - Precision Mockup Palette
    private let neonCyan = Color(red: 0.1, green: 0.9, blue: 1.0)
    private let neonPink = Color(red: 1.0, green: 0.2, blue: 0.5)
    private let cyberNavy = Color(red: 0.02, green: 0.03, blue: 0.1)
    
    // Calculate the scale based on progress
    private var maxScaleHeight: Double {
        let reached = landmarks.last(where: { $0.height <= totalClimb }) ?? landmarks[0]
        let nextTarget = landmarks.first(where: { $0.height > totalClimb }) ?? reached
        // Add 20% visual buffer on top ensuring image fits
        return max(totalClimb * 1.3, nextTarget.height * 1.35)
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Increase top padding to prevent "head cutting" of high landmarks
            let botPadding: CGFloat = 80
            let topPadding: CGFloat = 80
            let plotArea = geometry.size.height - (botPadding + topPadding)
            
            ZStack(alignment: .bottom) {
                // 1. Digital Background Lab
                cyberNavy.ignoresSafeArea()
                digitalGrid(size: geometry.size)
                
                HStack(spacing: 0) {
                    // 2. High-Precision Command Ruler
                    commandRuler(height: plotArea)
                        .frame(width: 60)
                        .padding(.bottom, botPadding)
                    
                    ZStack(alignment: .bottom) {
                        // 3. Procedural Holographic Buildings
                        holographicStage(size: CGSize(width: geometry.size.width - 80, height: plotArea))
                            .padding(.bottom, botPadding)
                        
                        // 4. Achievement Laser (Front Layer)
                        achievementLaser(width: geometry.size.width - 80, totalHeight: plotArea)
                            .padding(.bottom, botPadding)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // --- Grid System ---
    private func digitalGrid(size: CGSize) -> some View {
        Canvas { context, size in
            let spacing: CGFloat = 35
            for x in stride(from: 0, through: size.width, by: spacing) {
                context.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))}, with: .color(.white.opacity(0.04)), lineWidth: 0.5)
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                context.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y))}, with: .color(.white.opacity(0.04)), lineWidth: 0.5)
            }
        }
    }
    
    // --- Ruler System ---
    private func commandRuler(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            let steps = 10
            ForEach(0...steps, id: \.self) { i in
                let val = (maxScaleHeight / Double(steps)) * Double(steps - i)
                HStack(spacing: 6) {
                    Text("\(Int(val))m")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(neonCyan.opacity(0.6))
                    
                    Rectangle()
                        .fill(i % 5 == 0 ? neonCyan : neonCyan.opacity(0.25))
                        .frame(width: i % 5 == 0 ? 15 : 6, height: 1.5)
                        .shadow(color: i % 5 == 0 ? neonCyan : .clear, radius: 4)
                }
                if i < steps { Spacer() }
            }
        }
        .frame(height: height)
        .padding(.leading, 10)
    }
    
    // --- The Holographic Stage ---
    private func holographicStage(size: CGSize) -> some View {
        ZStack(alignment: .bottom) {
            // Filter to only show relevant range to avoid visual clutter
            let visibleLandmarks = landmarks.filter { $0.height <= maxScaleHeight * 1.15 }
            
            ForEach(Array(visibleLandmarks.enumerated()), id: \.element.id) { index, landmark in
                let progress = CGFloat(landmark.height / maxScaleHeight)
                let isReached = landmark.height <= totalClimb
                
                hologramBuilding(landmark: landmark, isReached: isReached)
                    .offset(y: -progress * size.height)
                    // Shift slightly left to leave room for the Right-side Tag
                    .offset(x: index % 2 == 0 ? -25 : 10)
            }
        }
    }
    
    private func hologramBuilding(landmark: Landmark, isReached: Bool) -> some View {
        VStack(spacing: 2) {
            // Data Tag
            HStack(spacing: 4) {
                Image(systemName: isReached ? "checkmark.circle.fill" : "circle.dotted")
                    .font(.system(size: 7))
                Text(landmark.name.uppercased())
                    .font(.system(size: 8, weight: .black))
                Text("\(Int(landmark.height))M")
                    .font(.system(size: 8, design: .monospaced))
            }
            .foregroundStyle(isReached ? neonCyan : .white.opacity(0.5))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(isReached ? neonCyan.opacity(0.1) : .clear)
            .overlay(RoundedRectangle(cornerRadius: 1).stroke(isReached ? neonCyan.opacity(0.5) : .white.opacity(0.2), lineWidth: 0.5))
            
            // Structural Visualization
            ZStack(alignment: .bottom) {
                 // Glow Floor
                 Ellipse()
                     .fill(RadialGradient(colors: [neonCyan.opacity(isReached ? 0.4 : 0.1), .clear], center: .center, startRadius: 0, endRadius: 30))
                     .frame(width: 80, height: 15)
                 
                 // The Asset Image
                 imageForLandmark(landmark.name)
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 100, height: 120)
                     .foregroundStyle(isReached ? neonCyan : .white.opacity(0.25))
                     .opacity(isReached ? 1.0 : 0.6)
                     .shadow(color: isReached ? neonCyan.opacity(0.6) : .clear, radius: 15)
                     .overlay(
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, neonCyan.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
                            .frame(height: 2)
                            .offset(y: 20)
                            .opacity(isReached ? 1.0 : 0.0)
                     )
            }
            .scaleEffect(isReached ? 1.0 : 0.9)
            .animation(.easeInOut(duration: 0.8), value: isReached)
        }
    }
    
    // --- Asset Mapping Logic ---
    private func imageForLandmark(_ name: String) -> Image {
        let n = name.lowercased()
        if n.contains("house") { return Image("HologramHouse") }
        if n.contains("tree") { return Image("HologramTree") }
        if n.contains("apartment") { return Image("HologramApartment") }
        if n.contains("liberty") { return Image("HologramLiberty") }
        if n.contains("pyramid") { return Image("HologramPyramid") }
        if n.contains("eiffel") { return Image("HologramEiffel") }
        if n.contains("empire") || n.contains("skyscraper") { return Image("HologramSkyscraper") }
        if n.contains("burj") { return Image("HologramSkyscraper") }
        if n.contains("everest") || n.contains("mountain") || n.contains("base camp") { return Image("HologramMountain") }
        
        return Image(systemName: "building.2")
    }
    
    // --- The Achievement Laser ---
    private func achievementLaser(width: CGFloat, totalHeight: CGFloat) -> some View {
        let progress = CGFloat(totalClimb / maxScaleHeight)
        
        return ZStack(alignment: .trailing) {
            // Horizontal Pulse Line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, neonPink, neonPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .shadow(color: neonPink, radius: 10)
            
            // Floating Data Plate
            HStack(spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(Int(totalClimb))m")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .italic()
                    
                    Text("CURRENT")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(neonPink)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.85))
                
                // Status Indicator
                Rectangle()
                    .fill(neonPink)
                    .frame(width: 4)
            }
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(neonPink.opacity(0.5), lineWidth: 1))
            .shadow(color: neonPink.opacity(0.3), radius: 15)
            .offset(y: -40)
            .padding(.trailing, 10)
            
            // Scanning Dot
            Circle()
                .fill(neonPink)
                .frame(width: 6, height: 6)
                .shadow(color: neonPink, radius: 10)
        }
        .frame(width: width, alignment: .trailing)
        .offset(y: -progress * totalHeight)
        .animation(.interpolatingSpring(stiffness: 40, damping: 10), value: totalClimb)
    }
}

#Preview {
    AchievementInfographicView(totalClimb: 12, landmarks: Landmark.samples)
        .preferredColorScheme(.dark)
}
