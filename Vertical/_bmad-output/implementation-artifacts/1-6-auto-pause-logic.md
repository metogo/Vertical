# Story 1.6: Auto-Pause Logic

Status: done

## Story

As a User,
I want the app to ignore elevator rides,
so that my stats are legit.

## Acceptance Criteria

1. **Given** I am recording
2. **When** I step into an elevator (rapid pressure change + low acceleration noise)
3. **Then** The recording state switches to `.paused`
4. **And** A system notification triggers "High speed detected, pausing"

## Tasks / Subtasks

- [x] Task 1: Define Auto-Pause Detection Algorithm (AC: 2)
  - [x] Create `AutoPauseDetector` utility to analyze altitude change rate
  - [x] Define threshold: > 3 m/s vertical speed = potential elevator
  - [x] Require at least 2 consecutive readings above threshold to trigger
- [x] Task 2: Add Pause State to TrackerFeature (AC: 3)
  - [x] Add `isPaused` state property
  - [x] Add `autoPauseTriggered` / `resumeButtonTapped` actions
  - [x] Stop VAM calculation when paused but keep location alive
- [x] Task 3: Implement Notification (AC: 4)
  - [x] Create `NotificationClient` dependency
  - [x] Request notification permissions on first pause trigger
  - [x] Send local notification "High speed detected, pausing"
- [x] Task 4: UI Updates (AC: 3)
  - [x] Show paused indicator in TrackerView
  - [x] Add "Resume" button when paused
- [x] Task 5: Unit Tests (AC: 2, 3)
  - [x] Test auto-pause detection threshold
  - [x] Test state transitions: tracking -> paused -> tracking

## Dev Notes

- **Detection Strategy**: Simple threshold on altitude change rate. More sophisticated motion analysis (accelerometer) can be added later.
- **Vertical Speed**: Elevators typically move at 1-10 m/s. We use 3 m/s as a conservative threshold (faster than any human climb).
- **Debouncing**: Require 2 consecutive readings to avoid false positives from barometer noise.

### References

- [Source: planning-artifacts/epics.md#Story 1.6: Auto-Pause Logic]
- [Source: project-context.md#User Notifications]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Created `AutoPauseDetector` utility with 3 m/s threshold and 2 consecutive readings requirement.
- Added `isPaused` state and `autoPauseTriggered`/`resumeButtonTapped` actions to TrackerFeature.
- Created `NotificationClient` dependency for local notifications.
- Updated TrackerView with paused banner, status indicator, and Resume button.
- Added comprehensive unit tests for auto-pause detection and state transitions.
- [Review Fix] Fixed reading not being persisted when auto-pause triggers.
- [Review Fix] Added `hasRequestedNotificationPermission` state to avoid repeated permission requests.
- [Review Fix] Used localized strings for notification messages.
- [Review Fix] Added all preview dependencies to TrackerView preview.
- [Review Fix] Updated tests to use AutoPauseDetector constants instead of magic numbers.
- [Review Fix] Added `testPermissionOnlyRequestedOnce` test.
- [Review Fix] Added boundary value tests for AutoPauseDetector.

### File List

- Vertical/Vertical/Sources/Utilities/AutoPauseDetector.swift
- Vertical/Vertical/Sources/Clients/NotificationClient/NotificationClient.swift
- Vertical/Vertical/Sources/Features/Tracker/TrackerReducer.swift
- Vertical/Vertical/Sources/Features/Tracker/TrackerView.swift
- Vertical/Tests/FeatureTests/TrackerFeatureTests.swift
