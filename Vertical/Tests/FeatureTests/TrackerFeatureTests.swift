import ComposableArchitecture
import CoreLocation
import XCTest
@testable import Vertical

// Simple helper for async expectations in tests
actor Requirement {
    var fulfilled = false
    var callCount = 0
    func fulfill() { fulfilled = true; callCount += 1 }
    func assert() { XCTAssertTrue(fulfilled) }
    func getCallCount() -> Int { callCount }
}

@MainActor
final class TrackerFeatureTests: XCTestCase {
    func testVAMCalculationSteadyClimb() async {
        let (stream, continuation) = AsyncStream<SensorReading>.makeStream()
        
        let startMonitoringCalled = Requirement()
        let stopMonitoringCalled = Requirement()
        let saveCounter = Requirement()
        
        let store = TestStore(initialState: TrackerFeature.State()) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { stream }
            $0.locationClient.startMonitoring = { await startMonitoringCalled.fulfill() }
            $0.locationClient.stopMonitoring = { await stopMonitoringCalled.fulfill() }
            $0.databaseClient.save = { _, _ in await saveCounter.fulfill() }
            $0.notificationClient.requestPermission = { true }
            $0.notificationClient.sendNotification = { _, _ in }
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        
        await store.send(.view(.startButtonTapped)) {
            $0.isTracking = true
            $0.currentSessionId = "00000000-0000-0000-0000-000000000000"
        }
        
        await startMonitoringCalled.assert()
        
        // Reading 0: t=0, alt=100
        let reading0 = SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 100.0)
        continuation.yield(reading0)
        await store.receive(\.internal.altitudeReceived, reading0) {
            $0.currentAltitude = 100.0
            $0.altitudeHistory = [reading0]
        }
        
