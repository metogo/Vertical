# Story 1.5: GRDB Data Persistence

Status: done

## Story

As a User,
I want my data saved automatically,
so that I don't lose it if the app crashes.

## Acceptance Criteria

1. **Given** Sensor data is arriving
2. **When** A new reading arrives
3. **Then** It is inserted into the `SensorReadings` SQLite table
4. **And** The write happens on a background actor

## Tasks / Subtasks

- [x] Task 1: Add GRDB Dependency (AC: 3)
  - [x] Add GRDB package to project dependencies
  - [x] Verify package resolves correctly
- [x] Task 2: Create Database Schema (AC: 3)
  - [x] Define `SensorReadingRecord` conforming to `Codable`, `FetchableRecord`, `PersistableRecord`
  - [x] Create migration for `sensor_readings` table
  - [x] Add indexes for timestamp queries
- [x] Task 3: Create DatabaseClient Dependency (AC: 3, 4)
  - [x] Define `DatabaseClient` interface with `save(_ reading:)` and `fetchAll()` methods
  - [x] Implement `liveValue` with database writer on background actor
  - [x] Implement `testValue` and `previewValue`
- [x] Task 4: Integrate into TrackerFeature (AC: 1, 2)
  - [x] Inject `DatabaseClient` into TrackerFeature
  - [x] Save each altitude reading as it arrives
- [x] Task 5: Unit Tests (AC: 3, 4)
  - [x] Test database write and read operations
  - [x] Test that writes happen asynchronously (non-blocking)

## Dev Notes

- **GRDB Choice**: GRDB is the recommended SQLite wrapper for Swift. It's Sendable-safe and works well with Swift Concurrency.
- **Background Actor**: GRDB's `DatabasePool` handles background writes automatically. We just need to ensure our `DatabaseClient` is Sendable.
- **Schema Design**: Start simple. `sensor_readings(id, timestamp, pressure, relativeAltitude)`. Can add session_id later.

### References

- [Source: planning-artifacts/epics.md#Story 1.5: GRDB Data Persistence]
- [Source: project-context.md#GRDB]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Added GRDB 6.24.0 package dependency to Xcode project.
- Created `SensorReadingRecord` model conforming to GRDB protocols.
- Implemented `AppDatabase` actor with migrations and CRUD operations.
- Created `DatabaseClient` TCA dependency with live, test, and preview values.
- Integrated `DatabaseClient` into `TrackerFeature` to persist every altitude reading.
- Added comprehensive unit tests for database operations.
- [Review Fix] Removed force unwrap from AppDatabase.shared with fallback to in-memory.
- [Review Fix] Added guard for Application Support URL path creation.
- [Review Fix] Added error logging instead of silent error swallowing.
- [Review Fix] Added sessionId field to schema for grouping readings by session.
- [Review Fix] Fixed test exhaustivity to handle async Effects properly.
- [Review Fix] Exposed all fetch methods in DatabaseClient.
- [Review Fix] Added memberwise initializer to SensorReadingRecord.
- [Review Fix] Added testFetchBySession test case.

### File List

- Vertical/Vertical/Sources/Database/SensorReadingRecord.swift
- Vertical/Vertical/Sources/Database/AppDatabase.swift
- Vertical/Vertical/Sources/Clients/DatabaseClient/DatabaseClient.swift
- Vertical/Vertical/Sources/Features/Tracker/TrackerReducer.swift
- Vertical/Tests/FeatureTests/TrackerFeatureTests.swift
- Vertical.xcodeproj/project.pbxproj
