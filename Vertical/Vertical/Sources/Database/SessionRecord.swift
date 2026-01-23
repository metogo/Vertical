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
    var isAMPKActivated: Bool
    var mitochondrialIndex: Double
    var rerEstimation: Double
    var autophagyDepth: Double
    
    init(id: String, startDate: Date, endDate: Date? = nil, totalClimb: Double = 0, maxVam: Double = 0, readingsCount: Int = 0, isSynced: Bool = false, isAMPKActivated: Bool = false, mitochondrialIndex: Double = 0.0, rerEstimation: Double = 0.0, autophagyDepth: Double = 0.0) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.totalClimb = totalClimb
        self.maxVam = maxVam
        self.readingsCount = readingsCount
        self.isSynced = isSynced
        self.isAMPKActivated = isAMPKActivated
        self.mitochondrialIndex = mitochondrialIndex
        self.rerEstimation = rerEstimation
        self.autophagyDepth = autophagyDepth
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case startDate
        case endDate
        case totalClimb
        case maxVam
        case readingsCount
        case isSynced
        case isAMPKActivated
        case mitochondrialIndex
        case rerEstimation
        case autophagyDepth
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
        static let isAMPKActivated = Column(CodingKeys.isAMPKActivated)
        static let mitochondrialIndex = Column(CodingKeys.mitochondrialIndex)
        static let rerEstimation = Column(CodingKeys.rerEstimation)
        static let autophagyDepth = Column(CodingKeys.autophagyDepth)
    }
}
