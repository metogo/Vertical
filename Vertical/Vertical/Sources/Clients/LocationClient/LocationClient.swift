import ComposableArchitecture
import CoreLocation
import Foundation
import os.log

private let logger = Logger(subsystem: "com.vertical.location", category: "LocationClient")

@DependencyClient
struct LocationClient {
    /// Request permissions and start low-accuracy location updates to keep app alive in background.
    var startMonitoring: @Sendable () async -> Void
    /// Stop location updates.
    var stopMonitoring: @Sendable () async -> Void
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}

// MARK: - Implementation

/// Actor to safely manage CLLocationManager lifecycle on the main thread.
@MainActor
private final class LocationManagerHolder: NSObject, CLLocationManagerDelegate {
    private var manager: CLLocationManager?
    private var isMonitoring = false
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        // Lazy initialization to avoid crash if called prematurely
        if manager == nil {
            let m = CLLocationManager()
            m.delegate = self
            m.desiredAccuracy = kCLLocationAccuracyReduced
            
            // CRITICAL: Only enable background updates if we are on a real device and have the capability
            #if !targetEnvironment(simulator)
            m.allowsBackgroundLocationUpdates = true
            m.pausesLocationUpdatesAutomatically = false
            #endif
            
            self.manager = m
        }
        
        guard let manager = manager else { return }
        logger.info("Requesting location authorization and starting updates")
        
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
            isMonitoring = true
        } else {
            logger.warning("Location authorization denied or restricted")
        }
    }
    
    func stopMonitoring() {
        guard isMonitoring, let manager = manager else { return }
        logger.info("Stopping location updates")
        manager.stopUpdatingLocation()
        isMonitoring = false
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                logger.info("Location authorized, starting updates")
                manager.startUpdatingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            logger.error("Location manager error: \(error.localizedDescription)")
        }
    }
}

extension LocationClient: DependencyKey {
    static let liveValue: Self = {
        let holder = LocationManagerHolder()
        
        return Self(
            startMonitoring: {
                await holder.startMonitoring()
            },
            stopMonitoring: {
                await holder.stopMonitoring()
            }
        )
    }()
    
    static let testValue = Self(
        startMonitoring: { unimplemented("\(Self.self).startMonitoring") },
        stopMonitoring: { unimplemented("\(Self.self).stopMonitoring") }
    )
    
    static let previewValue = Self(
        startMonitoring: {},
        stopMonitoring: {}
    )
}
