# Story 1.1: Project Scaffold & Dependency Injection

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a Developer,
I want to set up the Xcode Service and Dependency Injection,
so that feature development is decoupled from hardware.

## Acceptance Criteria

1. **Given** A new Xcode project configured with TCA
2. **When** I access `DependencyValues.sensorClient`
3. **Then** It returns a mock value in previews and live value in simulater/device
4. **And** The app compiles without Strict Concurrency warnings

## Tasks / Subtasks

- [ ] Task 1: Initialize Xcode Project and Folder Structure (AC: 1, 4)
  - [ ] Create new Xcode project 'Vertical' (iOS App, SwiftUI, Swift)
  - [x] Configure `Info.plist` for Background Modes (Location updates, Background processing)
  - [x] Create folder structure matching Architecture.md (Sources/App, Features, Clients, DesignSystem, etc.)
  - [x] Add `.swiftlint.yml` configuration standardizing rules
- [ ] Task 2: Configure Dependencies and SPM (AC: 1)
  - [ ] Add `swift-composable-architecture` (TCA) via SPM
  - [ ] Add `GRDB.swift` via SPM
  - [ ] Ensure all packages resolve and build
- [x] Task 3: Implement Initial Dependency Injection (AC: 2, 3)
  - [x] Define `SensorClient` interface struct (actions: start, stop, stream)
  - [x] Implement `SensorClient.liveValue` (placeholder logging)
  - [x] Implement `SensorClient.testValue` (unimplemented)
  - [x] Implement `SensorClient.previewValue` (static mock)
  - [x] Register `SensorClient` in `DependencyValues` extension
- [x] Task 4: Setup App Entry Point (AC: 1)
  - [x] Implement `VerticalApp.swift`
  - [x] Implement `AppReducer` (Root Feature)
  - [ ] Verify App compiles and runs on Simulator

## Dev Notes

- **Architecture**: The Composable Architecture (TCA) 1.x
- **Concurrency**: Enable Strict Concurrency Checking (Swift 6)
- **Dependency**: Use `@Dependency(\.sensorClient)` pattern
- **Folder Structure**: STRICTLY follow `Sources/Clients/SensorClient`, `Sources/Features/Root`

### Project Structure Notes

- **Sources/App**: `VerticalApp.swift`, `AppReducer.swift`
- **Sources/Clients**: `SensorClient/Interface.swift`, `SensorClient/Live.swift`
- **Sources/Features**: `Root/RootFeature.swift`

### References

- [Source: planning-artifacts/architecture.md#Project Directory Structure]
- [Source: planning-artifacts/project-context.md#Framework-Specific Rules (TCA & SwiftUI)]

## Dev Agent Record

### Agent Model Used

Antigravity (simulated)

### Debug Log References

### Completion Notes List

### File List

- .swiftlint.yml
- Vertical/Resources/Info.plist
- Vertical/Sources/Clients/SensorClient/Interface.swift
- Vertical/Sources/Clients/SensorClient/Live.swift
- Vertical/Sources/Features/Root/AppReducer.swift
- Vertical/Sources/App/VerticalApp.swift
