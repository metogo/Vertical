import Foundation
import GRDB

struct SessionRecord: Codable, FetchableRecord, PersistableRecord, Sendable, Equatable {
    static let databaseTableName = "sessions"
    
    var id: String // UUID as string
    var startDate: Date
    var endDate: Date?
    var totalClimb: Double
    var maxVam: Double
    var readingsCount: Int
    var isSynced: Bool
    
    init(id: String, startDate: Date, endDate: Date? = nil, totalClimb: Double = 0, maxVam: Double = 0, readingsCount: Int = 0, isSynced: Bool = false) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.totalClimb = totalClimb
        self.maxVam = maxVam
        self.readingsCount = readingsCount
        self.isSynced = isSynced
    }
}

extension SessionRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let startDate = Column(CodingKeys.startDate)
        static let endDate = Column(CodingKeys.endDate)
        static let totalClimb = Column(CodingKeys.totalClimb)
        static let maxVam = Column(CodingKeys.maxVam)
        static let readingsCount = Column(CodingKeys.readingsCount)
        static let isSynced = Column(CodingKeys.isSynced)
    }
}
