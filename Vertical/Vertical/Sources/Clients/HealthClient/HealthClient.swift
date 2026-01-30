import ComposableArchitecture
import Foundation
import HealthKit

struct HealthClient {
    var requestPermission: @Sendable () async -> Bool
    var heartRateStream: @Sendable () async -> AsyncStream<Double>
    /// Fetch flights climbed in a specific time range
    var fetchFloorsClimbed: @Sendable (Date, Date) async throws -> Int
    /// Observe changes in HealthKit data in the background
    var observeHealthDataChanges: @Sendable () async -> AsyncStream<Void>
}

extension HealthClient: DependencyKey {
    static let liveValue: HealthClient = {
        let healthStore = HKHealthStore()
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let floorsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        
        return HealthClient(
            requestPermission: {
                guard HKHealthStore.isHealthDataAvailable() else { return false }
                let types: Set = [heartRateType, floorsType]
                do {
                    try await healthStore.requestAuthorization(toShare: [], read: types)
                    return true
                } catch {
                    return false
                }
            },
            heartRateStream: {
                AsyncStream { continuation in
                    let query = HKAnchoredObjectQuery(
                        type: heartRateType,
                        predicate: nil,
                        anchor: nil,
                        limit: HKObjectQueryNoLimit
                    ) { _, samples, _, _, _ in
                        if let quantitySample = samples?.last as? HKQuantitySample {
                            let hr = quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                            continuation.yield(hr)
                        }
                    }
                    
                    query.updateHandler = { _, samples, _, _, _ in
                        if let quantitySample = samples?.last as? HKQuantitySample {
                            let hr = quantitySample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                            continuation.yield(hr)
                        }
                    }
                    
                    healthStore.execute(query)
                    
                    continuation.onTermination = { _ in
                        healthStore.stop(query)
                    }
                }
            },
            fetchFloorsClimbed: { from, to in
                let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
                
                return try await withCheckedThrowingContinuation { continuation in
                    let query = HKStatisticsQuery(
                        quantityType: floorsType,
                        quantitySamplePredicate: predicate,
                        options: .cumulativeSum
                    ) { _, result, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            let sum = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                            continuation.resume(returning: Int(sum))
                        }
                    }
                    healthStore.execute(query)
                }
            },
            observeHealthDataChanges: {
                AsyncStream { continuation in
                    let query = HKObserverQuery(sampleType: floorsType, predicate: nil) { _, completionHandler, error in
                        if error == nil {
                            continuation.yield(())
                        }
                        completionHandler()
                    }
                    
                    healthStore.execute(query)
                    healthStore.enableBackgroundDelivery(for: floorsType, frequency: .immediate) { _, _ in }
                    
                    continuation.onTermination = { _ in
                        healthStore.stop(query)
                    }
                }
            }
        )
    }()
    
    static let testValue = HealthClient(
        requestPermission: { true },
        heartRateStream: { 
            AsyncStream { continuation in
                continuation.yield(75.0)
            }
        },
        fetchFloorsClimbed: { _, _ in 10 },
        observeHealthDataChanges: { .finished }
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
        },
        fetchFloorsClimbed: { _, _ in 5 },
        observeHealthDataChanges: { .finished }
    )
}

extension DependencyValues {
    var healthClient: HealthClient {
        get { self[HealthClient.self] }
        set { self[HealthClient.self] = newValue }
    }
}
