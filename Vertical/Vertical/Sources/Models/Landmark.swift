import Foundation

/// Represents a vertical landmark or milestone
struct Landmark: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let name: String
    let height: Double // in meters
    let systemImage: String // SF Symbol name
    let description: String
    let modelName: String? // Name of the 3D model file
    
    init(id: UUID = UUID(), name: String, height: Double, systemImage: String = "building.2", description: String = "", modelName: String? = nil) {
        self.id = id
        self.name = name
        self.height = height
        self.systemImage = systemImage
        self.description = description
        self.modelName = modelName
    }
}

extension Landmark {
    static let samples: [Landmark] = [
        Landmark(name: "Two-Story House", height: 8, systemImage: "house.fill", description: "A standard family home."),
        Landmark(name: "Ancient Tree", height: 25, systemImage: "leaf.fill", description: "A massive redwood or oak."),
        Landmark(name: "City Apartment", height: 45, systemImage: "building.fill", description: "A typical mid-rise building."),
        Landmark(name: "Statue of Liberty", height: 93, systemImage: "figure.stand", description: "A symbol of freedom in New York Harbor."),
        Landmark(name: "Great Pyramid of Giza", height: 138, systemImage: "triangle", description: "The oldest of the Seven Wonders of the Ancient World."),
        Landmark(name: "Eiffel Tower", height: 330, systemImage: "antenna.radiowaves.left.and.right", description: "The iron lady of Paris."),
        Landmark(name: "Empire State Building", height: 381, systemImage: "building.2.fill", description: "Iconic Art Deco skyscraper."),
        Landmark(name: "Burj Khalifa", height: 828, systemImage: "building", description: "The tallest structure in the world."),
        Landmark(name: "Mount Everest Base Camp", height: 5364, systemImage: "mountain.2.fill", description: "The gateway to the highest peak on Earth.")
    ].sorted(by: { $0.height < $1.height })
}
