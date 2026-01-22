import ComposableArchitecture
import XCTest
@testable import Vertical

@MainActor
final class SmokeTests: XCTestCase {
    func testFullUserJourney() async throws {
        // --- 1. SETUP ---
        let (altitudeStream, continuation) = AsyncStream<SensorReading>.makeStream()
        
        // Mock dependencies
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.userDefaults.boolForKey = { _ in false } // Not agreed yet
            $0.userDefaults.setBool = { _, _ in }
            $0.landmarkClient.loadLandmarks = { Landmark.samples }
            $0.sensorClient.altitudeStream = { altitudeStream }
            $0.locationClient.startMonitoring = {}
            $0.locationClient.stopMonitoring = {}
            $0.databaseClient.save = { _, _ in }
            $0.databaseClient.saveSession = { _ in }
            $0.sync.sync = {}
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        
        // --- 2. ONBOARDING ---
        await store.send(.view(.onAppear))
        
        await store.receive(\.internal.showOnboarding) {
            $0.onboarding = OnboardingFeature.State()
        }
        
        await store.send(.onboarding(.presented(.view(.scrolledToBottom)))) {
            $0.onboarding?.isAgreeEnabled = true
        }
        
        await store.send(.onboarding(.presented(.view(.agreeButtonTapped))))
        await store.receive(\.onboarding.presented.internal.savedChoice) {
            $0.onboarding = nil
        }
        
        // --- 3. TRACKING ---
        await store.send(.tracker(.view(.startButtonTapped))) {
            $0.tracker.isTracking = true
            $0.tracker.currentSessionId = "00000000-0000-0000-0000-000000000000"
        }
        
        // Simulate climbing
        let now = Date()
        let reading1 = SensorReading(timestamp: now, pressure: 101.3, relativeAltitude: 10.0)
        let reading2 = SensorReading(timestamp: now.addingTimeInterval(2), pressure: 101.2, relativeAltitude: 15.0)
        
        continuation.yield(reading1)
        await store.receive(\.tracker.internal.altitudeReceived, reading1)
        
        continuation.yield(reading2)
        await store.receive(\.tracker.internal.altitudeReceived, reading2) {
            $0.tracker.currentAltitude = 15.0
            $0.tracker.totalClimb = 5.0
            $0.tracker.sessionReadingsCount = 2
        }
        
        // --- 4. STOP & RESULT ---
        await store.send(.tracker(.view(.stopButtonTapped))) {
            $0.result = ResultFeature.State(sessionId: "00000000-0000-0000-0000-000000000000")
            $0.tracker.isTracking = false
        }
        
        // --- 5. CLEANUP ---
        // Ensure sync was triggered
        await store.receive(\.internal.syncFinished)
    }
}
