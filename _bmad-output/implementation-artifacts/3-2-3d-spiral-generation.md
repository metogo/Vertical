# Story 3.2: 3D Spiral Generation

Status: done

## Story

As a User,
I want to see my path as a 3D wireframe,
so that I can visualize my climb in an immersive way.

## Acceptance Criteria

1. **Given** A set of session altitude data points
2. **When** I view the session summary/result
3. **Then** A 3D spiral mesh/line is generated matching the data points
4. **And** I can rotate the visualization with touch gestures

## Tasks / Subtasks

- [x] Task 1: Create Result/Summary Feature (AC: 1, 2)
  - [x] Implement `ResultFeature` reducer and state.
  - [x] Handle loading data from `DatabaseClient`.
- [x] Task 2: Implement 3D Spiral Metal Renderer (AC: 3)
  - [x] Create `SpiralRenderer` with vertex buffers for the path.
  - [x] Map altitude and time to 3D spiral coordinates.
  - [x] Implement shaders for 3D wireframe rendering.
- [x] Task 3: Touch Interaction (AC: 4)
  - [x] Add rotation state to the renderer.
  - [x] Bind SwiftUI drag gestures to rotation uniforms.
- [x] Task 4: UI Integration (AC: 2)
  - [x] Create `ResultView` and navigation from `TrackerView` (when stopping).

## Dev Notes

- **Coordinate Mapping**:
  - $Y$ = Altitude (normalized)
  - $X = R \cdot \cos(\theta)$
  - $Z = R \cdot \sin(\theta)$
  - $\theta$ increases with time (creating the spiral)
- **Aesthetics**: Use the same blue-pink gradient as the particles and VAM gauge. Use additive blending for a "neon glow" look.

### References

- [Source: planning-artifacts/epics.md#Story 3.2: 3D Spiral Generation]

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Implemented `SpiralRenderer` using Metal `lineStrip` to draw a 3D path.
- Created `ResultFeature` which loads session readings and calculates total climb.
- Integrated `SpiralView` into `ResultView` with interactive rotation gestures.
- Automatic navigation to `ResultView` when a tracking session is stopped.
- Added matrix math utilities for perspective projection and object rotation.

### File List

- Vertical/Vertical/Sources/Rendering/SpiralTypes.swift
- Vertical/Vertical/Sources/Rendering/SpiralShaders.metal
- Vertical/Vertical/Sources/Rendering/SpiralRenderer.swift
- Vertical/Vertical/Sources/Rendering/SpiralView.swift
- Vertical/Vertical/Sources/Utilities/MathUtils.swift
- Vertical/Vertical/Sources/Features/Result/ResultFeature.swift
- Vertical/Vertical/Sources/Features/Root/AppReducer.swift