        // Reading 1: t=2, alt=102
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.28, relativeAltitude: 102.0)
        continuation.yield(reading1)
        await store.receive(\.internal.altitudeReceived, reading1) {
            $0.currentAltitude = 102.0
            $0.altitudeHistory = [reading0, reading1]
        }
        
        // Reading 2: t=4, alt=104
        let reading2 = SensorReading(timestamp: Date(timeIntervalSince1970: 4), pressure: 101.26, relativeAltitude: 104.0)
        continuation.yield(reading2)
        await store.receive(\.internal.altitudeReceived, reading2) {
            $0.currentAltitude = 104.0
            $0.altitudeHistory = [reading0, reading1, reading2]
            $0.vam = 3600.0
        }
        
        await store.send(.view(.stopButtonTapped)) {
            $0.isTracking = false
            $0.vam = 0.0
            $0.currentSessionId = nil
        }
        
        await stopMonitoringCalled.assert()
        
        // Verify database save was called for each reading
        let saveCount = await saveCounter.getCallCount()
        XCTAssertEqual(saveCount, 3, "Database save should be called for each altitude reading")
    }
    
    func testAutoPauseDetection() async {
        let (stream, continuation) = AsyncStream<SensorReading>.makeStream()
        let notificationSent = Requirement()
        let saveCounter = Requirement()
        
        let store = TestStore(initialState: TrackerFeature.State()) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { stream }
            $0.locationClient.startMonitoring = {}
            $0.locationClient.stopMonitoring = {}
            $0.databaseClient.save = { _, _ in await saveCounter.fulfill() }
            $0.notificationClient.requestPermission = { true }
            $0.notificationClient.sendNotification = { _, _ in await notificationSent.fulfill() }
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        
        await store.send(.view(.startButtonTapped)) {
            $0.isTracking = true
            $0.currentSessionId = "00000000-0000-0000-0000-000000000000"
        }
        
        // Simulate elevator: speed above AutoPauseDetector.verticalSpeedThreshold (3 m/s)
        // Using exactly threshold + margin to test boundary
        let elevatorSpeed = AutoPauseDetector.verticalSpeedThreshold + 1.0 // 4 m/s
        let reading0 = SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 100.0)
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: 100.0 + elevatorSpeed)
        let reading2 = SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.1, relativeAltitude: 100.0 + elevatorSpeed * 2)
        
        continuation.yield(reading0)
        await store.receive(\.internal.altitudeReceived, reading0) {
            $0.currentAltitude = 100.0
            $0.altitudeHistory = [reading0]
        }
        
        continuation.yield(reading1)
        await store.receive(\.internal.altitudeReceived, reading1) {
            $0.currentAltitude = reading1.relativeAltitude
            $0.altitudeHistory = [reading0, reading1]
        }
        
        continuation.yield(reading2)
        await store.receive(\.internal.altitudeReceived, reading2) {
            $0.currentAltitude = reading2.relativeAltitude
            $0.altitudeHistory = [reading0, reading1, reading2]
        }
        
        // Should trigger auto-pause with the reading
        await store.receive(\.internal.autoPauseTriggered) {
            $0.isPaused = true
            $0.vam = 0.0
            $0.hasRequestedNotificationPermission = true
        }
        
        // Verify notification was sent
        await notificationSent.assert()
        
        // Verify all readings were saved (including the one that triggered pause)
        let saveCount = await saveCounter.getCallCount()
        XCTAssertEqual(saveCount, 3, "All readings including pause-triggering one should be saved")
    }
    
    func testResumeAfterAutoPause() async {
        var state = TrackerFeature.State()
        state.isTracking = true
        state.isPaused = true
        state.currentSessionId = "test-session"
        
        let store = TestStore(initialState: state) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { AsyncStream { _ in } }
            $0.locationClient.startMonitoring = {}
            $0.locationClient.stopMonitoring = {}
            $0.databaseClient.save = { _, _ in }
            $0.notificationClient.requestPermission = { true }
            $0.notificationClient.sendNotification = { _, _ in }
            $0.uuid = .incrementing
        }
        
        await store.send(.view(.resumeButtonTapped)) {
            $0.isPaused = false
            $0.altitudeHistory = []
        }
    }
    
    func testPermissionOnlyRequestedOnce() async {
        var state = TrackerFeature.State()
        state.isTracking = true
        state.hasRequestedNotificationPermission = true // Already requested
        
        let permissionRequested = Requirement()
        
        let reading = SensorReading(timestamp: Date(), pressure: 101.3, relativeAltitude: 100.0)
        
        let store = TestStore(initialState: state) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { AsyncStream { _ in } }
            $0.locationClient.startMonitoring = {}
            $0.locationClient.stopMonitoring = {}
            $0.databaseClient.save = { _, _ in }
            $0.notificationClient.requestPermission = { 
                await permissionRequested.fulfill()
                return true 
            }
            $0.notificationClient.sendNotification = { _, _ in }
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        
        await store.send(.internal(.autoPauseTriggered(reading: reading))) {
            $0.isPaused = true
            $0.vam = 0.0
        }
        
        // Permission should NOT be requested again since hasRequestedNotificationPermission is true
        let count = await permissionRequested.getCallCount()
        XCTAssertEqual(count, 0, "Permission should not be requested again")
    }
    
    func testHapticFeedbackClimb() async {
        let (stream, continuation) = AsyncStream<SensorReading>.makeStream()
        let hapticCalled = Requirement()
        
        let store = TestStore(initialState: TrackerFeature.State()) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { stream }
            $0.locationClient.startMonitoring = {}
            $0.locationClient.stopMonitoring = {}
            $0.databaseClient.save = { _, _ in }
            $0.hapticClient.impact = { _ in await hapticCalled.fulfill() }
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        
        await store.send(.view(.startButtonTapped))
        
        // Initial reading
        let reading0 = SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 0.0)
        continuation.yield(reading0)
        await store.receive(\.internal.altitudeReceived)
        
        // Climb 2.9m (no haptic yet)
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: 2.9)
        continuation.yield(reading1)
        await store.receive(\.internal.altitudeReceived)
        
        var count = await hapticCalled.getCallCount()
        XCTAssertEqual(count, 0)
        
        // Climb to 3.1m (should trigger haptic)
        let reading2 = SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.1, relativeAltitude: 3.1)
        continuation.yield(reading2)
        await store.receive(\.internal.altitudeReceived) {
            $0.lastHapticAltitude = 3.1
        }
        
        count = await hapticCalled.getCallCount()
        XCTAssertEqual(count, 1)
        
        // Climb another 3m (to 6.2m)
        let reading3 = SensorReading(timestamp: Date(timeIntervalSince1970: 3), pressure: 101.0, relativeAltitude: 6.2)
        continuation.yield(reading3)
        await store.receive(\.internal.altitudeReceived) {
            $0.lastHapticAltitude = 6.2
        }
        
        count = await hapticCalled.getCallCount()
        XCTAssertEqual(count, 2)
    }
    
    func testLandmarkHapticFeedback() async {
        let (stream, continuation) = AsyncStream<SensorReading>.makeStream()
        let landmarkHapticCalled = Requirement()
        
        let store = TestStore(initialState: TrackerFeature.State()) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { stream }
            $0.locationClient.startMonitoring = {}
            $0.locationClient.stopMonitoring = {}
            $0.databaseClient.save = { _, _ in }
            $0.hapticClient.notification = { _ in await landmarkHapticCalled.fulfill() }
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        
        await store.send(.view(.startButtonTapped))
        
        // Climb near Statue of Liberty (93m)
        let landmark = Landmark.samples.first { $0.name == "Statue of Liberty" }!
        
        let reading0 = SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: landmark.height - 1.0)
        continuation.yield(reading0)
        await store.receive(\.internal.altitudeReceived)
        
        // Reach landmark height
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: landmark.height + 0.5)
        continuation.yield(reading1)
        await store.receive(\.internal.altitudeReceived) {
            $0.reachedLandmarkIds = [landmark.id]
        }
        
        let count = await landmarkHapticCalled.getCallCount()
        XCTAssertEqual(count, 1)
        
        // Oscillate (stay above or cross again) - should not trigger haptic again
        let reading2 = SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.1, relativeAltitude: landmark.height + 2.0)
        continuation.yield(reading2)
        await store.receive(\.internal.altitudeReceived)
        
        let finalCount = await landmarkHapticCalled.getCallCount()
        XCTAssertEqual(finalCount, 1, "Haptic should only fire once per landmark")
    }
    
    func testHapticFeedbackDescentThenClimb() async {
        let (stream, continuation) = AsyncStream<SensorReading>.makeStream()
        let hapticCalled = Requirement()
        
        let store = TestStore(initialState: TrackerFeature.State()) {
            TrackerFeature()
        } withDependencies: {
            $0.sensorClient.altitudeStream = { stream }
            $0.locationClient.startMonitoring = {}
            $0.locationClient.stopMonitoring = {}
            $0.databaseClient.save = { _, _ in }
            $0.hapticClient.impact = { _ in await hapticCalled.fulfill() }
            $0.uuid = .incrementing
        }
        
        store.exhaustivity = .off
        
        await store.send(.view(.startButtonTapped))
        
        // Climb to 3.5m (first haptic)
        let reading0 = SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 0.0)
        continuation.yield(reading0)
        await store.receive(\.internal.altitudeReceived)
        
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: 3.5)
        continuation.yield(reading1)
        await store.receive(\.internal.altitudeReceived) {
            $0.lastHapticAltitude = 3.5
        }
        
        var count = await hapticCalled.getCallCount()
        XCTAssertEqual(count, 1)
        
        // Descend to 1.0m - baseline should reset
        let reading2 = SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.3, relativeAltitude: 1.0)
        continuation.yield(reading2)
        await store.receive(\.internal.altitudeReceived) {
            $0.lastHapticAltitude = 1.0 // Reset due to descent
        }
        
        // Climb 3m from new baseline (to 4.0m) - should trigger haptic again
        let reading3 = SensorReading(timestamp: Date(timeIntervalSince1970: 3), pressure: 101.2, relativeAltitude: 4.0)
        continuation.yield(reading3)
        await store.receive(\.internal.altitudeReceived) {
            $0.lastHapticAltitude = 4.0
        }
        
        count = await hapticCalled.getCallCount()
        XCTAssertEqual(count, 2, "Haptic should fire again after descending and re-climbing 3m")
    }
}

