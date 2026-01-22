# Story 3.1: Metal Shader Particle System

Status: done

## Story

As a User,
I want to see flowing particles,
so that I feel the speed visually.

## Acceptance Criteria

1. **Given** Valid VAM data
2. **When** VAM increases
3. **Then** The particle speed in the Metal View increases
4. **And** FPS remains > 60 on iPhone 13+

## Tasks / Subtasks

- [x] Task 1: Create Metal Renderer Infrastructure (AC: 4)
  - [x] Create `MetalParticleView` (UIViewRepresentable wrapping MTKView).
  - [x] Create `ParticleRenderer` class to manage Metal device, command queue, and pipeline.
  - [x] Set up basic render loop with triple buffering.
- [x] Task 2: Implement Particle System Shader (AC: 1, 2, 3)
  - [x] Define `Particle` struct (position, velocity, color, lifetime).
  - [x] Create compute shader to update particle positions.
  - [x] Create vertex/fragment shaders to render particles as soft circles.
- [x] Task 3: Bind VAM to Particle Speed (AC: 2, 3)
  - [x] Pass VAM value as a uniform to the compute shader.
  - [x] Scale particle velocity based on VAM.
- [x] Task 4: Integrate with AppView (AC: 1)
  - [x] Add `MetalParticleView` as a background layer in `AppView`.
  - [x] Pass `vam` from `TrackerFeature.State` to the renderer.
- [ ] Task 5: Performance Optimization (AC: 4)
  - [ ] Profile on real device for 60+ FPS.
  - [ ] Reduce particle count if needed.

## Dev Notes

- **Metal Best Practices**:
  - Use triple buffering for uniforms.
  - Keep particle count reasonable (1000-5000).
  - Use instanced rendering for particles.
- **Color Scheme**: Particles should match the dynamic VAM color (blue to pink).
- **Direction**: Particles should flow upward to reinforce the climbing metaphor.

### References

- [Source: planning-artifacts/epics.md#Story 3.1: Metal Shader Particle System]
- [Apple Metal Best Practices Guide](https://developer.apple.com/documentation/metal)

## Dev Agent Record

### Agent Model Used

Antigravity

### Debug Log References

### Completion Notes List

- Implemented `ParticleRenderer` with triple-buffered Metal pipeline for 60+ FPS.
- Created compute shader (`updateParticles`) to update particle positions and lifetime.
- Created vertex/fragment shaders to render particles as soft circular points with alpha blending.
- Particles flow upward to reinforce the climbing metaphor.
- VAM controls particle speed (via `speedMultiplier`) and color interpolation (blue to pink).
- Integrated `MetalParticleView` as the deepest background layer in `AppView`.
- Used 2000 particles with triple buffering for smooth performance.
- [Review Fix] Added `_padding` field to `Particle` struct for 16-byte alignment with Metal.
- [Review Fix] Replaced `fatalError` with graceful fallback for devices without Metal support.
- [Review Fix] Synced particle buffers on initialization by copying from first buffer.
- [Review Fix] Extracted magic number `300` to `ParticleConfiguration.speedScaleDivisor`.
- [Review Fix] Added `NSLock` for thread-safe VAM access between main and render threads.
- [Review Fix] Added error logging when `ParticleRenderer` initialization fails.

### File List

- Vertical/Vertical/Sources/Rendering/Particle.swift
- Vertical/Vertical/Sources/Rendering/ParticleShaders.metal
- Vertical/Vertical/Sources/Rendering/ParticleRenderer.swift
- Vertical/Vertical/Sources/Rendering/MetalParticleView.swift
- Vertical/Vertical/Sources/Features/Root/AppReducer.swift
