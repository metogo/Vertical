import ComposableArchitecture
import Foundation

@DependencyClient
struct SyncClient: Sendable {
    var sync: @Sendable () async throws -> Void
}

extension SyncClient: DependencyKey {
    static let liveValue = Self(
        sync: {
            #if targetEnvironment(simulator)
            // Skip all sync in simulator to avoid database actor crashes
            print("⚠️ SyncClient: Skipped in simulator")
            return
            #else
            @Dependency(\.cloudKit) var cloudKit
            @Dependency(\.databaseClient) var database
            
            // 1. Push Unsynced Sessions
            let unsynced = try await database.fetchUnsyncedSessions()
            for session in unsynced {
                let readings = try await database.fetchSession(session.id)
                let data = try JSONEncoder().encode(readings)
                
                do {
                    try await cloudKit.uploadSession(session, data)
                    try await database.markAsSynced(session.id)
                } catch {
                    // Log error and continue with next session
                    print("CloudKit upload failed for session \(session.id): \(error.localizedDescription)")
                }
            }
            
            // 2. Fetch New Sessions (Pull sync)
            // For simplicity in this demo, we use a fixed last sync date or store it in UserDefaults
            let lastSyncDate = UserDefaults.standard.object(forKey: "lastCloudSyncDate") as? Date ?? .distantPast
            let newRecords = try await cloudKit.fetchNewSessions(lastSyncDate)
            
            for (session, readingsData) in newRecords {
                // Save session metadata
                try await database.saveSession(
                    session.id,
                    session.startDate.timeIntervalSince1970,
                    session.endDate?.timeIntervalSince1970,
                    session.totalClimb,
                    session.maxVam,
                    session.readingsCount,
                    session.isSynced,
                    session.isAMPKActivated
                )
                
                // Decode and save readings
                let readings = try JSONDecoder().decode([SensorReading].self, from: readingsData)
                for reading in readings {
                    try await database.save(
                        reading.timestamp.timeIntervalSince1970,
                        reading.pressure,
                        reading.relativeAltitude,
                        session.id
                    )
                }
            }
            
            UserDefaults.standard.set(Date(), forKey: "lastCloudSyncDate")
            #endif
        }
    )
}

extension DependencyValues {
    var sync: SyncClient {
        get { self[SyncClient.self] }
        set { self[SyncClient.self] = newValue }
    }
}