// MARK: - AutoPauseDetector Tests

final class AutoPauseDetectorTests: XCTestCase {
    func testNormalClimbDoesNotTrigger() {
        // Speed below threshold (normal human pace ~1 m/s)
        let belowThresholdSpeed = AutoPauseDetector.verticalSpeedThreshold - 1.0
        let readings = [
            SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 100.0),
            SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.29, relativeAltitude: 100.0 + belowThresholdSpeed),
            SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.28, relativeAltitude: 100.0 + belowThresholdSpeed * 2),
        ]
        
        let result = AutoPauseDetector.analyze(readings: readings)
        XCTAssertEqual(result, .normal)
    }
    
    func testExactlyAtThresholdTriggers() {
        // Speed exactly at threshold should trigger
        let thresholdSpeed = AutoPauseDetector.verticalSpeedThreshold
        let readings = [
            SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 100.0),
            SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: 100.0 + thresholdSpeed),
            SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.1, relativeAltitude: 100.0 + thresholdSpeed * 2),
        ]
        
        let result = AutoPauseDetector.analyze(readings: readings)
        XCTAssertEqual(result, .elevatorDetected)
    }
    
    func testElevatorSpeedTriggers() {
        // Speed well above threshold (elevator speed ~5 m/s)
        let elevatorSpeed = AutoPauseDetector.verticalSpeedThreshold + 2.0
        let readings = [
            SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 100.0),
            SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: 100.0 + elevatorSpeed),
            SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.1, relativeAltitude: 100.0 + elevatorSpeed * 2),
        ]
        
        let result = AutoPauseDetector.analyze(readings: readings)
        XCTAssertEqual(result, .elevatorDetected)
    }
    
    func testSingleHighSpeedReadingDoesNotTrigger() {
        // Only one high-speed interval, not enough consecutive readings
        let highSpeed = AutoPauseDetector.verticalSpeedThreshold + 5.0
        let lowSpeed = AutoPauseDetector.verticalSpeedThreshold - 2.0
        let readings = [
            SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 100.0),
            SensorReading(timestamp: Date(timeIntervalSince1970: 1), pressure: 101.2, relativeAltitude: 100.0 + highSpeed), // High
            SensorReading(timestamp: Date(timeIntervalSince1970: 2), pressure: 101.19, relativeAltitude: 100.0 + highSpeed + lowSpeed), // Low
        ]
        
        let result = AutoPauseDetector.analyze(readings: readings)
        XCTAssertEqual(result, .normal)
    }
    
    func testEmptyReadingsReturnsNormal() {
        let result = AutoPauseDetector.analyze(readings: [])
        XCTAssertEqual(result, .normal)
    }
    
    func testSingleReadingReturnsNormal() {
        let readings = [
            SensorReading(timestamp: Date(timeIntervalSince1970: 0), pressure: 101.3, relativeAltitude: 100.0),
        ]
        let result = AutoPauseDetector.analyze(readings: readings)
        XCTAssertEqual(result, .normal)
    }
}

