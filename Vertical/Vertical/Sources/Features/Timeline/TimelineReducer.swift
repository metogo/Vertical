import ComposableArchitecture
import Foundation

/// Configuration constants for the Timeline UI
enum TimelineConfiguration {
    static let pixelsPerMeter: CGFloat = 20
    static let maxAltitude: Double = 6000
    static let majorTickInterval: Int = 100  // Show label every 100m for performance
    static let minorTickInterval: Int = 10   // Show tick every 10m
}

@Reducer
struct TimelineFeature {
    @ObservableState
    struct State: Equatable {
        var currentAltitude: Double = 0.0
        var landmarks: [Landmark] = []
        var isAutoFollowEnabled: Bool = true
        
        /// Pre-computed landmark positions for efficient rendering
        var landmarkPositions: [LandmarkPosition] {
            landmarks.map { landmark in
                LandmarkPosition(
                    landmark: landmark,
                    offsetY: (TimelineConfiguration.maxAltitude - landmark.height) * Double(TimelineConfiguration.pixelsPerMeter)
                )
            }
        }
    }
    
    struct LandmarkPosition: Equatable, Identifiable {
        let landmark: Landmark
        let offsetY: Double
        var id: UUID { landmark.id }
    }
    
    enum Action {
        case setAltitude(Double)
        case toggleAutoFollow
        case setLandmarks([Landmark])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setAltitude(altitude):
                state.currentAltitude = altitude
                return .none
                
            case .toggleAutoFollow:
                state.isAutoFollowEnabled.toggle()
                return .none
                
            case let .setLandmarks(landmarks):
                state.landmarks = landmarks
                return .none
            }
        }
    }
}
