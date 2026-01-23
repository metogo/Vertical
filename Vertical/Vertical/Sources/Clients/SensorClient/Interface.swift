import ComposableArchitecture
import CoreMotion
import Foundation

/// A client interface for interacting with device sensors (Altimeter, Motion).
/// Decouples the feature logic from CoreMotion hardware.
@DependencyClient
struct SensorClient {
    /// Start monitoring altitude changes.
    /// Returns an AsyncStream of altitude data.
    var altitudeStream: @Sendable () async -> AsyncStream<SensorReading> = { .finished }
    
    /// Start monitoring motion activity (steps, flooring).
    var motionStream: @Sendable () async -> AsyncStream<MotionReading> = { .finished }
    
    /// Query historical pedometer data for a specific time range.
    var queryHistoricalFloors: @Sendable (Date, Date) async throws -> Int = { _, _ in 0 }
    
    /// Stop all sensor monitoring.
    var stopMonitoring: @Sendable () async -> Void
}

extension DependencyValues {
    var sensorClient: SensorClient {
        get { self[SensorClient.self] }
        set { self[SensorClient.self] = newValue }
    }
}

// MARK: - Models

struct SensorReading: Equatable, Sendable, Codable {
    let timestamp: Date
    let pressure: Double // kPa
    let relativeAltitude: Double // meters
}

struct MotionReading: Equatable, Sendable {
    let timestamp: Date
    let userAcceleration: Double // G-force
    let isStationary: Bool
}
