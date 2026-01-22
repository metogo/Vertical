import ComposableArchitecture
import XCTest
@testable import Vertical

@MainActor
final class TimelineFeatureTests: XCTestCase {
    func testSetAltitude() async {
        let store = TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        }
        
        await store.send(.setAltitude(100.0)) {
            $0.currentAltitude = 100.0
        }
    }
    
    func testToggleAutoFollow() async {
        let store = TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        }
        
        await store.send(.toggleAutoFollow) {
            $0.isAutoFollowEnabled = false
        }
        
        await store.send(.toggleAutoFollow) {
            $0.isAutoFollowEnabled = true
        }
    }
    
    func testLandmarkPositionsPrecomputed() {
        let state = TimelineFeature.State()
        
        // Verify that landmark positions are correctly pre-computed
        XCTAssertEqual(state.landmarkPositions.count, Landmark.samples.count)
        
        // Verify the Eiffel Tower position (height 330m)
        let eiffelPosition = state.landmarkPositions.first { $0.landmark.name == "Eiffel Tower" }
        XCTAssertNotNil(eiffelPosition)
        
        // Expected offset: (6000 - 330) * 20 = 113400
        let expectedOffset = (TimelineConfiguration.maxAltitude - 330) * Double(TimelineConfiguration.pixelsPerMeter)
        XCTAssertEqual(eiffelPosition?.offsetY, expectedOffset)
    }
}

@MainActor
final class AppSyncTests: XCTestCase {
    func testAltitudeSyncFromTrackerToTimeline() async {
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        }
        
        let reading = SensorReading(timestamp: Date(), pressure: 101.3, relativeAltitude: 50.0)
        
        store.exhaustivity = .off
        
        await store.send(.tracker(.internal(.altitudeReceived(reading))))
        
        await store.receive(.timeline(.setAltitude(50.0))) {
            $0.timeline.currentAltitude = 50.0
        }
    }
}

final class TimelineConfigurationTests: XCTestCase {
    func testConfigurationValues() {
        // Verify configuration values are sensible
        XCTAssertEqual(TimelineConfiguration.pixelsPerMeter, 20)
        XCTAssertEqual(TimelineConfiguration.maxAltitude, 6000)
        XCTAssertEqual(TimelineConfiguration.majorTickInterval, 100)
        XCTAssertEqual(TimelineConfiguration.minorTickInterval, 10)
        
        // Verify tick count is reasonable (should be ~600, not 6000)
        let tickCount = Int(TimelineConfiguration.maxAltitude) / TimelineConfiguration.minorTickInterval + 1
        XCTAssertEqual(tickCount, 601)
    }
}
