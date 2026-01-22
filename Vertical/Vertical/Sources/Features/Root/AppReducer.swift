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
        }
    }
    
    @Dependency(\.landmarkClient) var landmarkClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.sync) var syncClient
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                state.appLaunchCount += 1
                
                guard !state.isInitialized else { return .none }
                state.isInitialized = true
                
                return .run { [landmarkClient, userDefaults] send in
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
                        totalClimb: trackerState.totalClimb
                    )
                    return .none
                    #else
                    state.result = ResultFeature.State(sessionId: sessionId)
                    // Create and save session record for sync
                    let sessionRecord = SessionRecord(
                        id: sessionId,
                        startDate: trackerState.startTime ?? Date(),
                        endDate: Date(),
                        totalClimb: trackerState.totalClimb,
                        maxVam: trackerState.maxVam,
                        readingsCount: trackerState.sessionReadingsCount,
                        isSynced: false
                    )
                    
                    // Capture primitive values BEFORE entering the asynchronous run block
                    let id = String(sessionId) // Force a copy of the string to be safe
                    let startTs = (trackerState.startTime ?? Date()).timeIntervalSince1970
                    let endTs = Date().timeIntervalSince1970
                    let climb = trackerState.totalClimb
                    let vam = trackerState.maxVam
                    let count = trackerState.sessionReadingsCount
                    let synced = false
                    
                    return .run { [databaseClient, syncClient] send in
                        try? await databaseClient.saveSession(
                            id,
                            startTs,
                            endTs,
                            climb,
                            vam,
                            count,
                            synced
                        )
                        try? await syncClient.sync()
                        await send(.internal(.syncFinished))
                    }
                    #endif
                }
                return .none

            case .tracker:
                return .none
                
            case .timeline:
                return .none
                
            case .result:
                return .none
                
            case .internal(.showOnboarding):
                state.onboarding = OnboardingFeature.State()
                return .none
                
            case .onboarding(.presented(.internal(.savedChoice))):
                state.onboarding = nil
                return .none
                
            case .onboarding:
                return .none
                
            case .internal:
                return .none
            }
        }
        
        Scope(state: \.tracker, action: \.tracker) {
            TrackerFeature()
        }
        Scope(state: \.timeline, action: \.timeline) {
            TimelineFeature()
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
            MetalParticleView(vam: store.tracker.vam)
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
