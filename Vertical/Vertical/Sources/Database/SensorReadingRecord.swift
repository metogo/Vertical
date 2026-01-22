import Foundation
import GRDB

/// Database record for sensor readings, conforming to GRDB protocols.
struct SensorReadingRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    static let databaseTableName = "sensor_readings"
    
    var id: Int64?
    var sessionId: String?
    var timestamp: Date
    var pressure: Double
    var relativeAltitude: Double
    
    /// Memberwise initializer
    init(id: Int64? = nil, sessionId: String? = nil, timestamp: Date, pressure: Double, relativeAltitude: Double) {
        self.id = id
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.pressure = pressure
        self.relativeAltitude = relativeAltitude
    }
    
    /// Convert from the app's SensorReading model
    init(from reading: SensorReading, sessionId: String? = nil) {
        self.id = nil
        self.sessionId = sessionId
        self.timestamp = reading.timestamp
        self.pressure = reading.pressure
        self.relativeAltitude = reading.relativeAltitude
    }
    
    /// Convert to the app's SensorReading model
    func toSensorReading() -> SensorReading {
        SensorReading(
            timestamp: timestamp,
            pressure: pressure,
            relativeAltitude: relativeAltitude
        )
    }
}

// MARK: - Table Definition

extension SensorReadingRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let sessionId = Column(CodingKeys.sessionId)
        static let timestamp = Column(CodingKeys.timestamp)
        static let pressure = Column(CodingKeys.pressure)
        static let relativeAltitude = Column(CodingKeys.relativeAltitude)
    }
}
