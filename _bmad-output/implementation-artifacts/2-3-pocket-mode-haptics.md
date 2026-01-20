# Story 2.3: Pocket Mode Haptics

Status: done

## Story

As a User,
I want to feel my progress,
so that I don't have to look at the screen.

## Acceptance Criteria

1. **Given** Tracking is active
2. **When** I climb 1 floor (3 meters)
3. **Then** A heavy haptic impact plays
4. **And** When I reach a landmark, a double pulse plays

## Tasks / Subtasks

- [x] Task 1: Create HapticClient Dependency (AC: 1)
  - [x] Implement `HapticClient` with methods for `playImpact` and `playNotification`.
- [x] Task 2: Integrate Haptics into TrackerFeature (AC: 2, 3, 4)
  - [x] Add `isHapticEnabled` and `lastHapticAltitude` to `TrackerFeature.State`.
  - [x] Implemented logic to trigger heavy impact every 3m (1 floor).
  - [x] Added `reachedLandmarkIds` to prevent duplicate pulses for the same landmark milestones.
- [x] Task 3: UI Controls (AC: 1)
  - [x] Added a toggle in `TrackerView` for "Haptics" (Pocket Mode).
- [x] Task 4: Unit Tests (AC: 3, 4)
  - [x] Added successful tests for 3m climb haptics.
  - [x] Added successful tests for landmark crossing haptics.

## Dev Notes

- **Haptic Styles**:
  - 3m climb: `.impact(.heavy)`
  - Landmark: `.notification(.success)` or custom double pulse.
- **State Management**: We need to persist `lastHapticAltitude` in the state to ensure haptics are consistent even if readings are irregular.
- **Landmarks**: Use the `Landmark.samples` list to check for crossings during climbing.

### References

- [Source: planning-artifacts/epics.md#Story 2.3: Pocket Mode Haptics]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Created `HapticClient` wrapping `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`.
- Implemented cumulative altitude tracking (`lastHapticAltitude`) to trigger a heavy haptic impact every 3 meters of ascent.
- Added landmark crossing detection that triggers a `.success` notification pulse (double pulse) when reaching a milestone (e.g., Eiffel Tower height).
- User can toggle "Pocket Mode" haptics directly from the `TrackerView`.
- Verified all haptic logic via `TrackerFeatureTests.swift`.
- [Review Fix] Added `prepare()` call before haptic feedback to reduce latency.
- [Review Fix] Reset `lastHapticAltitude` on descent to ensure proper tracking after descending then re-climbing.
- [Review Fix] Localized "HAPTICS ON/OFF" strings.
- [Review Fix] Extracted `makeSaveEffect()` helper to reduce code duplication.
- [Review Fix] Added `testHapticFeedbackDescentThenClimb` test case.

### File List

- Vertical/Vertical/Sources/Clients/HapticClient/HapticClient.swift
- Vertical/Vertical/Sources/Features/Tracker/TrackerReducer.swift
- Vertical/Vertical/Sources/Features/Tracker/TrackerView.swift
- Vertical/Tests/FeatureTests/TrackerFeatureTests.swift
