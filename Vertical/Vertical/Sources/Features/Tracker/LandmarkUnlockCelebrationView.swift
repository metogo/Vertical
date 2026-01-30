import SwiftUI

struct LandmarkUnlockCelebrationView: View {
    let landmark: Landmark
    
    @State private var showContent = false
    @State private var rotateLogo = 0.0
    
    var body: some View {
        ZStack {
            // Dark Blur Background
            Rectangle()
                .fill(.ultraThinMaterial)
                .colorScheme(.dark)
                .ignoresSafeArea()
            
            // Background Glow
            Circle()
                .fill(RadialGradient(colors: [.cyan.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 300))
                .scaleEffect(showContent ? 1.5 : 0.5)
                .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 40) {
                // Celebration Title
                VStack(spacing: 8) {
                    Text("NEW ACHIEVEMENT")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.cyan)
                        .kerning(4)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("LANDMARK UNLOCKED")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                
                // Central Icon / Trophy
                ZStack {
                    Circle()
                        .stroke(lineWidth: 1)
                        .fill(LinearGradient(colors: [.cyan, .clear], startPoint: .top, endPoint: .bottom))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.init(degrees: rotateLogo))
                    
                    Image(systemName: landmark.systemImage)
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .shadow(color: .cyan, radius: 20)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                
                // Landmark Info
                VStack(spacing: 12) {
                    Text(landmark.name.uppercased())
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up")
                        Text("\(Int(landmark.height))m")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotateLogo = 360
            }
        }
    }
}

#Preview {
    LandmarkUnlockCelebrationView(landmark: Landmark.samples[2])
}
