import ComposableArchitecture
import Foundation
import UIKit
import os.log

private let logger = Logger(subsystem: "com.vertical.tracker", category: "TrackerFeature")

@Reducer
struct TrackerFeature {
    @ObservableState
    struct State: Equatable {
        var vam: Double = 0.0
        var currentAltitude: Double = 0.0
        var isTracking: Bool = false
        var isPaused: Bool = false
        var altitudeHistory: [SensorReading] = []
        var currentSessionId: String?
        var startTime: Date?
        var totalClimb: Double = 0.0
        var maxVam: Double = 0.0
        var sessionReadingsCount: Int = 0
        var hasRequestedNotificationPermission: Bool = false
        
        // Haptics and Milestones
        var isHapticEnabled: Bool = true
        var lastHapticAltitude: Double = 0.0
        var reachedLandmarkIds: Set<UUID> = []
        var landmarks: [Landmark] = []
        var lastUnlockedLandmarkName: String? = nil
        
        // Configuration constants
        static let windowDuration: TimeInterval = 10.0
        static let minimumWindowForCalculation: TimeInterval = 3.0
        static let minimumReadingsForCalculation = 3
        static let hapticInterval: Double = 3.0 // meters (approx 1 floor)
        static let unlockMessageDuration: UInt64 = 3_000_000_000 // 3 seconds in nanoseconds
        
        /// The next landmark to reach
        var nextLandmark: Landmark? {
            landmarks.first { $0.height > currentAltitude }
        }
        
        /// Progress percentage to the next landmark (0.0 to 1.0)
        var progressToNextLandmark: Double {
            guard let next = nextLandmark else { return 0.0 }
            let previousHeight = landmarks.last { $0.height <= currentAltitude }?.height ?? 0.0
            let range = next.height - previousHeight
            guard range > 0 else { return 0.0 }
            return min(1.0, max(0.0, (currentAltitude - previousHeight) / range))
        }
        
        var elapsedTime: TimeInterval {
            guard let start = startTime else { return 0 }
            return Date().timeIntervalSince(start)
        }
    }
    
    enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)
        
        enum ViewAction {
            case startButtonTapped
            case stopButtonTapped
            case resumeButtonTapped
            case hapticToggleTapped
            case onAppear
            case clearUnlockMessage
        }
        
        enum InternalAction {
            case altitudeReceived(SensorReading)
            case autoPauseTriggered(reading: SensorReading)
            case notificationPermissionResult(Bool)
            case setLandmarks([Landmark])
        }
    }
    
    @Dependency(\.sensorClient) var sensorClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.hapticClient) var hapticClient
    @Dependency(\.landmarkClient) var landmarkClient
    @Dependency(\.uuid) var uuid
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .none
                
            case let .internal(.setLandmarks(landmarks)):
                state.landmarks = landmarks
                return .none
                
            case .view(.clearUnlockMessage):
                state.lastUnlockedLandmarkName = nil
                return .none
                
            case .view(.hapticToggleTapped):
                state.isHapticEnabled.toggle()
                return .none
                
            case .view(.startButtonTapped):
                state.isTracking = true
                state.isPaused = false
                state.altitudeHistory = []
                state.vam = 0.0
                state.totalClimb = 0.0
                state.maxVam = 0.0
                state.sessionReadingsCount = 0
                state.lastHapticAltitude = 0.0
                state.reachedLandmarkIds = []
                state.startTime = Date()
                state.currentSessionId = uuid().uuidString
                let sessionId = state.currentSessionId
                logger.info("Starting tracking session: \(sessionId ?? "nil")")
                let location = locationClient
                let sensor = sensorClient
                return .run { send in
                    await location.startMonitoring()
                    
                    #if targetEnvironment(simulator)
                    // SIMULATOR: Skip SensorClient, use direct demo mode
                    logger.info("📍 Simulator detected. Running Demo Mode.")
                    var alt = 0.0
                    var loopCount = 0
                    while true {
                        loopCount += 1
                        print("🔄 Demo loop iteration \(loopCount), sleeping...")
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        alt += 0.75
                        print("🔄 Demo loop \(loopCount): altitude = \(alt)m, sending action...")
                        let reading = SensorReading(timestamp: Date(), pressure: 101.3, relativeAltitude: alt)
                        await send(.internal(.altitudeReceived(reading)))
                        print("🔄 Demo loop \(loopCount): action sent successfully")
                    }
                    #else
                    // REAL DEVICE: Use actual sensor
                    for await reading in await sensor.altitudeStream() {
                        await send(.internal(.altitudeReceived(reading)))
                    }
                    #endif
                }
                .cancellable(id: "tracker-altitude-stream", cancelInFlight: true)
                
            case .view(.stopButtonTapped):
                let sessionId = state.currentSessionId
                state.isTracking = false
                state.isPaused = false
                state.vam = 0.0
                state.currentSessionId = nil
                logger.info("Stopping tracking session: \(sessionId ?? "nil")")
                let location = locationClient
                return .merge(
                    .cancel(id: "tracker-altitude-stream"),
                    .run { _ in await location.stopMonitoring() }
                )
                
            case .view(.resumeButtonTapped):
                guard state.isTracking, state.isPaused else { return .none }
                state.isPaused = false
                state.altitudeHistory = [] // Clear history to avoid re-triggering pause
                logger.info("Resumed tracking after auto-pause")
                return .none
                
            case let .internal(.altitudeReceived(reading)):
                guard state.isTracking else { return .none }
                
                let sessionId = state.currentSessionId
                
                // Track total climb
                let delta = reading.relativeAltitude - state.currentAltitude
                if delta > 0 {
                    state.totalClimb += delta
                }
                
                state.sessionReadingsCount += 1
                state.currentAltitude = reading.relativeAltitude
                state.altitudeHistory.append(reading)
                
                // Track haptics
                var hapticEffects: [Effect<Action>] = []
                
                if state.isHapticEnabled && !state.isPaused {
                    // 1. Check for 3m climb (floor level)
                    // If we descended, reset the baseline to current altitude
                    if reading.relativeAltitude < state.lastHapticAltitude {
                        state.lastHapticAltitude = reading.relativeAltitude
                    }
                    
                    let climbSinceLastHaptic = reading.relativeAltitude - state.lastHapticAltitude
                    if climbSinceLastHaptic >= State.hapticInterval {
                        state.lastHapticAltitude = reading.relativeAltitude
                        let client = hapticClient
                        hapticEffects.append(.run { _ in await client.impact(.heavy) })
                    }
                    
                    // 2. Check for landmark crossing
                    // First, collect landmarks that were just reached
                    var newlyReachedLandmarks: [Landmark] = []
                    for landmark in state.landmarks {
                        if reading.relativeAltitude >= landmark.height && !state.reachedLandmarkIds.contains(landmark.id) {
                            newlyReachedLandmarks.append(landmark)
                        }
                    }
                    
                    // Then update state and create effects (separated to avoid inout capture)
                    for landmark in newlyReachedLandmarks {
                        state.reachedLandmarkIds.insert(landmark.id)
                        state.lastUnlockedLandmarkName = landmark.name
                        logger.info("Landmark reached: \(landmark.name)")
                    }
                    
                    if !newlyReachedLandmarks.isEmpty {
                        let client = hapticClient
                        hapticEffects.append(.run { _ in await client.notification(.success) })
                        // Auto-dismiss the message after 3 seconds
                        hapticEffects.append(.run { send in
                            try? await Task.sleep(nanoseconds: State.unlockMessageDuration)
                            await send(.view(.clearUnlockMessage))
                        })
                    }
                }
                
                // Remove readings outside the 10s window
                let now = reading.timestamp
                state.altitudeHistory.removeAll { now.timeIntervalSince($0.timestamp) > State.windowDuration }
                
                // Effect to save reading (skip in simulator to avoid actor crash)
                #if targetEnvironment(simulator)
                let saveEffect: Effect<Action> = .none
                #else
                // CRITICAL: Extract primitive values BEFORE capture to avoid use-after-free
                // Using primitive Double and TimeInterval is 100% safe across threads.
                let ts = reading.timestamp.timeIntervalSince1970
                let pr = reading.pressure
                let alt = reading.relativeAltitude
                let sid = sessionId
                
                let database = databaseClient
                let saveEffect: Effect<Action> = .run { _ in
                    do {
                        try await database.save(ts, pr, alt, sid)
                    } catch {
                        print("❌ DB Save Error: \(error.localizedDescription)")
                    }
                }
                #endif
                
                // Skip VAM calculation if paused, but still persist data
                if state.isPaused {
                    return .merge(hapticEffects + [saveEffect])
                }
                
                // Check for elevator/lift detection
                let detectionResult = AutoPauseDetector.analyze(readings: state.altitudeHistory)
                if detectionResult == .elevatorDetected {
                    return .send(.internal(.autoPauseTriggered(reading: reading)))
                }
                
                // Calculate VAM only if we have enough data points and time span
                print("📊 VAM Check: historyCount=\(state.altitudeHistory.count), required=\(State.minimumReadingsForCalculation)")
                guard state.altitudeHistory.count >= State.minimumReadingsForCalculation,
                      let first = state.altitudeHistory.first,
                      let last = state.altitudeHistory.last,
                      first != last else {
                    print("📊 VAM: Not enough readings yet")
                    return .merge(hapticEffects + [saveEffect])
                }
                
                let timeDelta = last.timestamp.timeIntervalSince(first.timestamp)
                print("📊 VAM Check: timeDelta=\(timeDelta)s, required=\(State.minimumWindowForCalculation)s")
                guard timeDelta >= State.minimumWindowForCalculation else {
                    print("📊 VAM: Time window too short")
                    return .merge(hapticEffects + [saveEffect])
                }
                
                let altitudeDelta = last.relativeAltitude - first.relativeAltitude
                // VAM is meters per hour, capped at 0 for ascent-only
                let calculatedVam = (altitudeDelta / timeDelta) * 3600
                state.vam = max(0, calculatedVam)
                state.maxVam = max(state.maxVam, state.vam)
                print("📊 VAM CALCULATED: altDelta=\(altitudeDelta)m, timeDelta=\(timeDelta)s, VAM=\(state.vam) m/h")
                
                // Persist reading to database
                return .merge(hapticEffects + [saveEffect])

                
            case let .internal(.autoPauseTriggered(reading)):
                guard state.isTracking, !state.isPaused else { return .none }
                state.isPaused = true
                state.vam = 0.0
                logger.warning("Auto-pause triggered: elevator/lift detected")
                
                let sessionId = state.currentSessionId
                let shouldRequestPermission = !state.hasRequestedNotificationPermission
                state.hasRequestedNotificationPermission = true
                
                // CRITICAL: Extract primitive values BEFORE capture to avoid use-after-free
                let ts = reading.timestamp.timeIntervalSince1970
                let pr = reading.pressure
                let alt = reading.relativeAltitude
                let sid = sessionId
                
                // Save the reading AND request notification
                let database = databaseClient
                let notification = notificationClient
                return .run { send in
                    // Always save the reading first
                    do {
                        try await database.save(ts, pr, alt, sid)
                    } catch {
                        print("❌ DB Save Error: \(error.localizedDescription)")
                    }
                    
                    // Request permission only once per session
                    if shouldRequestPermission {
                        let granted = await notification.requestPermission()
                        await send(.internal(.notificationPermissionResult(granted)))
                    } else {
                        // Permission already requested, just send notification
                        await send(.internal(.notificationPermissionResult(true)))
                    }
                }
                
            case let .internal(.notificationPermissionResult(granted)):
                guard granted else {
                    logger.info("Notification permission denied, skipping notification")
                    return .none
                }
                let notification = notificationClient
                return .run { _ in
                    await notification.sendNotification(
                        String(localized: "High Speed Detected"),
                        String(localized: "Tracking paused. Tap Resume when you're ready to continue.")
                    )
                }
            }
        }
    }
}
