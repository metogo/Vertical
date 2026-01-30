import Foundation
import simd

/// A vertex for the 3D spiral path
struct SpiralVertex {
    var position: SIMD4<Float>
    var color: SIMD4<Float>
}

/// Uniforms for the 3D spiral rendering
struct SpiralUniforms {
    var mvpMatrix: matrix_float4x4
    var rotationMatrix: matrix_float4x4
    var landmarkHeight: Float
    var currentClimb: Float
}
