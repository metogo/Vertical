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
/// Uses DatabaseQueue for maximum stability on real devices.
final class AppDatabase: Sendable {
    // Single shared instance
    static let shared: AppDatabase = {
        do {
            return try AppDatabase(path: AppDatabase.defaultDatabasePath())
        } catch {
            print("❌ DATABASE CRITICAL ERROR: \(error)")
            fatalError("Database initialization failed: \(error)")
        }
    }()
    
    private let dbWriter: any DatabaseWriter
    
    private static let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
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
        
        return migrator
    }()
    
    private init(path: String) throws {
        var config = Configuration()
        config.label = "AppDatabase"
        // Traditional journaling is more stable for many small writes on mobile
        config.prepareDatabase { db in
            try? db.execute(sql: "PRAGMA journal_mode = DELETE")
        }
        
        if path == ":memory:" {
            dbWriter = try DatabaseQueue(configuration: config)
        } else {
            dbWriter = try DatabaseQueue(path: path, configuration: config)
        }
        
        try AppDatabase.migrator.migrate(dbWriter)
    }
    
    private static func defaultDatabasePath() throws -> String {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent("vertical.sqlite").path
    }
    
    // MARK: - Public API
    
    func save(
        timestamp: Double,
        pressure: Double,
        altitude: Double,
        sessionId: String?
    ) throws {
        // Force strings to be copied as independent values BEFORE closure capture
        // usage of interpolation ensures a new string buffer is created
        let localSid = sessionId.map { "\($0)" }
        
        try dbWriter.write { db in
            let record = SensorReadingRecord(
                sessionId: localSid,
                timestamp: Date(timeIntervalSince1970: timestamp),
                pressure: pressure,
                relativeAltitude: altitude
            )
            try record.insert(db)
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
    
    func saveSession(
        id: String,
        startDate: Double,
        endDate: Double?,
        totalClimb: Double,
        maxVam: Double,
        readingsCount: Int,
        isSynced: Bool
    ) throws {
        // Deep copy of strings via interpolation
        let localId = "\(id)"
        
        try dbWriter.write { db in
            var session = SessionRecord(
                id: localId,
                startDate: Date(timeIntervalSince1970: startDate),
                endDate: endDate.map { Date(timeIntervalSince1970: $0) },
                totalClimb: totalClimb,
                maxVam: maxVam,
                readingsCount: readingsCount,
                isSynced: isSynced
            )
            try session.save(db)
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
    
    func deleteAll() throws {
        try dbWriter.write { db in
            try SensorReadingRecord.deleteAll(db)
            try SessionRecord.deleteAll(db)
        }
    }
}
