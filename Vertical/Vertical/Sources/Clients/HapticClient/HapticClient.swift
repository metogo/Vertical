import ComposableArchitecture
import UIKit

@DependencyClient
struct HapticClient: Sendable {
    var impact: @Sendable (UIImpactFeedbackGenerator.FeedbackStyle) async -> Void
    var notification: @Sendable (UINotificationFeedbackGenerator.FeedbackType) async -> Void
}

extension DependencyValues {
    var hapticClient: HapticClient {
        get { self[HapticClient.self] }
        set { self[HapticClient.self] = newValue }
    }
}

extension HapticClient: DependencyKey {
    static let liveValue = Self(
        impact: { style in
            await MainActor.run {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            }
        },
        notification: { type in
            await MainActor.run {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
            }
        }
    )
    
    static let testValue = Self(
        impact: { _ in unimplemented("\(Self.self).impact") },
        notification: { _ in unimplemented("\(Self.self).notification") }
    )
    
    static let previewValue = Self(
        impact: { _ in },
        notification: { _ in }
    )
}
