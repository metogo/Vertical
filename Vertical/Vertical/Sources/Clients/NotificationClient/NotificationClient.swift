import ComposableArchitecture
import Foundation
import UserNotifications

@DependencyClient
struct NotificationClient: Sendable {
    /// Request notification permissions
    var requestPermission: @Sendable () async -> Bool = { false }
    /// Send a local notification
    var sendNotification: @Sendable (_ title: String, _ body: String) async -> Void
}

extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}

// MARK: - Implementation

extension NotificationClient: DependencyKey {
    static let liveValue = Self(
        requestPermission: {
            let center = UNUserNotificationCenter.current()
            do {
                return try await center.requestAuthorization(options: [.alert, .sound])
            } catch {
                return false
            }
        },
        sendNotification: { title, body in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil // Deliver immediately
            )
            
            let center = UNUserNotificationCenter.current()
            try? await center.add(request)
        }
    )
    
    static let testValue = Self(
        requestPermission: { unimplemented("\(Self.self).requestPermission", placeholder: false) },
        sendNotification: { _, _ in unimplemented("\(Self.self).sendNotification") }
    )
    
    static let previewValue = Self(
        requestPermission: { true },
        sendNotification: { _, _ in }
    )
}
