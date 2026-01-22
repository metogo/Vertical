import Metal
import MetalKit
import simd
import os.log

private let logger = Logger(subsystem: "com.vertical.rendering", category: "SpiralRenderer")

final class SpiralRenderer: NSObject {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    
    private var vertexBuffer: MTLBuffer?
    private var vertexCount: Int = 0
    
    var rotation: SIMD2<Float> = .zero // X and Y rotation
    
    init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        
        let library = device.makeDefaultLibrary()
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "spiralVertex")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "spiralFragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
        
        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            logger.error("Failed to create spiral pipeline state: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Catmull-Rom Interpolation
    private func catmullRom(p0: SIMD3<Float>, p1: SIMD3<Float>, p2: SIMD3<Float>, p3: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        let t2 = t * t
        let t3 = t2 * t
        
        let v0 = (p2 - p0) * 0.5
        let v1 = (p3 - p1) * 0.5
        
        // Break down 'a' component: (2*p1 - 2*p2 + v0 + v1) * t3
        let a1 = 2 * p1
        let a2 = 2 * p2
        let a_sum = (a1 - a2) + (v0 + v1)
        let a = a_sum * t3
        
        // Break down 'b' component: (-3*p1 + 3*p2 - 2*v0 - v1) * t2
        let b1 = 3 * p1
        let b2 = 3 * p2
        let v0_2 = 2 * v0
        let b_sum = (b2 - b1) - (v0_2 + v1)
        let b = b_sum * t2
        
        let c = v0 * t
        
        return a + b + c + p1
    }
    
    func updateData(readings: [SensorReading]) {
        guard readings.count >= 4 else {
            self.vertexBuffer = nil
            self.vertexCount = 0
            return
        }
        
        let minAlt = readings.map { $0.relativeAltitude }.min() ?? 0
        let maxAlt = readings.map { $0.relativeAltitude }.max() ?? 10
        let altRange = max(1.0, maxAlt - minAlt)
        let count = readings.count
        
        // Convert readings to control points
        var controlPoints: [SIMD3<Float>] = []
        
        // Calculate dynamic turns: 1 turn per 20m, min 2, max 100
        let turns = min(100.0, max(2.0, Float(altRange) / 20.0))
        
        for (i, reading) in readings.enumerated() {
            let t = Float(i) / Float(count - 1)
            let angle = t * .pi * 2.0 * turns
            
            // Dynamic radius based on height (cone shape) + slight wobble
            // We reduce radius slightly for very long climbs to keep it elegant
            let radiusScale: Float = altRange > 500 ? 0.7 : 1.0
            let baseRadius: Float = 0.5 * radiusScale
            let radius = baseRadius + sin(t * .pi * 4) * (0.1 * radiusScale)
            
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            
            // Adjust vertical scale based on climb height
            // Small climbs (<100m) look "shorter", massive climbs fill the volume
            let heightLimit: Float = 2.5
            let heightScale = min(1.0, Float(altRange) / 100.0)
            let currentHeight = heightLimit * (0.5 + 0.5 * heightScale) // Minimum 50% height
            
            let y = (Float(reading.relativeAltitude - minAlt) / Float(altRange)) * currentHeight - (currentHeight / 2.0)
            
            controlPoints.append(SIMD3<Float>(x, y, z))
        }
        
        // Generate interpolated vertices
        var vertices: [SpiralVertex] = []
        let segments = controlPoints.count - 3
        
        // Ensure smoothness: at least 32 steps per turn, or 20 per segment min
        let stepsPerSegment = max(20, Int((turns * 32) / Float(segments)))
        
        for i in 0..<segments {
            let p0 = controlPoints[i]
            let p1 = controlPoints[i + 1]
            let p2 = controlPoints[i + 2]
            let p3 = controlPoints[i + 3]
            
            for j in 0..<stepsPerSegment {
                let t = Float(j) / Float(stepsPerSegment)
                let pos = catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: t)
                
                // Enhanced coloring logic
                // Calculate height ratio relative to full range
                let heightRatio = (pos.y + 1.25) / 2.5
                
                // Gradient: Deep Purple -> Neon Blue -> Hot Pink
                let deepPurple = SIMD3<Float>(0.3, 0.0, 0.6)
                let neonBlue = SIMD3<Float>(0.0, 0.8, 1.0)
                let hotPink = SIMD3<Float>(1.0, 0.2, 0.7)
                
                var color: SIMD3<Float>
                if heightRatio < 0.5 {
                    color = mix(deepPurple, neonBlue, t: heightRatio * 2.0)
                } else {
                    color = mix(neonBlue, hotPink, t: (heightRatio - 0.5) * 2.0)
                }
                
                // Add alpha that fades at edges
                vertices.append(SpiralVertex(
                    position: SIMD4<Float>(pos.x, pos.y, pos.z, 1.0),
                    color: SIMD4<Float>(color.x, color.y, color.z, 1.0)
                ))
            }
        }
        
        self.vertexCount = vertices.count
        self.vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<SpiralVertex>.stride,
            options: .storageModeShared
        )
    }
}

extension SpiralRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let vertexBuffer = vertexBuffer,
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        let aspect = Float(view.drawableSize.width / view.drawableSize.height)
        let projectionMatrix = matrix_float4x4.perspective(
            fovyRadians: .pi / 3,
            aspectRatio: aspect,
            nearZ: 0.1,
            farZ: 100.0
        )
        
        // Auto-rotation
        rotation.x += 0.005
        
        // Simulating camera movement
        let viewMatrix = matrix_float4x4.lookAt(
            eye: SIMD3<Float>(0, 1.0, 4.0), // Slightly higher camera
            center: SIMD3<Float>(0, 0, 0),
            up: SIMD3<Float>(0, 1, 0)
        )
        
        let rotationMatrix = matrix_float4x4.rotationY(rotation.x) * matrix_float4x4.rotationX(0.2) // Slight tilt
        
        var uniforms = SpiralUniforms(
            modelViewProjectionMatrix: projectionMatrix * viewMatrix,
            rotationMatrix: rotationMatrix
        )
        
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0) // Transparent background
        
        if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) {
            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            // Pass 1: Main Line
            var uniformsMain = uniforms
            encoder.setVertexBytes(&uniformsMain, length: MemoryLayout<SpiralUniforms>.stride, index: 1)
            encoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: vertexCount)
            
            // Pass 2: Glow bleed (slight offset/scale)
            var uniformsGlow = uniforms
            uniformsGlow.modelViewProjectionMatrix = uniforms.modelViewProjectionMatrix * matrix_float4x4.scale(x: 1.01, y: 1.0, z: 1.01)
            encoder.setVertexBytes(&uniformsGlow, length: MemoryLayout<SpiralUniforms>.stride, index: 1)
            encoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: vertexCount)
            
            encoder.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
