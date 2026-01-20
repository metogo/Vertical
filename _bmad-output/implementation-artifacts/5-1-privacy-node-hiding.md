# Story 5.1: Privacy Node Hiding

Status: done

## Story

As a User,
I want to hide my home location in the 3D visualization,
so that I can share my results safely without revealing where I live or work.

## Acceptance Criteria

1. **Given** A completed workout with 3D path data
2. **When** I toggle "Privacy Mode" or "Hide Start/End" in the Result view
3. **Then** The first and last segments of the 3D spiral are hidden
4. **And** The total altitude statistics remain accurate

## Tasks / Subtasks

- [x] Task 1: Add `isPrivacyModeEnabled` to `ResultFeature.State`.
- [x] Task 2: Implement Privacy Toggle in `ResultView`.
- [x] Task 3: Update `SpiralRenderer` to support data clipping. (Done by filtering inputs)
- [x] Task 4: Connect the toggle to the renderer update logic. (Via `.id(isPrivacyModeEnabled)`)

## Dev Notes

- Since we don't store GPS coordinates (for privacy), "Hide Start/End" will clip a fixed time-based or index-based percentage (e.g., first and last 30 seconds or 10% of points) to obscure the beginning and end of the climb.
- Implementation: Filter the `readings` array passed to `SpiralRenderer`.

### References

- [Source: planning-artifacts/epics.md#Story 5.1: Privacy Node Hiding]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Added `isPrivacyModeEnabled` to `ResultFeature` and a high-aesthetic orange toggle in `ResultView`.
- Implemented `visibleReadings` computed property that clips the first and last 10% of the movement path when Privacy Mode is active.
- Integrated the toggle with `SpiralContainerView`, using the `.id()` modifier to force a fresh Metal rendering when privacy settings change.
- Ensured total statistics (Total Climb) remain accurate even when the visualization is clipped, as required by the PRD.

**Code Review Fixes (2026-01-19):**

- Added boundary check to ensure at least 2 visible readings after clipping.
- Removed unused `maxVam` variable from `ResultFeature.State`.

### File List

- Vertical/Vertical/Vertical/Sources/Features/Result/ResultFeature.swift
