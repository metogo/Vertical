import ComposableArchitecture
import Foundation

struct HealthClient {
    var requestPermission: @Sendable () async -> Bool
    var heartRateStream: @Sendable () async -> AsyncStream<Double>
}

extension HealthClient: DependencyKey {
    static let liveValue = HealthClient(
        requestPermission: {
            // Implementation will use HealthKit
            return true
        },
        heartRateStream: {
            AsyncStream { continuation in
                // Real implementation would observe HKQuantityTypeIdentifierHeartRate
                continuation.finish()
            }
        }
    )
    
    static let testValue = HealthClient(
        requestPermission: { true },
        heartRateStream: { 
            AsyncStream { continuation in
                continuation.yield(75.0)
            }
        }
    )
    
    static let previewValue = HealthClient(
        requestPermission: { true },
        heartRateStream: {
            AsyncStream { continuation in
                Task {
                    var hr = 70.0
                    while true {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        hr += Double.random(in: -2...5)
                        continuation.yield(hr)
                    }
                }
            }
        }
    )
}

extension DependencyValues {
    var healthClient: HealthClient {
        get { self[HealthClient.self] }
        set { self[HealthClient.self] = newValue }
    }
}
