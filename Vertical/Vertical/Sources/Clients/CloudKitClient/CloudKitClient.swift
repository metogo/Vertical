import ComposableArchitecture
import CloudKit
import Foundation

@DependencyClient
struct CloudKitClient: Sendable {
    var checkAccountStatus: @Sendable () async throws -> CKAccountStatus = { .couldNotDetermine }
    var uploadSession: @Sendable (SessionRecord, Data) async throws -> Void
    var fetchNewSessions: @Sendable (Date) async throws -> [(SessionRecord, Data)] = { _ in [] }
}

extension CloudKitClient: DependencyKey {
    static let liveValue = Self(
        checkAccountStatus: {
            print("⚠️ CloudKit: Running in Local Mode (No dev account detected)")
            return .couldNotDetermine
        },
        uploadSession: { _, _ in
            print("⚠️ CloudKit: Sync skipped (Local Mode)")
        },
        fetchNewSessions: { _ in
            print("⚠️ CloudKit: Fetch skipped (Local Mode)")
            return []
        }
    )
    
    static let testValue = Self()
    static let previewValue = Self(
        checkAccountStatus: { .available },
        uploadSession: { _, _ in },
        fetchNewSessions: { _ in [] }
    )
}

extension DependencyValues {
    var cloudKit: CloudKitClient {
        get { self[CloudKitClient.self] }
        set { self[CloudKitClient.self] = newValue }
    }
}
