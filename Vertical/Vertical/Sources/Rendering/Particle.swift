import Foundation
import simd

/// Particle data structure for Metal rendering
/// Layout must match Metal shader struct exactly
struct Particle {
    /// Position in normalized device coordinates (-1 to 1)
    var position: SIMD2<Float>      // 8 bytes, offset 0
    /// Velocity in units per second
    var velocity: SIMD2<Float>      // 8 bytes, offset 8
    /// Color (RGBA)
    var color: SIMD4<Float>         // 16 bytes, offset 16
    /// Remaining lifetime in seconds
    var lifetime: Float             // 4 bytes, offset 32
    /// Initial lifetime for alpha calculation
    var initialLifetime: Float      // 4 bytes, offset 36
    /// Size of the particle
    var size: Float                 // 4 bytes, offset 40
    /// Padding to align to 16-byte boundary (Metal prefers 16-byte aligned structs)
    var _padding: Float = 0         // 4 bytes, offset 44
    // Total: 48 bytes
    
    /// Create a random particle for the upward flow effect
    static func random() -> Particle {
        let x = Float.random(in: -1...1)
        let y = Float.random(in: -1.5...(-1.0)) // Start below screen
        let lifetime = Float.random(in: 2...4)
        
        return Particle(
            position: SIMD2<Float>(x, y),
            velocity: SIMD2<Float>(Float.random(in: -0.05...0.05), Float.random(in: 0.3...0.6)),
            color: SIMD4<Float>(0.3, 0.5, 1.0, 1.0), // Blue base color
            lifetime: lifetime,
            initialLifetime: lifetime,
            size: Float.random(in: 2...6),
            _padding: 0
        )
    }
}

/// Uniform data passed to shaders each frame
struct ParticleUniforms {
    /// VAM-based speed multiplier (0.0 to 2.0+)
    var speedMultiplier: Float      // 4 bytes
    /// Delta time since last frame
    var deltaTime: Float            // 4 bytes
    /// Color interpolation factor (0 = blue, 1 = pink)
    var colorFactor: Float          // 4 bytes
    /// Metabolic activation factor (0.0 to 1.0)
    var activationFactor: Float     // 4 bytes
    // Total: 16 bytes (aligned)
}
