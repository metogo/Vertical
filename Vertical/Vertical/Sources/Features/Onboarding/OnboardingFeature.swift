import ComposableArchitecture
import SwiftUI

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var isAgreeEnabled: Bool = false
    }
    
    enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)
        
        enum ViewAction {
            case agreeButtonTapped
            case scrolledToBottom
        }
        
        enum InternalAction {
            case savedChoice
        }
    }
    
    @Dependency(\.userDefaults) var userDefaults
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.agreeButtonTapped):
                return .run { send in
                    await userDefaults.setBool(true, UserDefaultClient.hasAgreedToTermsKey)
                    await send(.internal(.savedChoice))
                }
                
            case .view(.scrolledToBottom):
                state.isAgreeEnabled = true
                return .none
                
            case .internal(.savedChoice):
                // This will be handled by parent to dismiss onboarding
                return .none
            }
        }
    }
}

struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Background Accent - Subtle Building Silhouette
            buildingSilhouette
            
            VStack(spacing: 32) {
                Spacer()
                
                // Title
                VStack(spacing: 8) {
                    Text("VERTICAL")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .italic()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("URBAN EXPLORER")
                        .font(.caption)
                        .fontWeight(.black)
                        .kerning(4)
                        .foregroundStyle(.secondary)
                }
                
                // Disclaimer Box
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SAFETY & RISK DISCLAIMER")
                            .font(.headline)
                            .foregroundStyle(.pink)
                        
                        Text("DISCLAIMER_TEXT")
                            .foregroundStyle(.white)
                        
                        warningPoint(text: "WARNING_1")
                        warningPoint(text: "WARNING_2")
                        warningPoint(text: "WARNING_3")
                        warningPoint(text: "WARNING_4")
                        
                        Color.clear.frame(height: 20)
                            .onAppear {
                                store.send(.view(.scrolledToBottom))
                            }
                    }
                    .padding()
                }
                .frame(maxHeight: 300)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // Action Button
                Button {
                    store.send(.view(.agreeButtonTapped))
                } label: {
                    Text("I UNDERSTAND & AGREE")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            store.isAgreeEnabled ? 
                            AnyView(LinearGradient(colors: [.blue, .pink], startPoint: .leading, endPoint: .trailing)) :
                            AnyView(Color.gray.opacity(0.3))
                        )
                        .cornerRadius(15)
                        .shadow(color: store.isAgreeEnabled ? .pink.opacity(0.4) : .clear, radius: 10)
                }
                .disabled(!store.isAgreeEnabled)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func warningPoint(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.caption)
            Text(LocalizedStringKey(text))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    private var buildingSilhouette: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom, spacing: 20) {
                Rectangle()
                    .fill(LinearGradient(colors: [.black, .blue.opacity(0.2)], startPoint: .bottom, endPoint: .top))
                    .frame(width: 60, height: 200)
                Rectangle()
                    .fill(LinearGradient(colors: [.black, .pink.opacity(0.15)], startPoint: .bottom, endPoint: .top))
                    .frame(width: 80, height: 350)
                Rectangle()
                    .fill(LinearGradient(colors: [.black, .blue.opacity(0.1)], startPoint: .bottom, endPoint: .top))
                    .frame(width: 40, height: 250)
            }
            .blur(radius: 40)
            .opacity(0.5)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    )
}
