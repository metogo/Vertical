# Story 2.1: Vertical Axis Navigation

Status: done

## Story

As a User,
I want to scroll a vertical ruler,
so that I can feel the scale of the height.

## Acceptance Criteria

1. **Given** The Home Screen
2. **When** I scroll vertically
3. **Then** The ruler moves with inertial scrolling
4. **And** Landmarks appear at correct relative positions

## Tasks / Subtasks

- [x] Task 1: Design Vertical Ruler Component (AC: 1, 3)
  - [x] Implement a custom `ScrollView` or `List` that looks like a ruler
  - [x] Add tick marks every 1m and major labels every 10m
  - [x] Ensure smooth inertial scrolling
- [x] Task 2: Implement Landmark Display (AC: 4)
  - [x] Define `Landmark` model
  - [x] Create `LandmarkView` to display milestones on the ruler
  - [x] Position landmarks correctly based on their altitude
- [x] Task 3: Integrate into Home Screen (AC: 1)
  - [x] Update `AppView` or create a new `TimelineView`
  - [x] Link the current altitude from `TrackerFeature` to the ruler's scroll position
- [x] Task 4: Unit/UI Tests (AC: 3, 4)
  - [x] Verify landmark positioning logic
  - [x] Test scroll synchronization

## Dev Notes

- **Aesthetics**: The ruler should feel premium. Use thin lines, subtle gradients, and a monospace font for height numbers.
- **Auto-follow**: When tracking is active, the ruler should automatically scroll to keep the current altitude centered or at a specific marker.
- **Landmarks**: For now, hardcode a few famous landmarks (Eiffel Tower 300m, etc.) until Story 4.1.

### References

- [Source: planning-artifacts/epics.md#Story 2.1: Vertical Axis Navigation]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Created `Landmark` model with sample famous landmarks.
- Developed `TimelineView` featuring a detailed vertical ruler (0-6000m).
- Implemented `ScrollViewReader` synchronization to automatically scroll to the current altitude.
- Added a "Current Altitude HUD" that remains fixed while the ruler scrolls.
- Integrated `TimelineFeature` into `AppReducer` for real-time data flow from `TrackerFeature`.
- Added unit tests for altitude synchronization and timeline state management.
- [Review Fix] Optimized ruler from 6000+ views to ~600 views (render every 10m instead of every 1m).
- [Review Fix] Extracted magic numbers to `TimelineConfiguration` enum.
- [Review Fix] Renamed `iconName` to `systemImage` and display SF Symbols in landmarks.
- [Review Fix] Added accessibility identifiers to all interactive elements.
- [Review Fix] Pre-computed landmark positions in State for efficient rendering.
- [Review Fix] Added `testLandmarkPositionsPrecomputed` and `TimelineConfigurationTests`.

### File List

- Vertical/Vertical/Sources/Models/Landmark.swift
- Vertical/Vertical/Sources/Features/Timeline/TimelineReducer.swift
- Vertical/Vertical/Sources/Features/Timeline/TimelineView.swift
- Vertical/Vertical/Sources/Features/Root/AppReducer.swift
- Vertical/Tests/FeatureTests/TimelineTests.swift
