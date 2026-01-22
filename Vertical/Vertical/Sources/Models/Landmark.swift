import Foundation

/// Represents a vertical landmark or milestone
struct Landmark: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let name: String
    let height: Double // in meters
    let systemImage: String // SF Symbol name
    
    init(id: UUID = UUID(), name: String, height: Double, systemImage: String = "building.2") {
        self.id = id
        self.name = name
        self.height = height
        self.systemImage = systemImage
    }
}

extension Landmark {
    static let samples: [Landmark] = [
        Landmark(name: "Statue of Liberty", height: 93, systemImage: "figure.stand"),
        Landmark(name: "Great Pyramid of Giza", height: 138, systemImage: "triangle"),
        Landmark(name: "Eiffel Tower", height: 330, systemImage: "antenna.radiowaves.left.and.right"),
        Landmark(name: "Empire State Building", height: 381, systemImage: "building.2.fill"),
        Landmark(name: "Burj Khalifa", height: 828, systemImage: "building"),
        Landmark(name: "Mount Everest Base Camp", height: 5364, systemImage: "mountain.2.fill")
    ].sorted(by: { $0.height < $1.height })
}
