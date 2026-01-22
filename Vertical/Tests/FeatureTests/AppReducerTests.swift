import ComposableArchitecture
import XCTest
@testable import Vertical

@MainActor
final class AppReducerTests: XCTestCase {
    func testAltitudeUpdate() async {
        // Create an immediate stream for testing stability
        let (stream, continuation) = AsyncStream<SensorReading>.makeStream()
        
        let store = TestStore(initialState: AppReducer.State()) {
            AppReducer()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { stream }
        }
        
        // App launches
        await store.send(.view(.onAppear)) {
            $0.appLaunchCount = 1
        }
        
        // Start tracking
        let task = await store.send(.view(.task))
        
        // Yield values manually from continuation
        let reading0 = SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 0.0)
        continuation.yield(reading0)
        
        await store.receive(\.internal.altitudeResponse, reading0) {
            $0.currentAltitude = 0.0
            $0.currentPressure = 101.3
        }
        
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: 1.5)
        continuation.yield(reading1)
        
        await store.receive(\.internal.altitudeResponse, reading1) {
            $0.currentAltitude = 1.5
            $0.currentPressure = 101.2
        }
        
        // Clean up
        continuation.finish()
        await task.cancel()
    }
}
