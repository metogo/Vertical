# Story 2.2: Live HUD Overlay

Status: done

## Story

As a User,
I want to see big neon numbers,
so that I can read stats while running.

## Acceptance Criteria

1. **Given** I am in a workout
2. **When** My VAM changes
3. **Then** The HUD number updates with a "slot machine" animation
4. **And** The color shifts from Blue (Idle) to Pink (Peak)

## Tasks / Subtasks

- [x] Task 1: Implement Rolling Number Animation (AC: 3)
  - [x] Create `RollingNumberView` to split an integer into digits and animate vertical scrolling.
  - [x] Support variable number of digits.
- [x] Task 2: Implement Dynamic Color System (AC: 4)
  - [x] Define VAM color mapping (0 -> Blue, 1200 -> Pink/Neon).
  - [x] Apply color to VAM display and gauge.
- [x] Task 3: Enhance TrackerView Styling (AC: 2)
  - [x] Refine "Neon" look with shadows and glows.
- [x] Task 4: UI Verification (AC: 3, 4)
  - [x] Verify animations in Preview.

## Dev Notes

- **Slot Machine Effect**: Use `contentTransition(.numericText())` if targetting iOS 17+, or a custom implementation for more control. Since we want a "wow" factor, a custom component might be better for that specific "slot machine" feel.
- **Neon Aesthetic**: High contrast colors, blur effects for glows.
- **VAM Peak**: Let's assume a peak of 1200 m/h for color shifting (typical pro cycling ascent rate).

### References

- [Source: planning-artifacts/epics.md#Story 2.2: Live HUD Overlay]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Implemented `RollingNumberView` with a vertical scroll animation for each digit, creating a classic "slot machine" effect.
- Added a dynamic color system that transitions from Blue (0 VAM) to Purple and then Pink (1200+ VAM) as the user climbs faster.
- Enhanced `TrackerView` with neon glows and a circular progress-style gauge that tracks VAM intensity.
- Integrated the new animation and color system into the main tracker display.
- [Review Fix] Added dynamic digit width calculation based on font size.
- [Review Fix] Added minimum digit padding (4 digits) to prevent layout jumps.
- [Review Fix] Added `.clipped()` to DigitView to prevent overflow.
- [Review Fix] Extracted magic number `1200` to `RollingNumberConfiguration.peakVam`.
- [Review Fix] Implemented smooth HSB color interpolation via `Color.interpolate(from:to:ratio:)`.

### File List

- Vertical/Vertical/Sources/Features/Tracker/RollingNumberView.swift
- Vertical/Vertical/Sources/Features/Tracker/TrackerView.swift
