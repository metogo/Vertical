import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct LandmarkCollectionFeature {
    @ObservableState
    struct State: Equatable {
        var landmarks: [Landmark] = []
        var unlockedLandmarkIds: Set<UUID> = []
        var isLoading: Bool = false
        var selectedLandmark: Landmark?
    }
    
    enum Action {
        case onAppear
        case landmarksResponse([Landmark])
        case unlockedIdsResponse(Set<UUID>)
        case selectLandmark(Landmark)
        case dismissDetail
        case shareLandmark(Landmark)
    }
    
    @Dependency(\.landmarkClient) var landmarkClient
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.shareClient) var shareClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .run { send in
                        do {
                            let landmarks = try await landmarkClient.loadLandmarks()
                            await send(.landmarksResponse(landmarks))
                        } catch {}
                    },
                    .run { send in
                        if let ids = try? await databaseClient.fetchUnlockedLandmarkIds() {
                            await send(.unlockedIdsResponse(ids))
                        }
                    }
                )
                
            case let .landmarksResponse(landmarks):
                state.landmarks = landmarks
                state.isLoading = false
                return .none
                
            case let .unlockedIdsResponse(ids):
                state.unlockedLandmarkIds = ids
                return .none
                
            case let .selectLandmark(landmark):
                // Only allow selecting unlocked landmarks for now
                if state.unlockedLandmarkIds.contains(landmark.id) {
                    state.selectedLandmark = landmark
                }
                return .none
                
            case .dismissDetail:
                state.selectedLandmark = nil
                return .none
                
            case let .shareLandmark(landmark):
                return .run { send in
                    let view = CinematicCardView(
                        totalClimb: landmark.height,
                        landmarkName: landmark.name,
                        readingsCount: 0,
                        isAMPKActivated: false,
                        mitochondrialIndex: 0,
                        rerEstimation: 0.85,
                        autophagyDepth: 0
                    )
                    
                    let renderer = ImageRenderer(content: view)
                    renderer.scale = 3.0
                    if let image = renderer.uiImage {
                        await shareClient.shareImage(image)
                    }
                }
            }
        }
    }
}
