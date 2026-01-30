import ComposableArchitecture
import SwiftUI

struct LandmarkCollectionView: View {
    let store: StoreOf<LandmarkCollectionFeature>
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        @Bindable var store = store
        return NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(store.landmarks) { landmark in
                        LandmarkGridCell(
                            landmark: landmark,
                            isUnlocked: store.unlockedLandmarkIds.contains(landmark.id)
                        )
                        .onTapGesture {
                            store.send(.selectLandmark(landmark))
                        }
                    }
                }
                .padding()
            }
            .sheet(item: Binding(
                get: { store.selectedLandmark },
                set: { _ in store.send(.dismissDetail) }
            )) { landmark in
                LandmarkDetailView(landmark: landmark)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShareLandmark"))) { obj in
                        if let landmark = obj.object as? Landmark {
                            store.send(.shareLandmark(landmark))
                        }
                    }
            }
            .background(
                ZStack {
                    Color.black.ignoresSafeArea()
                    RadialGradient(
                        colors: [.cyan.opacity(0.08), .clear],
                        center: .top,
                        startRadius: 0,
                        endRadius: 600
                    )
                    .ignoresSafeArea()
                }
            )
            .navigationTitle(String(localized: "LANDMARKS"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

struct LandmarkGridCell: View {
    let landmark: Landmark
    let isUnlocked: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Architectural Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("REF: \(landmark.id.uuidString.prefix(8).uppercased())")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.3))
                    
                    Text(LocalizedStringKey(landmark.name))
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(isUnlocked ? .white : .white.opacity(0.4))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if !isUnlocked {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Schematic Area
            ZStack {
                // Background Grid Logic
                GridPattern(spacing: 12)
                    .stroke(isUnlocked ? Color.cyan.opacity(0.1) : Color.white.opacity(0.02), lineWidth: 0.5)
                
                // Vertical Scale Indicator
                HStack {
                    VStack(spacing: 4) {
                        ForEach(0..<4) { i in
                            Rectangle()
                                .fill(isUnlocked ? Color.cyan.opacity(0.3) : Color.white.opacity(0.05))
                                .frame(width: 4, height: 1)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.leading, 8)
                .padding(.vertical, 10)
                
                // The Visual Representation
                VStack(spacing: 0) {
                    Spacer()
                    Image(systemName: landmark.systemImage)
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(isUnlocked ? .cyan : .white.opacity(0.1))
                    
                    if isUnlocked {
                        // Holographic "Base" Glow
                        Ellipse()
                            .fill(RadialGradient(colors: [.cyan.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 30))
                            .frame(width: 60, height: 10)
                            .blur(radius: 5)
                            .offset(y: 5)
                    }
                    Spacer()
                }
            }
            .frame(height: 100)
            .background(isUnlocked ? Color.cyan.opacity(0.03) : Color.white.opacity(0.01))
            .cornerRadius(12)
            .padding(.horizontal, 8)

            // Technical Footer
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ELEVATION")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                        .kerning(1)
                    Text("\(Int(landmark.height))m")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(isUnlocked ? .cyan : .white.opacity(0.4))
                }
                
                Spacer()
                
                if isUnlocked {
                    Circle()
                        .fill(.cyan)
                        .frame(width: 4, height: 4)
                        .shadow(color: .cyan, radius: 4)
                        .padding(.bottom, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(isUnlocked ? Color.white.opacity(0.05) : Color.white.opacity(0.02))
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: isUnlocked ? [.cyan.opacity(0.4), .cyan.opacity(0.1)] : [.white.opacity(0.1), .white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .contentShape(RoundedRectangle(cornerRadius: 24))
    }
}

private struct GridPattern: Shape {
    let spacing: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, through: rect.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, through: rect.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

#Preview {
    LandmarkCollectionView(
        store: Store(initialState: LandmarkCollectionFeature.State()) {
            LandmarkCollectionFeature()
        } withDependencies: {
            $0.landmarkClient = .testValue
            $0.databaseClient = .previewValue
        }
    )
}
