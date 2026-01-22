# Story 1.3: Tracker Logic & VAM Calculation

Status: done

## Story

As a User,
I want to see my Vertical Ascent Speed (VAM),
so that I can gauge my intensity.

## Acceptance Criteria

1. **Given** A stream of altitude updates from `SensorClient`
2. **When** 10 seconds pass during a tracking session
3. **Then** The VAM (Vertical Ascent Meters per hour) is recalculated based on a rolling average of altitude changes
4. **And** The `TrackerFeature.State` updates with the new VAM value
5. **And** Horizontal distance/noise is filtered out (altitude-only calculation for now)

## Tasks / Subtasks

- [x] Task 1: Create `TrackerFeature` logic (AC: 1, 4)
  - [x] Define `TrackerFeature` Reducer with `vam` and `lastAltitude` state
  - [x] Implement `altitudeUpdate` action handler
- [x] Task 2: Implement VAM Calculation Algorithm (AC: 3, 5)
  - [x] Create a utility or helper to calculate rolling average VAM
  - [x] Implement a 10-second sliding window for calculation
  - [x] Format the output as Meters/Hour
- [x] Task 3: Unit Tests for VAM Logic (AC: 3)
  - [x] Test VAM calculation with a steady climb
  - [x] Test VAM calculation with descent (should handle or show negative/zero)
  - [x] Test noise filtering (no change in altitude = 0 VAM)
- [x] Task 4: UI Integration (AC: 4)
  - [x] Update `AppView` or create a new `TrackerView` to show the VAM value
  - [x] Add "Start/Stop" tracking capability to the state

## Dev Notes

- **VAM Calculation**: `(Altitude_now - Altitude_n_seconds_ago) / n_seconds * 3600`.
- **Sliding Window**: Store a history of readings or use a simple exponential moving average if complexity grows. For 10s, a small array of `(Date, Altitude)` pairs is sufficient.
- **Noise**: CoreMotion barometer is sensitive. Small fluctuations should not cause jumpy VAM.

### References

- [Source: planning-artifacts/epics.md#Story 1.3: Tracker Logic & VAM Calculation]
- [Source: project-context.md#Main Thread Blocking]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Created `TrackerFeature` to encapsulate tracking logic.
- Implemented a sliding window VAM algorithm (10s window).
- Built a premium `TrackerView` with a circular gauge design.
- Integrated `TrackerFeature` into `AppReducer` using `Scope`.
- Verified logic with comprehensive unit tests for climb and descent.
- [Review Fix] Removed unused `continuousClock` dependency.
- [Review Fix] Increased minimum calculation window to 3s and 3 readings for stability.
- [Review Fix] Extracted magic numbers into named constants.
- [Review Fix] Added accessibility identifiers to TrackerView.
- [Review Fix] Added missing noise filtering test.

### File List

- Vertical/Vertical/Sources/Features/Tracker/TrackerReducer.swift
- Vertical/Vertical/Sources/Features/Tracker/TrackerView.swift
- Vertical/Vertical/Sources/Features/Root/AppReducer.swift
- Vertical/Tests/FeatureTests/TrackerFeatureTests.swift
