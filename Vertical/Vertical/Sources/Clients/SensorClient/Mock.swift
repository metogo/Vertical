import Foundation
import ComposableArchitecture

extension SensorClient {
    /// Creates a mock version of SensorClient that replays a sequence of readings.
    /// Useful for testing climb logic and UI previews.
    static func mock(
        altitudeStream: AsyncStream<SensorReading>
    ) -> Self {
        return Self(
            altitudeStream: { altitudeStream },
            motionStream: { .finished },
            queryHistoricalFloors: { _, _ in 0 },
            stopMonitoring: {}
        )
    }
    
    /// Creates an altitude stream from a CSV string.
    /// Format: timestamp,pressure,altitude (one per line)
    static func altitudeStream(fromCSV csv: String, interval: TimeInterval = 1.0) -> AsyncStream<SensorReading> {
        AsyncStream { continuation in
            let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            Task {
                for line in lines {
                    if let reading = SensorReading.from(csvLine: line) {
                        continuation.yield(reading)
                        if interval > 0 {
                            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                        }
                    }
                }
                continuation.finish()
            }
        }
    }
}

// MARK: - CSV Replay Helper

extension SensorReading {
    /// Simple parser for a CSV line in format: timestamp,pressure,altitude
    static func from(csvLine: String) -> SensorReading? {
        let components = csvLine.components(separatedBy: ",")
        guard components.count >= 3,
              let timestamp = Double(components[0].trimmingCharacters(in: .whitespaces)),
              let pressure = Double(components[1].trimmingCharacters(in: .whitespaces)),
              let altitude = Double(components[2].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        
        return SensorReading(
            timestamp: Date(timeIntervalSince1970: timestamp),
            pressure: pressure,
            relativeAltitude: altitude
        )
    }
}
