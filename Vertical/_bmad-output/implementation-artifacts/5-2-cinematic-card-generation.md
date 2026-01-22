# Story 5.2: Cinematic Card Generation

Status: done

## Story

As a User,
I want to share a cinematic, high-quality image of my climb to social media,
so that I can show off my achievements with an aesthetic that matches the app.

## Acceptance Criteria

1. **Given** A workout result view
2. **When** I tap the "Share" button
3. **Then** a high-resolution "Cinematic Card" is generated off-screen
4. **And** The system sharing sheet (`UIActivityViewController`) appears containing the image

## Tasks / Subtasks

- [x] Task 1: Create `CinematicCardView` for high-end sharing layout.
- [x] Task 2: Implement image generation logic (using `ImageRenderer`).
- [x] Task 3: Handle Metal snapshotting if needed (Simplified 2D stats representation for the card).
- [x] Task 4: Add `shareButtonTapped` to `ResultFeature` and show activity sheet.

## Dev Notes

- Use `ImageRenderer` in SwiftUI.
- The card should have a dark, sleek background with neon accents.
- Include the building mascot or landmark name in the card.

### References

- [Source: planning-artifacts/epics.md#Story 5.2: Cinematic Card Generation]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Created a premium `CinematicCardView` with dark aesthetic, neon gradients, and bold typography optimized for social sharing.
- Implemented `ShareClient` using `UIActivityViewController` to trigger the system share sheet.
- Integrated `ImageRenderer` (SwiftUI) to generate a high-resolution (3x) image of the cinematic card off-screen.
- Automatically detects the highest landmark reached during the session and highlights it on the shared card.
- Added a "Share" icon button to the `ResultView` header for easy access.

**Code Review Fixes (2026-01-19):**

- Added `testValue` and `previewValue` to `ShareClient` to prevent unit test crashes.
- Replaced non-existent SF Symbol `pinnacle.fill` with valid `arrow.up.forward.app.fill`.
- Fixed unstructured concurrency by removing nested `Task` in `shareButtonTapped`.
- Updated `LandmarkClient` to use `Bundle.main.url` instead of hardcoded absolute path.

### File List

- Vertical/Vertical/Vertical/Sources/Features/Result/CinematicCardView.swift
- Vertical/Vertical/Vertical/Sources/Clients/ShareClient/ShareClient.swift
- Vertical/Vertical/Vertical/Sources/Features/Result/ResultFeature.swift
