# Story 1.2: Core Motion Barometer Integration

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a User,
I want the app to read my altitude changes,
so that I can track my climb.

## Acceptance Criteria

1. **Given** `SensorClient.liveValue` is active
2. **When** The device changes altitude on a real device (or simulated via CSV)
3. **Then** The `altitudeStream` yields new `SensorReading` values with timestamp, pressure, and relative altitude
4. **And** Errors (e.g., `CMErrorDomain`, `Device Not Supported`) are gracefully handled (e.g., stream terminates or yields error state)

## Tasks / Subtasks

- [x] Task 1: Implement `SensorClient.liveValue` with `CMAltimeter` (AC: 1, 3)
  - [x] Import `CoreMotion` in Live implementation
  - [x] Implement `startRelativeAltitudeUpdates(to:withHandler:)` inside the AsyncStream
  - [x] Map `CMAltitudeData` to domain `SensorReading` struct
  - [x] Ensure `onTermination` stops updates
- [x] Task 2: Implement Error Handling (AC: 4)
  - [x] Check `CMAltimeter.isRelativeAltitudeAvailable()`
  - [x] Handle `stopRelativeAltitudeUpdates` cleanup
- [x] Task 3: Implement `SensorClient.mock` for replay (AC: 2)
  - [x] Create a mechanism to replay a recorded CSV of altitude data in `previewValue` or `testValue`
  - [x] Ensure Previews show dynamic (moving) data
- [x] Task 4: Integrate into `TrackerFeature` (AC: 3)
  - [x] Create `TrackerFeature` (if not exists) or update `AppReducer` to consume the stream
  - [x] Display raw altitude data on screen for debugging

## Dev Notes

- **Hardware Dependency**: `CMAltimeter` only works on physical devices. Simulator requires the Mock/Replay mechanism.
- **Concurrency**: Use `AsyncStream` bridging. Be careful with `OperationQueue` contexts from `CoreMotion`.
- **Permissions**: Ensure `NSMotionUsageDescription` is in Info.plist (Completed in 1.1).

### References

- [Source: planning-artifacts/epics.md#Story 1.2: Core Motion Barometer Integration]
- [Source: project-context.md#Sensor Mocking]

## Dev Agent Record

### Agent Model Used

Antigravity (simulated)

### Debug Log References

- [Log] Implemented `CMAltimeter` integration in `SensorClient.liveValue`.
- [Log] Added dynamic mocking capability to `previewValue` for SwiftUI Previews.
- [Log] Updated `AppReducer` to consume altitude stream and display real-time values.

### Completion Notes List

- Implemented real-time altitude tracking using CoreMotion.
- Decoupled hardware access via TCA DependencyClient.
- Verified logic with Unit Tests in `AppReducerTests.swift`.
- [Refactor] Updated `AppReducer` Action naming to follow `view/internal` convention.
- [Fix] Moved Altimeter updates to background queue to prevent main thread blocking.
- [Fix] Fixed singleton capture issue in `liveValue`.
- [Fix] Corrected typo in `Interface.swift`.
- [Improvement] Enhanced `Mock.swift` with full CSV replay support.
- [Test] Improved test stability by removing hardcoded sleeps.

### File List

- Vertical/Vertical/Sources/Clients/SensorClient/Interface.swift
- Vertical/Vertical/Sources/Clients/SensorClient/Live.swift
- Vertical/Vertical/Sources/Clients/SensorClient/Mock.swift
- Vertical/Vertical/Sources/Features/Root/AppReducer.swift
- Vertical/Tests/FeatureTests/AppReducerTests.swift
- \_bmad-output/implementation-artifacts/sprint-status.yaml
- \_bmad-output/implementation-artifacts/1-2-core-motion-barometer-integration.md
