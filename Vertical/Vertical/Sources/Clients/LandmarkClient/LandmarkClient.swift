import ComposableArchitecture
import Foundation

@DependencyClient
struct LandmarkClient: Sendable {
    var loadLandmarks: @Sendable () async throws -> [Landmark]
}

extension LandmarkClient: DependencyKey {
    static let liveValue = Self(
        loadLandmarks: {
            guard let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") else {
                throw LandmarkClientError.resourceNotFound
            }
            let data = try Data(contentsOf: url)
            let landmarks = try JSONDecoder().decode([Landmark].self, from: data)
            return landmarks.sorted(by: { $0.height < $1.height })
        }
    )
    
    static let testValue = Self(
        loadLandmarks: {
            Landmark.samples
        }
    )
}

enum LandmarkClientError: Error {
    case resourceNotFound
}

extension DependencyValues {
    var landmarkClient: LandmarkClient {
        get { self[LandmarkClient.self] }
        set { self[LandmarkClient.self] = newValue }
    }
}
