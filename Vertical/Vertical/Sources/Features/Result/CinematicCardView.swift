import SwiftUI

struct CinematicCardView: View {
    let totalClimb: Double
    let landmarkName: String?
    let readingsCount: Int
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo / Branding
            HStack {
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.title)
                    .foregroundStyle(.pink)
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
                    .stroke(LinearGradient(colors: [.blue.opacity(0.2), .pink.opacity(0.1)], startPoint: .top, endPoint: .bottom), lineWidth: 40)
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", totalClimb))
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("METERS CLIMBED")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.secondary)
                        .kerning(2)
                }
            }
            .padding(.vertical, 40)
            
            // Achievement
            if let landmark = landmarkName {
                VStack(spacing: 8) {
                    Text("GOAL REACHED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.pink)
                        .kerning(4)
                    
                    Text(LocalizedStringKey(landmark))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
                        .italic()
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
            }
            
            // Footer Stats
            HStack(spacing: 40) {
                VStack(alignment: .leading) {
                    Text("TYPE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.secondary)
                    Text(LocalizedStringKey("Vertical Sprint"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading) {
                    Text("READINGS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.secondary)
                    Text("\(readingsCount)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
        }
        .padding(32)
        .frame(width: 400, height: 600)
        .background(
            ZStack {
                Color.black
                RadialGradient(
                    colors: [.blue.opacity(0.2), .black],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 500
                )
                RadialGradient(
                    colors: [.pink.opacity(0.15), .black],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: 400
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

#Preview {
    CinematicCardView(totalClimb: 330, landmarkName: "Eiffel Tower", readingsCount: 1205)
        .padding()
        .background(Color.gray)
}
