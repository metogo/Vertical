import SwiftUI

struct MetabolicAvatarView: View {
    let intensity: Double // HRR% (0.0 to 1.0)
    let isAMPKActivated: Bool
    
    var body: some View {
        ZStack {
            // 1. Premium Dark Ambient Background
            ambientBackground
            
            // 2. Full-Bleed Bio-kinetic Waves
            KineticWaveView(intensity: intensity, isAMPK: isAMPKActivated)
            
            // 3. Central Metabolic Soul (Siri-style orb)
            metabolicOrb
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Premium Ambient Background
    private var ambientBackground: some View {
        ZStack {
            Color.black
            
            // Subtle radial glow centered on the orb
            RadialGradient(
                colors: [
                    coreColor.opacity(0.2),
                    coreColor.opacity(0.05),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
        }
    }
    
    // MARK: - Central Metabolic Orb (Siri-style)
    private var metabolicOrb: some View {
        ZStack {
            // Outer Glow Ring
            Circle()
                .stroke(coreColor.opacity(0.3), lineWidth: 2)
                .frame(width: 70, height: 70)
                .blur(radius: 4)
            
            // Mid Glow
            Circle()
                .fill(coreColor.opacity(0.15))
                .frame(width: 50, height: 50)
                .blur(radius: 15)
            
            // Inner Core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [coreColor, coreColor.opacity(0.4)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 22, height: 22)
                .shadow(color: coreColor, radius: 8)
        }
    }
    
    private var coreColor: Color {
        isAMPKActivated ? .orange : .cyan
    }
}

// MARK: - Kinetic Wave Visualization
struct KineticWaveView: View {
    let intensity: Double
    let isAMPK: Bool
    
    var body: some View {
        SwiftUI.TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                drawWaves(in: &context, size: size, time: time)
            }
        }
    }
    
    private func drawWaves(in context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let baseSpeed = 1.2 + (intensity * 1.5)
        let baseAmplitude = 15.0 + (intensity * 30.0)
        let midY = size.height / 2
        let waveCount = 4
        
        for i in 0..<waveCount {
            let index = Double(i)
            let speed = baseSpeed * (1.0 + index * 0.15)
            let amplitude = baseAmplitude * (1.0 - index * 0.2)
            let frequency = 0.008 + (index * 0.003)
            let phaseOffset = index * 0.5
            
            let path = createSmoothWavePath(
                size: size,
                midY: midY,
                time: time,
                speed: speed,
                amplitude: amplitude,
                frequency: frequency,
                phaseOffset: phaseOffset
            )
            
            // Apple-style gradient: primary color fading to transparent
            let opacity = 0.6 - (index * 0.12)
            let primaryColor = isAMPK ? Color.orange : Color.cyan
            let secondaryColor = isAMPK ? Color.red.opacity(0.3) : Color.blue.opacity(0.3)
            
            let lineWidth = 2.0 - (index * 0.3)
            
            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        primaryColor.opacity(opacity),
                        secondaryColor.opacity(opacity * 0.5)
                    ]),
                    startPoint: CGPoint(x: 0, y: midY),
                    endPoint: CGPoint(x: size.width, y: midY)
                ),
                lineWidth: CGFloat(lineWidth)
            )
        }
    }
    
    private func createSmoothWavePath(
        size: CGSize,
        midY: CGFloat,
        time: TimeInterval,
        speed: Double,
        amplitude: Double,
        frequency: Double,
        phaseOffset: Double
    ) -> Path {
        var path = Path()
        let startX: CGFloat = 0
        path.move(to: CGPoint(x: startX, y: midY))
        
        // Use smaller step for smoother curves
        let step: CGFloat = 3
        for x in stride(from: startX, through: size.width, by: step) {
            let relativeX = Double(x) / Double(size.width)
            
            // Multi-harmonic wave for organic feel
            let wave1 = sin(Double(x) * frequency + time * speed + phaseOffset)
            let wave2 = sin(Double(x) * frequency * 1.8 - time * speed * 0.6 + phaseOffset) * 0.25
            
            // Edge fade-out (smooth envelope)
            let envelope = sin(relativeX * .pi)
            
            let y = midY + CGFloat((wave1 + wave2) * amplitude * envelope)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        MetabolicAvatarView(intensity: 0.7, isAMPKActivated: true)
            .frame(height: 200)
        
        MetabolicAvatarView(intensity: 0.3, isAMPKActivated: false)
            .frame(height: 200)
    }
    .padding()
    .background(Color.black)
}
