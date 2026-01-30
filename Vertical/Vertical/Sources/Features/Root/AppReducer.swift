import ComposableArchitecture
import SwiftUI

@Reducer
struct AppReducer {
    @ObservableState
    struct State: Equatable {
        var appLaunchCount: Int = 0
        var tracker = TrackerFeature.State()
        var timeline = TimelineFeature.State()
        var stats = StatsFeature.State()
        var landmarkCollection = LandmarkCollectionFeature.State()
        @Presents var result: ResultFeature.State?
        @Presents var onboarding: OnboardingFeature.State?
        var isInitialized: Bool = false
    }
    
    enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)
        case tracker(TrackerFeature.Action)
        case timeline(TimelineFeature.Action)
        case stats(StatsFeature.Action)
        case landmarkCollection(LandmarkCollectionFeature.Action)
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
        Scope(state: \.stats, action: \.stats) {
            StatsFeature()
        }
        Scope(state: \.landmarkCollection, action: \.landmarkCollection) {
            LandmarkCollectionFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                state.appLaunchCount += 1
                
                guard !state.isInitialized else { return .none }
                state.isInitialized = true
                
                return .run { [landmarkClient, userDefaults, databaseClient] send in
                    await databaseClient.ping()
                    
                    let agreed = userDefaults.boolForKey(UserDefaultClient.hasAgreedToTermsKey)
                    if !agreed {
                        await send(.internal(.showOnboarding))
                    }
                    
                    do {
                        let landmarks = try await landmarkClient.loadLandmarks()
                        await send(.internal(.landmarksLoaded(landmarks)))
                    } catch {
                    }
                }
                
            case let .internal(.landmarksLoaded(landmarks)):
                return .merge(
                    .send(.tracker(.internal(.setLandmarks(landmarks)))),
                    .send(.timeline(.setLandmarks(landmarks)))
                )
                
            case let .tracker(.internal(.altitudeReceived(reading))):
                return .send(.timeline(.setAltitude(reading.relativeAltitude)))
                
            case .tracker(.view(.stopButtonTapped)):
                let trackerState = state.tracker
                if let sessionId = trackerState.currentSessionId {
                    state.tracker.isTracking = false
                    state.tracker.isSaving = true
                    
                    #if targetEnvironment(simulator)
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
                    
                    return .run { [databaseClient] send in
                        do {
                            // Stability delay
                            try await Task.sleep(nanoseconds: 300_000_000)
                            
                            try await databaseClient.saveSession(
                                id, startTs, endTs, climb, vam, count, synced, active, mito, rer, autoph
                            )
                            
                            let resultState = ResultFeature.State(
                                sessionId: id,
                                isAMPKActivated: active,
                                mitochondrialIndex: mito,
                                rerEstimation: rer,
                                autophagyDepth: autoph
                            )
                            await send(.internal(.sessionSaved(resultState)))
                        } catch {
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

            case .tracker, .timeline, .stats, .landmarkCollection, .result, .onboarding, .internal:
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
            
            TabView {
                // Main Tracker Tab
                ZStack {
                    // Deep Background - Particle System
                    MetalParticleView(
                        vam: store.tracker.vam,
                        altitude: store.tracker.currentAltitude,
                        isAMPKActivated: store.tracker.isAMPKActivated
                    )
                    .ignoresSafeArea()
                    
                    // Background Timeline
                    TimelineView(store: store.scope(state: \.timeline, action: \.timeline))
                        .ignoresSafeArea()
                    
                    // Foreground Tracker Controls
                    TrackerView(store: store.scope(state: \.tracker, action: \.tracker))
                        .padding(.bottom, 140)
                }
                .tabItem {
                    Label(String(localized: "TRACKER"), systemImage: "figure.climbing")
                }
                
                // Statistics Tab
                StatsView(store: store.scope(state: \.stats, action: \.stats))
                    .tabItem {
                        Label(String(localized: "STATS"), systemImage: "chart.bar.fill")
                    }
                
                // Landmarks Tab
                LandmarkCollectionView(store: store.scope(state: \.landmarkCollection, action: \.landmarkCollection))
                    .tabItem {
                        Label(String(localized: "LANDMARKS"), systemImage: "flag.fill")
                    }
            }
            .tint(.cyan)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.black
                appearance.backgroundEffect = UIBlurEffect(style: .dark)
                
                // Unselected (Dimmed but visible)
                let normal = appearance.stackedLayoutAppearance.normal
                normal.iconColor = UIColor.white.withAlphaComponent(0.4)
                normal.titleTextAttributes = [
                    .foregroundColor: UIColor.white.withAlphaComponent(0.4),
                    .font: UIFont.systemFont(ofSize: 10, weight: .bold)
                ]
                
                // Selected (Vibrant Cyan)
                let selected = appearance.stackedLayoutAppearance.selected
                selected.iconColor = UIColor.cyan
                selected.titleTextAttributes = [
                    .foregroundColor: UIColor.cyan,
                    .font: UIFont.systemFont(ofSize: 10, weight: .black)
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .preferredColorScheme(.dark) // Force dark mode regardless of system settings
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
