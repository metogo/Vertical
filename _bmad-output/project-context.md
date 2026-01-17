---
project_name: "vertical"
user_name: "Fanhua"
date: "2026-01-17"
sections_completed:
  ["technology_stack", "implementation_rules", "usage_guidelines"]
status: "complete"
rule_count: 25
optimized_for_llm: true
---

---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

- **Platform**: iOS 17+ (Native)
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Architecture**: The Composable Architecture (TCA) 1.x
- **Graphics**: Metal (via SwiftUI Shaders)
- **Sensors**: CoreMotion (CMMotionManager, CMAltimeter)
- **Data**: GRDB (SQLite)
- **Build Tools**: xcodebuild, Fastlane
- **Linting**: SwiftLint

## Critical Implementation Rules

### Language-Specific Rules (Swift 6)

- **Concurrency**: Enable `Strict Concurrency Checking`. Use `Task`, `Actor`, and `await`. Avoid `DispatchQueue` unless interacting with legacy C-APIs.
- **Safety**: Force unwrap (`!`) is strictly forbidden in Production Code. Allowed in Unit Tests and SwiftUI Previews (mock data only).
- **Type Safety**: Use `struct` for data models and `state`. Use `enum` for comprehensive state switching.

### Framework-Specific Rules (TCA & SwiftUI)

- **Action Naming**: Strict structure: `case view(ViewAction)`, `case internal(InternalAction)`, `case delegate(DelegateAction)`.
- **Delegate Rules**: `DelegateAction` must start with `did`, `will`, or `request` (e.g., `didFinishSession`). Parent features listen to these; child features never handle them.
- **Side Effects**: ALL side effects (API, Sensor, Haptics) must be executed via `DependencyClients`. Never call system APIs directly in Reducers.
- **View Binding**: Views must only observe `Store` or `ViewStore`. No `@StateObject` or `@ObservedObject` unless wrapping a legacy UIKit component.
- **Metal Shaders**: Expose shaders via `ShaderLibrary` extensions. **IMPORTANT**: Swift structs passing data to shaders must use `C-compatible` layout (align with `simd` types).

### Testing Rules

- **Logic Tests**: Use `TestStore` for all Feature logic. Verify every state change and effect.
- **UI Tests**: Snapshot Testing required for **Complex Custom Components** (HUD, Particle Views, Charts). Not required for standard lists.
- **Mocks**: Every `Client` must have static `.liveValue`, `.testValue` (failing), and `.previewValue`.
- **Sensor Mocking**: `SensorClient.mock` must support **Data Replay** (injecting a CSV stream of fake altitude data) to test climb logic.

### Code Quality & Style Rules

- **Linter**: Respect `.swiftlint.yml`.
- **File Structure**: Feature-Sliced. `State`, `Action`, `Reducer` can be in one file if small (<200 lines), otherwise split.
- **Comments**: Explain "Why" for sensor fusion algorithms and shader logic. "What" is self-evident.

### Critical Don't-Miss Rules (Anti-Patterns)

- ❌ **Privacy Violation**: NEVER persist exact GPS coordinates (latitude/longitude). Only persist `altitude` or relative distance.
- ❌ **Main Thread Blocking**: NEVER perform heavy sensor data processing on the Main Actor. Pipeline: Sensor -> Background Actor -> Reducer -> Main Actor (UI).
- ❌ **Direct Hardware Access**: NEVER instantiate `CMMotionManager` or `CLLocationManager` inside a View or Reducer. Always use `SensorClient`.

---

## Usage Guidelines

**For AI Agents:**

- Read this file before implementing any code
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- Update this file if new patterns emerge

**For Humans:**

- Keep this file lean and focused on agent needs
- Update when technology stack changes
- Review quarterly for outdated rules
- Remove rules that become obvious over time

Last Updated: 2026-01-17
