# Story 6.1: Onboarding & Disclaimer

Status: done

## Story

As a Lawyer,
I want users to agree to risks,
So that we don't get sued for incidents during vertical sprints.

## Acceptance Criteria

1. **Given** First app launch
2. **When** The app opens
3. **Then** A full-screen onboarding/disclaimer appears
4. **And** "I AGREE" enables or proceeds to the dashboard
5. **And** The choice is persisted so it doesn't show again

## Tasks / Subtasks

- [x] Task 1: Create `UserDefaultClient` for persisting app state.
- [x] Task 2: Implement `OnboardingFeature` and `OnboardingView`.
- [x] Task 3: Design high-aesthetic onboarding with risk disclaimer.
- [x] Task 4: Integrate into `AppReducer` as a modal or root switch.

## Dev Notes

- Use `UserDefaults` for "hasAgreedToTerms".
- The UI should feel premium - dark mode, bold typography, maybe a subtle building silhouette in the background.

### References

- [Source: planning-artifacts/epics.md#Story 6.1: Onboarding & Disclaimer]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Created `UserDefaultClient` to persist user agreement.
- Implemented a premium `OnboardingView` with deep dark aesthetics, neon branding, and building silhouettes.
- Added a "Safety & Risk Disclaimer" that requires scrolling to bottom before the "I AGREE" button is enabled (via `onAppear` in the scroll box).
- Integrated the onboarding flow into the root `AppReducer`, ensuring it blocks app usage until terms are accepted.
  **Code Review Fixes (2026-01-19):**
- Fixed SwiftUI conflict where multiple `.fullScreenCover` on the same view caused issues.
- Added `interactiveDismissDisabled(true)` to ensure users cannot skip the disclaimer.
- Added `isInitialized` check to `AppReducer` to prevent redundant onboarding checks on view re-appearance.
- Completed the `UserDefaultClient.testValue` to support unit testing.

### File List

- Vertical/Vertical/Vertical/Sources/Clients/UserDefaultClient/UserDefaultClient.swift
- Vertical/Vertical/Vertical/Sources/Features/Onboarding/OnboardingFeature.swift
- Vertical/Vertical/Vertical/Sources/Features/Root/AppReducer.swift
