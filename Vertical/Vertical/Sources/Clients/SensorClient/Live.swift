import ComposableArchitecture
import CoreMotion
import Foundation

extension SensorClient: DependencyKey {
    static let liveValue = {
        return SensorClient(
            altitudeStream: {
                // Ensure Motion Permissions are requested by touching Pedometer
                // CMAltimeter alone sometimes doesn't trigger the prompt on fresh installs
                let pedometer = CMPedometer()
                if CMPedometer.isStepCountingAvailable() {
                    pedometer.queryPedometerData(from: Date(), to: Date()) { _, _ in }
                }
                
                if CMAltimeter.isRelativeAltitudeAvailable() {
                    // REAL DEVICE: Use actual barometer
                    print("✅ Barometer available. Starting live updates.")
                    return AsyncStream { continuation in
                        let altimeter = CMAltimeter()
                        let queue = OperationQueue()
                        queue.name = "com.vertical.sensor.queue"
                        
                        altimeter.startRelativeAltitudeUpdates(to: queue) { data, error in
                            if let error = error {
                                print("❌ Altimeter Error: \(error.localizedDescription)")
                                return
                            }
                            
                            if let data = data {
                                let reading = SensorReading(
                                    timestamp: Date(),
                                    pressure: data.pressure.doubleValue,
                                    relativeAltitude: data.relativeAltitude.doubleValue
                                )
                                continuation.yield(reading)
                            }
                        }
                        
                        // Keep altimeter alive via the termination handler capture
                        continuation.onTermination = { _ in
                            altimeter.stopRelativeAltitudeUpdates()
                        }
                    }
                } else {
                    // SIMULATOR: Use GCD timer for reliable demo mode
                    print("⚠️ Barometer not available. Entering Simulator Demo Mode.")
                    return AsyncStream { continuation in
                        var currentAlt = 0.0
                        
                        // Yield initial reading immediately
                        continuation.yield(SensorReading(timestamp: Date(), pressure: 101.3, relativeAltitude: 0))
                        
                        // Use GCD timer - most reliable across all contexts
                        let timer = DispatchSource.makeTimerSource(queue: .main)
                        timer.schedule(deadline: .now() + 0.5, repeating: 0.5)
                        timer.setEventHandler {
                            currentAlt += 0.75
                            let reading = SensorReading(
                                timestamp: Date(),
                                pressure: 101.3,
                                relativeAltitude: currentAlt
                            )
                            print("📍 Demo: \(String(format: "%.1f", currentAlt))m")
                            continuation.yield(reading)
                        }
                        timer.resume()
                        
                        continuation.onTermination = { _ in
                            timer.cancel()
                        }
                    }
                }
            },
            motionStream: {
                AsyncStream { continuation in
                    continuation.finish()
                }
            },
            queryHistoricalFloors: { from, to in
                let pedometer = CMPedometer()
                guard CMPedometer.isStepCountingAvailable() else { return 0 }
                
                return try await withCheckedThrowingContinuation { continuation in
                    pedometer.queryPedometerData(from: from, to: to) { data, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data {
                            let floors = data.floorsAscended?.intValue ?? 0
                            continuation.resume(returning: floors)
                        } else {
                            continuation.resume(returning: 0)
                        }
                    }
                }
            },
            stopMonitoring: {}
        )
    }()
    
    static let testValue = SensorClient()
    
    static let previewValue = SensorClient(
        altitudeStream: {
            AsyncStream { continuation in
                Task {
                    for i in 0..<100 {
                        continuation.yield(
                            SensorReading(
                                timestamp: Date(),
                                pressure: 101.3 - Double(i) * 0.01,
                                relativeAltitude: Double(i) * 0.5
                            )
                        )
                        try? await Task.sleep(nanoseconds: 500_000_000)
                    }
                    continuation.finish()
                }
            }
        },
        motionStream: {
            AsyncStream { continuation in
                continuation.finish()
            }
        },
        stopMonitoring: {}
    )
}
