import ComposableArchitecture
import Foundation

@DependencyClient
struct DatabaseClient: Sendable {
    /// Save a sensor reading using primitive values to ensure memory safety
    var save: @Sendable (
        _ timestamp: Double,
        _ pressure: Double,
        _ altitude: Double,
        _ sessionId: String?
    ) async throws -> Void
    
    /// Fetch all stored readings
    var fetchAll: @Sendable () async throws -> [SensorReading]
    /// Fetch readings for a specific session
    var fetchSession: @Sendable (_ sessionId: String) async throws -> [SensorReading]
    /// Fetch readings within a time range
    var fetchRange: @Sendable (_ from: Date, _ to: Date) async throws -> [SensorReading]
    /// Delete all readings
    var deleteAll: @Sendable () async throws -> Void
    
    // Session Management
    var saveSession: @Sendable (
        _ id: String,
        _ startDate: Double,
        _ endDate: Double?,
        _ totalClimb: Double,
        _ maxVam: Double,
        _ readingsCount: Int,
        _ isSynced: Bool,
        _ isAMPKActivated: Bool,
        _ mitochondrialIndex: Double,
        _ rerEstimation: Double,
        _ autophagyDepth: Double
    ) async throws -> Void
    var fetchSessions: @Sendable () async throws -> [SessionRecord] = { [] }
    var fetchUnsyncedSessions: @Sendable () async throws -> [SessionRecord] = { [] }
    var markAsSynced: @Sendable (_ sessionId: String) async throws -> Void
    
    /// Warm up the database (initializes the shared instance)
    var ping: @Sendable () async -> Void
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

// MARK: - Implementation

extension DatabaseClient: DependencyKey {
    #if targetEnvironment(simulator)
    // SIMULATOR: Use no-op implementation to avoid demo mode database conflicts
    static let liveValue = Self(
        save: { _, _, _, _ in print("📦 DB: save skipped (simulator)") },
        fetchAll: { [] },
        fetchSession: { _ in [] },
        fetchRange: { _, _ in [] },
        deleteAll: { },
        saveSession: { _, _, _, _, _, _, _, _, _, _, _ in print("📦 DB: saveSession skipped (simulator)") },
        fetchSessions: { [] },
        fetchUnsyncedSessions: { [] },
        markAsSynced: { _ in },
        ping: { }
    )
    #else
    // REAL DEVICE: Use actual database with primitive values for maximum safety
    static let liveValue = Self(
        save: { ts, pr, alt, sid in
            print("📦 DB: saving sensor reading...")
            try AppDatabase.shared.save(
                timestamp: ts,
                pressure: pr,
                altitude: alt,
                sessionId: sid
            )
        },
        fetchAll: {
            try AppDatabase.shared.fetchAll()
        },
        fetchSession: { sessionId in
            try AppDatabase.shared.fetchReadings(forSession: sessionId)
        },
        fetchRange: { from, to in
            try AppDatabase.shared.fetchReadings(from: from, to: to)
        },
        deleteAll: {
            try AppDatabase.shared.deleteAll()
        },
        saveSession: { id, start, end, climb, vam, count, synced, active, mito, rer, autoph in
            print("📦 DatabaseClient: calling saveSession for \(id)")
            try AppDatabase.shared.saveSession(
                id: id,
                startDate: start,
                endDate: end,
                totalClimb: climb,
                maxVam: vam,
                readingsCount: count,
                isSynced: synced,
                isAMPKActivated: active,
                mitochondrialIndex: mito,
                rerEstimation: rer,
                autophagyDepth: autoph
            )
            print("📦 DatabaseClient: saveSession call returned for \(id)")
        },
        fetchSessions: {
            try AppDatabase.shared.fetchSessions()
        },
        fetchUnsyncedSessions: {
            try AppDatabase.shared.fetchUnsyncedSessions()
        },
        markAsSynced: { sessionId in
            try AppDatabase.shared.markAsSynced(sessionId: sessionId)
        },
        ping: {
            print("📦 DatabaseClient: pinging database...")
            _ = AppDatabase.shared
            print("📦 DatabaseClient: ping finished")
        }
    )
    #endif
    
    static let testValue = Self(
        save: { _, _, _, _ in },
        fetchAll: { [] },
        fetchSession: { _ in [] },
        fetchRange: { _, _ in [] },
        deleteAll: { },
        saveSession: { _, _, _, _, _, _, _, _, _, _, _ in },
        fetchSessions: { [] },
        fetchUnsyncedSessions: { [] },
        markAsSynced: { _ in },
        ping: { }
    )
    
    static let previewValue = Self(
        save: { _, _, _, _ in },
        fetchAll: { [] },
        fetchSession: { _ in [] },
        fetchRange: { _, _ in [] },
        deleteAll: { },
        saveSession: { _, _, _, _, _, _, _, _, _, _, _ in },
        fetchSessions: { [] },
        fetchUnsyncedSessions: { [] },
        markAsSynced: { _ in },
        ping: { }
    )
}