// MARK: - LocationClient Integration Tests

@MainActor
final class LocationClientTests: XCTestCase {
    func testLiveValueExists() {
        let client = LocationClient.liveValue
        XCTAssertNotNil(client.startMonitoring)
        XCTAssertNotNil(client.stopMonitoring)
    }
    
    func testPreviewValueNoOps() async {
        let client = LocationClient.previewValue
        await client.startMonitoring()
        await client.stopMonitoring()
    }
}

// MARK: - DatabaseClient Tests

@MainActor
final class DatabaseClientTests: XCTestCase {
    func testInMemoryDatabaseSaveAndFetch() async throws {
        let db = try AppDatabase.inMemory()
        
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 100), pressure: 101.3, relativeAltitude: 50.0)
        let reading2 = SensorReading(timestamp: Date(timeIntervalSince1970: 200), pressure: 101.2, relativeAltitude: 55.0)
        
        try await db.save(reading1, sessionId: "session-1")
        try await db.save(reading2, sessionId: "session-1")
        
        let fetched = try await db.fetchAll()
        XCTAssertEqual(fetched.count, 2)
        XCTAssertEqual(fetched[0].relativeAltitude, 50.0)
        XCTAssertEqual(fetched[1].relativeAltitude, 55.0)
    }
    
    func testInMemoryDatabaseDeleteAll() async throws {
        let db = try AppDatabase.inMemory()
        
        let reading = SensorReading(timestamp: Date(), pressure: 101.3, relativeAltitude: 50.0)
        try await db.save(reading)
        
        var fetched = try await db.fetchAll()
        XCTAssertEqual(fetched.count, 1)
        
        try await db.deleteAll()
        
        fetched = try await db.fetchAll()
        XCTAssertEqual(fetched.count, 0)
    }
    
    func testFetchBySession() async throws {
        let db = try AppDatabase.inMemory()
        
        let reading1 = SensorReading(timestamp: Date(timeIntervalSince1970: 100), pressure: 101.3, relativeAltitude: 50.0)
        let reading2 = SensorReading(timestamp: Date(timeIntervalSince1970: 200), pressure: 101.2, relativeAltitude: 55.0)
        let reading3 = SensorReading(timestamp: Date(timeIntervalSince1970: 300), pressure: 101.1, relativeAltitude: 60.0)
        
        try await db.save(reading1, sessionId: "session-1")
        try await db.save(reading2, sessionId: "session-2")
        try await db.save(reading3, sessionId: "session-1")
        
        let session1Readings = try await db.fetchReadings(forSession: "session-1")
        XCTAssertEqual(session1Readings.count, 2)
        
        let session2Readings = try await db.fetchReadings(forSession: "session-2")
        XCTAssertEqual(session2Readings.count, 1)
    }
}
