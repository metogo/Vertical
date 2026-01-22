# Story 6.2: CloudKit Sync

Status: done (core implemented)

## Story

As a User,
I want my workout data to be automatically synchronized across all my Apple devices,
So that I can track my long-term progress and view my 3D climbs on a larger screen like my iPad.

## Acceptance Criteria

1. **Given** Multiple devices signed into the same iCloud account
2. **When** I complete a workout on one device
3. **Then** The workout session and its corresponding sensor readings are uploaded to CloudKit
4. **And** The data is automatically fetched and merged on the other devices
5. **And** The sync process happens in the background without blocking the UI

## Tasks / Subtasks

- [x] Task 1: Create `CloudKitClient` for interacting with the private CloudKit database.
- [x] Task 2: Update `AppDatabase` to include a `sessions` table.
- [x] Task 3: Implement `SyncClient` engine to push/pull data.
- [x] Task 4: Integrate sync into `AppReducer`.
- [ ] Task 5: Add a "Syncing..." visual indicator in the UI. (Optional but good for premium feel)

## Dev Notes

- Use `CKRecord` for sessions.
- For thousands of sensor readings, consider uploading them as a `CKAsset` (the SQLite file or a compressed JSON/Binary) rather than individual records to save data and battery.
- Implementation: When a session is saved locally, trigger an upload task.

### References

- [Source: planning-artifacts/epics.md#Story 6.2: CloudKit Sync]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Implemented `CloudKitClient` using `CKRecord` and `CKQuery`.
- Optimized sync by bundling thousands of sensor readings into a single JSON blob per session, stored as `NSData` in CloudKit.
- Added a `sessions` table to GRDB to track high-level session metadata and sync status.
- Implemented `SyncClient` which handles the background push/pull logic.
- Integrated sync triggers on app launch and workout completion in `AppReducer`.

### File List

- Vertical/Vertical/Vertical/Sources/Database/SessionRecord.swift
- Vertical/Vertical/Vertical/Sources/Clients/CloudKitClient/CloudKitClient.swift
- Vertical/Vertical/Vertical/Sources/Clients/SyncClient/SyncClient.swift
- Vertical/Vertical/Vertical/Sources/Database/AppDatabase.swift
- Vertical/Vertical/Vertical/Sources/Clients/DatabaseClient/DatabaseClient.swift
- Vertical/Vertical/Vertical/Sources/Features/Root/AppReducer.swift
