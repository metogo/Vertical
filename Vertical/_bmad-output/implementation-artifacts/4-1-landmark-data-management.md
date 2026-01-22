# Story 4.1: Landmark Data Management

Status: done

## Story

As a Product Owner,
I want to configure landmarks in a JSON file,
so that I can easily update goals without recompiling the core logic.

## Acceptance Criteria

1. **Given** A JSON configuration file (`landmarks.json`)
2. **When** The app launches or `LandmarkClient` is initialized
3. **Then** `LandmarkClient` loads the definitions (Name, Height, systemImage)
4. **And** The data is available to the rest of the app via Dependency.

## Tasks / Subtasks

- [x] Task 1: Create `landmarks.json` bundle resource.
- [x] Task 2: Update `Landmark` model to support Decodable.
- [x] Task 3: Implement `LandmarkClient` to parse JSON.
- [x] Task 4: Replace hardcoded `Landmark.samples` with dependency-delivered data in `TrackerReducer`. (Centralized in `AppReducer`)

## Dev Notes

- Place `landmarks.json` in the app's main bundle.
- Use `JSONDecoder` with proper coding keys if needed.

### References

- [Source: planning-artifacts/epics.md#Story 4.1: Landmark Data Management]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Created `landmarks.json` with 6 major landmarks including Eiffel Tower.
- Updated `Landmark` model to conform to `Codable`.
- Implemented `LandmarkClient` to load and decode the JSON configuration.
- Centralized landmark loading in `AppReducer` to ensure consistency between `Tracker` and `Timeline` views.
- Removed all hardcoded `Landmark.samples` usages in feature reducers.

### File List

- Vertical/Vertical/Vertical/Resources/landmarks.json
- Vertical/Vertical/Vertical/Sources/Models/Landmark.swift
- Vertical/Vertical/Vertical/Sources/Clients/LandmarkClient/LandmarkClient.swift
- Vertical/Vertical/Vertical/Sources/Features/Root/AppReducer.swift
- Vertical/Vertical/Vertical/Sources/Features/Tracker/TrackerReducer.swift
- Vertical/Vertical/Vertical/Sources/Features/Timeline/TimelineReducer.swift
