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
        var animatedAltitude: Double = 0.0 // For growth animations
        var isTracking: Bool = false
        var isPaused: Bool = false
        var altitudeHistory: [SensorReading] = []
        var currentSessionId: String?
        var startTime: Date?
        var totalClimb: Double = 0.0
        var maxVam: Double = 0.0
        var sessionReadingsCount: Int = 0
        var hasRequestedNotificationPermission: Bool = false
        var isSaving: Bool = false
        
        // Haptics and Milestones
        var isHapticEnabled: Bool = true
        var lastHapticAltitude: Double = 0.0
        var reachedLandmarkIds: Set<UUID> = []
        var landmarks: [Landmark] = []
        var lastUnlockedLandmarkName: String? = nil
        var celebrationLandmark: Landmark? = nil // For the new full-screen effect
        
        // Metabolic Activity (AMPK & MetaVision)
        var activeClimbDuration: TimeInterval = 0.0
        var isAMPKActivated: Bool = false
        var isScienceBoardPresented: Bool = false
        var retroactiveSessionFloors: Int? = nil
        
        // Real-time Bio-metrics
        var heartRate: Double = 0.0
        var hrrPercentage: Double = 0.0
        var mitochondrialIndex: Double = 0.0 // Duration in target zone
        var rerEstimation: Double = 0.85     // Respiratory Exchange Ratio
        var autophagyDepth: Double = 0.0     // Cumulative autophagy stimulus
        
        // User Bio-profile (for Karvonen)
        var userAge: Int = 30
        var userRestHR: Double = 60.0
        
        var maxHR: Double { 220.0 - Double(userAge) }
        
        // Configuration constants
        static let windowDuration: TimeInterval = 10.0
        static let minimumWindowForCalculation: TimeInterval = 3.0
        static let minimumReadingsForCalculation = 3
        static let hapticInterval: Double = 3.0 // meters (approx 1 floor)
        static let unlockMessageDuration: UInt64 = 3_000_000_000 // 3 seconds in nanoseconds
        static let amkpActivationThreshold: TimeInterval = 120.0 // 2 minutes (120s) for metabolic activation
        static let amkpVamThreshold: Double = 300.0 // meters/hour to be considered "active"
        
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
            case infoButtonTapped
            case retroactiveDismissTapped
        }
        
        enum InternalAction {
            case altitudeReceived(SensorReading)
            case heartRateReceived(Double)
            case autoPauseTriggered(reading: SensorReading)
            case notificationPermissionResult(Bool)
            case setLandmarks([Landmark])
            case checkRetroactiveTracking
            case retroactiveFloorsFound(Int)
            case startGrowthAnimation(target: Double)
            case growthAnimationTick(target: Double)
            case loadUnlockedLandmarks
            case setUnlockedLandmarkIds(Set<UUID>)
            case clearCelebration
        }
    }
    
    @Dependency(\.sensorClient) var sensorClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.hapticClient) var hapticClient
    @Dependency(\.landmarkClient) var landmarkClient
    @Dependency(\.healthClient) var healthClient
    @Dependency(\.uuid) var uuid
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .merge(
                    .send(.internal(.checkRetroactiveTracking)),
                    .send(.internal(.loadUnlockedLandmarks)),
                    .run { [healthClient] send in
                        for await _ in await healthClient.observeHealthDataChanges() {
                            await send(.internal(.checkRetroactiveTracking))
                        }
                    }
                )
                
            case .internal(.loadUnlockedLandmarks):
                return .run { [databaseClient] send in
                    if let ids = try? await databaseClient.fetchUnlockedLandmarkIds() {
                        await send(.internal(.setUnlockedLandmarkIds(ids)))
                    }
                }
                
            case let .internal(.setUnlockedLandmarkIds(ids)):
                state.reachedLandmarkIds = ids
                return .none
                
            case let .internal(.setLandmarks(landmarks)):
                state.landmarks = landmarks
                return .none
                
            case .view(.clearUnlockMessage):
                state.lastUnlockedLandmarkName = nil
                state.celebrationLandmark = nil
                return .none
                
            case .internal(.clearCelebration):
                state.celebrationLandmark = nil
                return .none
                
            case .view(.hapticToggleTapped):
                state.isHapticEnabled.toggle()
                return .none
                
            case .view(.infoButtonTapped):
                state.isScienceBoardPresented.toggle()
                return .none
                
            case .view(.retroactiveDismissTapped):
                let floors = state.retroactiveSessionFloors ?? 0
                state.retroactiveSessionFloors = nil
                
                if floors > 0 {
                    // Save a "Shadow Session" representing the offline climbing
                    let id = "OFFLINE-\(UUID().uuidString.prefix(8))"
                    let end = Date()
                    let start = end.addingTimeInterval(-3600 * 2) // Assume it happened in the last 2 hours for now
                    let climb = Double(floors) * 3.0 // 3m per floor
                    
                    return .run { [databaseClient] send in
                        // 1. Epic 9.3: Check for data overlap (Deduplication)
                        let isOverlapping = (try? await databaseClient.checkOverlap(start, end)) ?? false
                        
                        if isOverlapping {
                            print("🛡️ Deduplication: Overlap detected for retroactive sync. Skipping shadow session.")
                            // Still show the growth animation for "achievement feel" but don't duplicate data
                            // In a real app, we might want to merge or inform the user, but for MVP we prefer high-freq data.
                        } else {
                            // 2. Save to DB if no overlap
                            try? await databaseClient.saveSession(
                                id,
                                start.timeIntervalSince1970,
                                end.timeIntervalSince1970,
                                climb,
                                0.0, // VAM unknown
                                0,   // Readings count unknown
                                false,
                                false, // AMPK unknown
                                0.0,
                                0.85,
                                0.0
                            )
                        }
                        
                        // 3. Trigger visual growth (Delayed Reward Feel)
                        await send(.internal(.startGrowthAnimation(target: climb)))
                    }
                }
                return .none
                
            case let .internal(.startGrowthAnimation(target)):
                state.animatedAltitude = 0 // Start from zero for the "delayed reward" effect
                return .run { send in
                    await send(.internal(.growthAnimationTick(target: target)))
                }
                
            case let .internal(.growthAnimationTick(target)):
                let step = target / 20.0 
                state.animatedAltitude += step
                
                let haptic = hapticClient
                if state.animatedAltitude < target {
                    return .run { [animated = state.animatedAltitude] send in
                        await haptic.impact(.light) // Haptic "ticks" (FR-VS-07)
                        try? await Task.sleep(nanoseconds: 70_000_000) // Slightly faster (1.4s total)
                        await send(.internal(.growthAnimationTick(target: target)))
                    }
                } else {
                    state.animatedAltitude = target
                    state.currentAltitude = target
                    return .run { _ in await haptic.notification(.success) }
                }
                
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
                state.activeClimbDuration = 0.0
                state.isAMPKActivated = false
                state.startTime = Date()
                state.currentSessionId = uuid().uuidString
                let sessionId = state.currentSessionId
                logger.info("Starting tracking session: \(sessionId ?? "nil")")
                let location = locationClient
                let sensor = sensorClient
                let health = healthClient
                
                return .run { send in
                    await location.startMonitoring()
                    _ = await health.requestPermission()
                    
                    await withTaskGroup(of: Void.self) { group in
                        // Heart Rate Stream
                        group.addTask {
                            for await hr in await health.heartRateStream() {
                                await send(.internal(.heartRateReceived(hr)))
                            }
                        }
                        
                        // Altitude Stream
                        group.addTask {
                            #if targetEnvironment(simulator)
                            // SIMULATOR: Skip SensorClient, use direct demo mode
                            logger.info("📍 Simulator detected. Running Demo Mode.")
                            var alt = 0.0
                            while true {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                alt += 0.75
                                let reading = SensorReading(timestamp: Date(), pressure: 101.3, relativeAltitude: alt)
                                await send(.internal(.altitudeReceived(reading)))
                            }
                            #else
                            // REAL DEVICE: Use actual sensor
                            for await reading in await sensor.altitudeStream() {
                                await send(.internal(.altitudeReceived(reading)))
                            }
                            #endif
                        }
                    }
                }
                .cancellable(id: "tracker-tracking-streams", cancelInFlight: true)
                
            case .view(.stopButtonTapped):
                guard !state.isSaving else { return .none }
                let sessionId = state.currentSessionId
                state.isTracking = false
                state.isPaused = false
                state.isSaving = true
                state.vam = 0.0
                // We keep the sessionId until AppReducer captures it for saving
                logger.info("Stopping tracking session: \(sessionId ?? "nil")")
                let location = locationClient
                return .merge(
                    .cancel(id: "tracker-tracking-streams"),
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
                state.animatedAltitude = reading.relativeAltitude // Sync animated display during live tracking
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
                    let database = databaseClient
                    for landmark in newlyReachedLandmarks {
                        state.reachedLandmarkIds.insert(landmark.id)
                        state.lastUnlockedLandmarkName = landmark.name
                        state.celebrationLandmark = landmark // Trigger full-screen effect
                        logger.info("Landmark reached: \(landmark.name)")
                        
                        // Save to persistent storage
                        hapticEffects.append(.run { _ in
                            try? await database.unlockLandmark(landmark.id)
                        })
                    }
                    
                    if !newlyReachedLandmarks.isEmpty {
                        let client = hapticClient
                        hapticEffects.append(.run { _ in await client.notification(.success) })
                        // Auto-dismiss the message and celebration after 4 seconds
                        hapticEffects.append(.run { send in
                            try? await Task.sleep(nanoseconds: 4_000_000_000)
                            await send(.internal(.clearCelebration))
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
                
                // Track AMPK Activation
                if state.vam >= State.amkpVamThreshold {
                    // Get time delta since last reading
                    if state.altitudeHistory.count >= 2 {
                        let lastIdx = state.altitudeHistory.count - 1
                        let delta = state.altitudeHistory[lastIdx].timestamp.timeIntervalSince(state.altitudeHistory[lastIdx-1].timestamp)
                        state.activeClimbDuration += delta
                    }
                } else {
                    // Decay the active duration if we slow down or stop
                    state.activeClimbDuration = max(0, state.activeClimbDuration - 1.0)
                }
                
                // Trigger activation
                let previouslyActivated = state.isAMPKActivated
                state.isAMPKActivated = state.activeClimbDuration >= State.amkpActivationThreshold
                
                if state.isAMPKActivated && !previouslyActivated {
                    logger.info("🔥 AMPK ACTIVATED: Metabolic health benefits achieved!")
                    let client = hapticClient
                    hapticEffects.append(.run { _ in await client.notification(.warning) }) // Double pulse for activation
                }
                
                // Persist reading to database
                return .merge(hapticEffects + [saveEffect])
                
            case .internal(.checkRetroactiveTracking):
                return .run { [sensorClient, healthClient] send in
                    // Query last 7 days for "hidden" climbs (PRD Alignment)
                    let end = Date()
                    let start = end.addingTimeInterval(-7 * 24 * 3600)
                    do {
                        // Combine Pedometer and HealthKit for better accuracy
                        let pFloors = try await sensorClient.queryHistoricalFloors(start, end)
                        let hFloors = try await healthClient.fetchFloorsClimbed(start, end)
                        let maxFloors = max(pFloors, hFloors)
                        
                        if maxFloors > 3 {
                            await send(.internal(.retroactiveFloorsFound(maxFloors)))
                        }
                    } catch {
                        print("❌ Retroactive query failed: \(error.localizedDescription)")
                    }
                }
                
            case let .internal(.retroactiveFloorsFound(floors)):
                // If we aren't already tracking, show the retroactive banner
                if !state.isTracking {
                    state.retroactiveSessionFloors = floors
                }
                return .none

            case let .internal(.heartRateReceived(hr)):
                state.heartRate = hr
                
                // Karvonen Formula: HRR% = (Current HR - Rest HR) / (Max HR - Rest HR)
                let hrrRange = state.maxHR - state.userRestHR
                if hrrRange > 0 {
                    state.hrrPercentage = max(0, min(1.0, (hr - state.userRestHR) / hrrRange))
                }
                
                // Update Metabolic Metrics based on HRR%
                // 1. Mitochondrial Index (Time in 75%-90% zone)
                if state.hrrPercentage >= 0.75 && state.hrrPercentage <= 0.90 {
                    // Assuming updates are ~1s apart
                    state.mitochondrialIndex += 1.0 / 60.0 // Add as minutes
                }
                
                // 2. RER Estimation (0.7 to 1.0)
                // Linear map: 40% HRR -> 0.7, 100% HRR -> 1.0
                let rerRatio = (state.hrrPercentage - 0.4) / (1.0 - 0.4)
                state.rerEstimation = 0.7 + max(0, min(0.3, rerRatio * 0.3))
                
                // 3. Autophagy Depth (Cumulative stimulus)
                // High intensity over time triggers autophagy. Exponential weighting for depth.
                if state.hrrPercentage > 0.6 {
                    state.autophagyDepth += pow(state.hrrPercentage, 3) * 0.1
                }
                
                return .none

                
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
