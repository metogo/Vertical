import Foundation
import GRDB
import os.log

/// Errors that can occur during database operations
enum DatabaseError: Error, LocalizedError {
    case pathError
    
    var errorDescription: String? {
        switch self {
        case .pathError:
            return "Failed to create database directory path"
        }
    }
}

/// Application database manager responsible for migrations and providing database access.
final class AppDatabase: Sendable {
    static let shared: AppDatabase = {
        do {
            let path = try AppDatabase.defaultDatabasePath()
            return try AppDatabase(path: path)
        } catch {
            fatalError("Database initialization failed: \(error)")
        }
    }()
    
    private let dbWriter: any DatabaseWriter
    
    private static let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("create_v1") { db in
            try db.create(table: "sensor_readings") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("sessionId", .text).indexed()
                t.column("timestamp", .datetime).notNull().indexed()
                t.column("pressure", .double).notNull()
                t.column("relativeAltitude", .double).notNull()
            }
            
            try db.create(table: "sessions") { t in
                t.column("id", .text).primaryKey()
                t.column("startDate", .datetime).notNull()
                t.column("endDate", .datetime)
                t.column("totalClimb", .double).notNull()
                t.column("maxVam", .double).notNull()
                t.column("readingsCount", .integer).notNull()
                t.column("isSynced", .boolean).notNull().defaults(to: false)
            }
        }
        
        migrator.registerMigration("add_ampk_column") { db in
            try db.alter(table: "sessions") { t in
                t.add(column: "isAMPKActivated", .boolean).notNull().defaults(to: false)
            }
        }
        
        migrator.registerMigration("add_metabolic_columns") { db in
            try db.alter(table: "sessions") { t in
                t.add(column: "mitochondrialIndex", .double).notNull().defaults(to: 0.0)
                t.add(column: "rerEstimation", .double).notNull().defaults(to: 0.0)
                t.add(column: "autophagyDepth", .double).notNull().defaults(to: 0.0)
            }
        }
        
        migrator.registerMigration("add_unlocked_landmarks") { db in
            try db.create(table: "unlocked_landmarks") { t in
                t.column("id", .text).primaryKey()
                t.column("unlockedDate", .datetime).notNull()
            }
        }
        
        return migrator
    }()
    
    private init(path: String) throws {
        var config = Configuration()
        config.label = "AppDatabase"
        
        config.prepareDatabase { db in
            try? db.execute(sql: "PRAGMA journal_mode = WAL")
            try? db.execute(sql: "PRAGMA synchronous = NORMAL")
        }
        
        if path == ":memory:" {
            dbWriter = try DatabaseQueue(configuration: config)
        } else {
            // DatabasePool provides significantly better performance for concurrent reads during writes
            dbWriter = try DatabasePool(path: path, configuration: config)
        }
        
        try AppDatabase.migrator.migrate(dbWriter)
    }
    
    private static func defaultDatabasePath() throws -> String {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        
        return directoryURL.appendingPathComponent("vertical.sqlite").path
    }
    
    // MARK: - Public API
    
    func save(timestamp: Double, pressure: Double, altitude: Double, sessionId: String?) async throws {
        let localSid = sessionId.map { "\($0)" }
        try await dbWriter.write { db in
            let record = SensorReadingRecord(
                sessionId: localSid,
                timestamp: Date(timeIntervalSince1970: timestamp),
                pressure: pressure,
                relativeAltitude: altitude
            )
            try record.insert(db)
        }
    }
    
    func saveSession(id: String, startDate: Double, endDate: Double?, totalClimb: Double, maxVam: Double, readingsCount: Int, isSynced: Bool, isAMPKActivated: Bool, mitochondrialIndex: Double, rerEstimation: Double, autophagyDepth: Double) async throws {
        let localId = "\(id)"
        try await dbWriter.write { db in
            var session = SessionRecord(
                id: localId,
                startDate: Date(timeIntervalSince1970: startDate),
                endDate: endDate.map { Date(timeIntervalSince1970: $0) },
                totalClimb: totalClimb,
                maxVam: maxVam,
                readingsCount: readingsCount,
                isSynced: isSynced,
                isAMPKActivated: isAMPKActivated,
                mitochondrialIndex: mitochondrialIndex,
                rerEstimation: rerEstimation,
                autophagyDepth: autophagyDepth
            )
            try session.save(db)
        }
    }
    
    func fetchAll() throws -> [SensorReading] {
        try dbWriter.read { db in
            try SensorReadingRecord
                .order(SensorReadingRecord.Columns.timestamp)
                .fetchAll(db)
                .map { $0.toSensorReading() }
        }
    }
    
    func fetchReadings(forSession sessionId: String) throws -> [SensorReading] {
        let localSid = "\(sessionId)"
        return try dbWriter.read { db in
            try SensorReadingRecord
                .filter(SensorReadingRecord.Columns.sessionId == localSid)
                .order(SensorReadingRecord.Columns.timestamp)
                .fetchAll(db)
                .map { $0.toSensorReading() }
        }
    }
    
    func fetchReadings(from: Date, to: Date) throws -> [SensorReading] {
        try dbWriter.read { db in
            try SensorReadingRecord
                .filter(SensorReadingRecord.Columns.timestamp >= from)
                .filter(SensorReadingRecord.Columns.timestamp <= to)
                .order(SensorReadingRecord.Columns.timestamp)
                .fetchAll(db)
                .map { $0.toSensorReading() }
        }
    }

    /// Checks if any session or readings exist within the given time range.
    /// Used for deduplicating HealthKit/Pedometer backfills.
    func checkOverlap(from: Date, to: Date) throws -> Bool {
        try dbWriter.read { db in
            // 1. Check for overlapping high-frequency readings
            let readingsOverlap = try SensorReadingRecord
                .filter(SensorReadingRecord.Columns.timestamp >= from)
                .filter(SensorReadingRecord.Columns.timestamp <= to)
                .fetchCount(db) > 0
            
            if readingsOverlap { return true }
            
            // 2. Check for overlapping session records
            // A session overlaps if (session.start <= to) AND (session.end >= from)
            let sessionOverlap = try SessionRecord
                .filter(SessionRecord.Columns.startDate <= to)
                .filter(SessionRecord.Columns.endDate >= from)
                .fetchCount(db) > 0
            
            return sessionOverlap
        }
    }
    
    func fetchSessions() throws -> [SessionRecord] {
        try dbWriter.read { db in
            try SessionRecord
                .order(SessionRecord.Columns.startDate.desc)
                .fetchAll(db)
        }
    }
    
    func fetchUnsyncedSessions() throws -> [SessionRecord] {
        try dbWriter.read { db in
            try SessionRecord
                .filter(SessionRecord.Columns.isSynced == false)
                .fetchAll(db)
        }
    }
    
    func markAsSynced(sessionId: String) throws {
        let localSid = "\(sessionId)"
        try dbWriter.write { db in
            if var session = try SessionRecord.fetchOne(db, key: localSid) {
                session.isSynced = true
                try session.update(db)
            }
        }
    }
    
    func unlockLandmark(id: UUID) async throws {
        let idString = id.uuidString
        try await dbWriter.write { db in
            if try db.tableExists("unlocked_landmarks") {
                let sql = "INSERT OR IGNORE INTO unlocked_landmarks (id, unlockedDate) VALUES (?, ?)"
                try db.execute(sql: sql, arguments: [idString, Date()])
            }
        }
    }
    
    func fetchUnlockedLandmarkIds() throws -> Set<UUID> {
        try dbWriter.read { db in
            let ids = try String.fetchAll(db, sql: "SELECT id FROM unlocked_landmarks")
            return Set(ids.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func deleteAll() throws {
        try dbWriter.write { db in
            try SensorReadingRecord.deleteAll(db)
            try SessionRecord.deleteAll(db)
        }
    }
}
