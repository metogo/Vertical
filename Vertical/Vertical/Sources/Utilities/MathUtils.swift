import Foundation
import simd

extension matrix_float4x4 {
    static func perspective(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let ys = 1 / tanf(fovyRadians * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (nearZ - farZ)
        
        return matrix_float4x4(columns: (
            SIMD4<Float>(xs,  0,  0,  0),
            SIMD4<Float>( 0, ys,  0,  0),
            SIMD4<Float>( 0,  0, zs, -1),
            SIMD4<Float>( 0,  0, nearZ * zs, 0)
        ))
    }
    
    static func lookAt(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
        let z = normalize(eye - center)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        
        return matrix_float4x4(columns: (
            SIMD4<Float>(x.x, y.x, z.x, 0),
            SIMD4<Float>(x.y, y.y, z.y, 0),
            SIMD4<Float>(x.z, y.z, z.z, 0),
            SIMD4<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)
        ))
    }
    
    static func rotationY(_ radians: Float) -> matrix_float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        
        return matrix_float4x4(columns: (
            SIMD4<Float>(cos, 0, -sin, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(sin, 0, cos, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
    
    static func rotationX(_ radians: Float) -> matrix_float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        
        return matrix_float4x4(columns: (
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, cos, sin, 0),
            SIMD4<Float>(0, -sin, cos, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
    
    static func scale(x: Float, y: Float, z: Float) -> matrix_float4x4 {
        return matrix_float4x4(columns: (
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
}
