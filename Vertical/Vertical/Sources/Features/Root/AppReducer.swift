import ComposableArchitecture
import SwiftUI

@Reducer
struct AppReducer {
    @ObservableState
    struct State: Equatable {
        var appLaunchCount: Int = 0
        var tracker = TrackerFeature.State()
        var timeline = TimelineFeature.State()
        @Presents var result: ResultFeature.State?
        @Presents var onboarding: OnboardingFeature.State?
        var isInitialized: Bool = false
    }
    
    enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)
        case tracker(TrackerFeature.Action)
        case timeline(TimelineFeature.Action)
        case result(PresentationAction<ResultFeature.Action>)
        case onboarding(PresentationAction<OnboardingFeature.Action>)
        
        enum ViewAction {
            case onAppear
        }
        
        enum InternalAction {
            case landmarksLoaded([Landmark])
            case showOnboarding
            case syncFinished
            case sessionSaved(ResultFeature.State)
        }
    }
    
    @Dependency(\.landmarkClient) var landmarkClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.sync) var syncClient
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some Reducer<State, Action> {
        Scope(state: \.tracker, action: \.tracker) {
            TrackerFeature()
        }
        Scope(state: \.timeline, action: \.timeline) {
            TimelineFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                state.appLaunchCount += 1
                
                guard !state.isInitialized else { return .none }
                state.isInitialized = true
                
                return .run { [landmarkClient, userDefaults, databaseClient] send in
                    // Warm up database
                    await databaseClient.ping()
                    
                    // Check if onboarding is needed
                    let agreed = userDefaults.boolForKey(UserDefaultClient.hasAgreedToTermsKey)
                    if !agreed {
                        await send(.internal(.showOnboarding))
                    }
                    
                    do {
                        let landmarks = try await landmarkClient.loadLandmarks()
                        await send(.internal(.landmarksLoaded(landmarks)))
                        
                        #if !targetEnvironment(simulator)
                        // Trigger sync on launch (skip in simulator)
                        try await syncClient.sync()
                        await send(.internal(.syncFinished))
                        #endif
                    } catch {
                        // Log error - fallback to empty
                    }
                }
                
            case let .internal(.landmarksLoaded(landmarks)):
                return .merge(
                    .send(.tracker(.internal(.setLandmarks(landmarks)))),
                    .send(.timeline(.setLandmarks(landmarks)))
                )
                
            case let .tracker(.internal(.altitudeReceived(reading))):
                // Sync altitude to timeline
                return .send(.timeline(.setAltitude(reading.relativeAltitude)))
                
            case .tracker(.view(.stopButtonTapped)):
                // Show result summary when stopping
                let trackerState = state.tracker
                if let sessionId = trackerState.currentSessionId {
                    #if targetEnvironment(simulator)
                    // In simulator, pass tracker data directly (database is disabled)
                    print("📊 Result: passing \(trackerState.altitudeHistory.count) readings, totalClimb=\(trackerState.totalClimb)")
                    state.result = ResultFeature.State(
                        sessionId: sessionId,
                        readings: trackerState.altitudeHistory,
                        totalClimb: trackerState.totalClimb,
                        isAMPKActivated: trackerState.isAMPKActivated,
                        mitochondrialIndex: trackerState.mitochondrialIndex,
                        rerEstimation: trackerState.rerEstimation,
                        autophagyDepth: trackerState.autophagyDepth
                    )
                    state.tracker.isSaving = false
                    state.tracker.currentSessionId = nil
                    return .none
                    #else
                    // Capture primitive values BEFORE entering the asynchronous run block
                    let id = String(sessionId)
                    let startTs = (trackerState.startTime ?? Date()).timeIntervalSince1970
                    let endTs = Date().timeIntervalSince1970
                    let climb = trackerState.totalClimb
                    let vam = trackerState.maxVam
                    let count = trackerState.sessionReadingsCount
                    let synced = false
                    let active = trackerState.isAMPKActivated
                    let mito = trackerState.mitochondrialIndex
                    let rer = trackerState.rerEstimation
                    let autoph = trackerState.autophagyDepth
                    
                    print("🛑 AppReducer: Finalizing session \(id)")
                    return .run { [databaseClient] send in
                        print("🚀 AppReducer: Entering .run block for \(id)")
                        do {
                            print("🚀 AppReducer: 300ms delay starting...")
                            try await Task.sleep(nanoseconds: 300_000_000)
                            
                            print("🚀 AppReducer: Triggering Task.detached...")
                            try await Task.detached(priority: .high) {
                                print("🚀 DETACHED: Thread checking in...")
                                print("🚀 DETACHED: Accessing AppDatabase.shared...")
                                let db = AppDatabase.shared
                                print("🚀 DETACHED: Calling db.saveSession...")
                                try db.saveSession(
                                    id: id,
                                    startDate: startTs,
                                    endDate: endTs,
                                    totalClimb: climb,
                                    maxVam: vam,
                                    readingsCount: count,
                                    isSynced: synced,
                                    isAMPKActivated: active,
                                    mitochondrialIndex: mito,
                                    rerEstimation: rer,
                                    autophagyDepth: autoph
                                )
                                print("🚀 DETACHED: db.saveSession returned")
                            }.value
                            print("🚀 AppReducer: saveSession SUCCESS")
                            
                            let resultState = ResultFeature.State(
                                sessionId: id,
                                isAMPKActivated: active,
                                mitochondrialIndex: mito,
                                rerEstimation: rer,
                                autophagyDepth: autoph
                            )
                            await send(.internal(.sessionSaved(resultState)))
                        } catch {
                            print("❌ AppReducer: SAVE FAILED: \(error.localizedDescription)")
                            let resultState = ResultFeature.State(sessionId: id)
                            await send(.internal(.sessionSaved(resultState)))
                        }
                    }
                    #endif
                }
                return .none
                
            case let .internal(.sessionSaved(resultState)):
                state.result = resultState
                state.tracker.isSaving = false
                state.tracker.currentSessionId = nil
                return .none
                
            case .onboarding(.presented(.internal(.savedChoice))):
                state.onboarding = nil
                return .none
                
            case .internal(.showOnboarding):
                state.onboarding = OnboardingFeature.State()
                return .none

            case .tracker, .timeline, .result, .onboarding, .internal:
                return .none
            }
        }
        .ifLet(\.$result, action: \.result) {
            ResultFeature()
        }
        .ifLet(\.$onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppReducer>
    
    var body: some View {
        @Bindable var store = store
        return ZStack {
            // Base dark background to ensure readability
            Color.black
                .ignoresSafeArea()
            
            // Subtle gradient overlay for depth
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.08, green: 0.05, blue: 0.15), location: 0.0),  // Deep purple-black
                    .init(color: Color(red: 0.02, green: 0.02, blue: 0.08), location: 0.4),  // Near black with slight blue
                    .init(color: .black, location: 0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Deep Background - Particle System
            MetalParticleView(vam: store.tracker.vam, isAMPKActivated: store.tracker.isAMPKActivated)
                .ignoresSafeArea()
            
            // Background Timeline
            TimelineView(store: store.scope(state: \.timeline, action: \.timeline))
                .ignoresSafeArea()
            
            // Foreground Tracker Controls
            VStack {
                Spacer()
                
                TrackerView(store: store.scope(state: \.tracker, action: \.tracker))
            }
        }
        .onAppear {
            store.send(.view(.onAppear))
        }
        .fullScreenCover(
            item: $store.scope(state: \.result, action: \.result)
        ) { resultStore in
            ResultView(store: resultStore)
        }
        .background(EmptyView().fullScreenCover(
            item: $store.scope(state: \.onboarding, action: \.onboarding)
        ) { onboardingStore in
            OnboardingView(store: onboardingStore)
                .interactiveDismissDisabled(true)
        })
    }
}
