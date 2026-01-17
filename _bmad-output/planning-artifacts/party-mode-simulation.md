**Facilitator (Antigravity):**
"🎉 PARTY MODE ACTIVATED! 🎉

Welcome everyone! I've drafted the **Critical Implementation Rules** for the Vertical project context. I need your expert review to ensure these are leak-proof instructions for our coding agents.

**The Draft:**

- **Swift 6**: Strict Concurrency checks enabled. No `!` force unwraps.
- **TCA**: Strict Action naming (`view`, `internal`, `delegate`). Side effects ONLY via DependencyClients.
- **Metal**: `simd` alignment for shared types.
- **Testing**: `TestStore` for logic, Snapshot for UI. Mocks for every client.
- **Critical**: NO GPS persistence (only altitude). NO heavy math on Main Actor.

**Winston (Architect) 🏗️:**
"The `simd` alignment rule for Metal is crucial. If we don't enforce `SharedTypes.h` bridging, we'll get silent rendering bugs. I'd add a specific rule: **'Always use `C-compatible` structs in `SharedTypes.h` for Metal buffers.'**"

**Amelia (Dev) 💻:**
"Regarding 'No force unwrap' - can we make an exception for `IBOutlets` or `Preview` data? Writing `if let` for static preview mocks is tedious. Also, for TCA Action naming, specifying `view`, `internal`, `delegate` is good, but let's add: **'Delegate actions must be listened to by parent features or ignored, never handled by the feature itself.'** That prevents circular logic."

**Murat (Test Architect) 🧪:**
"Snapshot testing is expensive on CI. We should clarify: **'Snapshot tests for Component Library and HUD only.'** We don't need snapshots for every standard list view. Also, for `SensorClient`, we need a rule: **'Mock must provide a replayable stream capability'** to test complex gestures like 'climb -> stop -> fall'."

**Facilitator (Antigravity):**
"Excellent points.

1. Winston: I'll clarify the `SharedTypes.h` C-compatibility.
2. Amelia: I'll allow `!` in Previews/Tests, and refine the Delegate Action rule.
3. Murat: I'll scope Snapshot tests to 'Complex UI' and add 'Replayable Stream' to Sensor mock requirements."

**Does this round of refinement look good to you, User?**
