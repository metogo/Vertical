import ComposableArchitecture
import Foundation

@DependencyClient
struct UserDefaultClient {
    var boolForKey: @Sendable (String) -> Bool = { _ in false }
    var setBool: @Sendable (Bool, String) async -> Void
}

extension UserDefaultClient: DependencyKey {
    static let liveValue = Self(
        boolForKey: { key in
            UserDefaults.standard.bool(forKey: key)
        },
        setBool: { value, key in
            UserDefaults.standard.set(value, forKey: key)
        }
    )
    
    static let testValue = Self(
        boolForKey: { _ in false },
        setBool: { _, _ in }
    )
    
    static let previewValue = Self(
        boolForKey: { _ in false },
        setBool: { _, _ in }
    )
}

extension DependencyValues {
    var userDefaults: UserDefaultClient {
        get { self[UserDefaultClient.self] }
        set { self[UserDefaultClient.self] = newValue }
    }
}

extension UserDefaultClient {
    static let hasAgreedToTermsKey = "hasAgreedToTerms"
}
