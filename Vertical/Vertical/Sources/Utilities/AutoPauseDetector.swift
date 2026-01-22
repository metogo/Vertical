import Foundation

/// Detects when the user is in an elevator or other mechanical lift
/// by analyzing the rate of altitude change.
struct AutoPauseDetector: Sendable {
    
    /// Threshold for vertical speed (m/s) that indicates non-human climb
    /// Elevators typically move at 1-10 m/s. We use 3 m/s as conservative threshold.
    static let verticalSpeedThreshold: Double = 3.0
    
    /// Minimum consecutive readings above threshold to trigger pause
    static let consecutiveReadingsRequired: Int = 2
    
    /// Result of detection analysis
    enum DetectionResult: Equatable, Sendable {
        case normal
        case elevatorDetected
    }
    
    /// Analyze a series of readings to detect elevator movement
    /// - Parameter readings: Recent altitude readings (should be at least 2)
    /// - Returns: Detection result
    static func analyze(readings: [SensorReading]) -> DetectionResult {
        guard readings.count >= 2 else { return .normal }
        
        var consecutiveHighSpeed = 0
        
        for i in 1..<readings.count {
            let previous = readings[i - 1]
            let current = readings[i]
            
            let altitudeDelta = abs(current.relativeAltitude - previous.relativeAltitude)
            let timeDelta = current.timestamp.timeIntervalSince(previous.timestamp)
            
            guard timeDelta > 0 else { continue }
            
            let verticalSpeed = altitudeDelta / timeDelta
            
            if verticalSpeed >= verticalSpeedThreshold {
                consecutiveHighSpeed += 1
                if consecutiveHighSpeed >= consecutiveReadingsRequired {
                    return .elevatorDetected
                }
            } else {
                consecutiveHighSpeed = 0
            }
        }
        
        return .normal
    }
}
