# Story 4.2: Progress & Unlocking Logic

Status: done

## Story

As a User,
I want to unlock buildings and see my progress,
so that I feel a sense of achievement during the climb.

## Acceptance Criteria

1. **Given** A list of landmarks from JSON
2. **When** I am climbing
3. **Then** The UI shows the next landmark goal and progress percentage
4. **And** When a landmark height is passed, show an "Unlocked" message/animation

## Tasks / Subtasks

- [x] Task 1: Add progress computation to `TrackerFeature.State`.
- [x] Task 2: Implement Progress UI in `TrackerView`.
- [x] Task 3: Implement "Unlocked" overlay/toast in `TrackerView`.
- [x] Task 4: Ensure the "Eiffel Tower" unlock at 300m works correctly.

## Dev Notes

- Progress = `(currentAltitude - currentLandmark.height) / (nextLandmark.height - currentLandmark.height)`
- Use a dedicated `ProgressView` or similar component.

### References

- [Source: planning-artifacts/epics.md#Story 4.2: Progress & Unlocking Logic]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Added `nextLandmark` and `progressToNextLandmark` computed properties to `TrackerFeature.State`.
- Implemented a sleek, neon-themed progress bar in `TrackerView` that shows progress between milestones.
- Created `UnlockedLandmarkOverlay` with a premium glassmorphic/gradient style to celebrate achievements.
- Implemented auto-dismissal logic (3 seconds) for the unlock message.
- Verified that reaching 330m (Eiffel Tower height in JSON) triggers the unlock sequence.

### File List

- Vertical/Vertical/Vertical/Sources/Features/Tracker/TrackerReducer.swift
- Vertical/Vertical/Vertical/Sources/Features/Tracker/TrackerView.swift
