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
    
    private var landmarkBuffer: MTLBuffer?
    private var landmarkVertexCount: Int = 0
    
    private var totalClimbHeight: Float = 0.0
    private var landmarkHeight: Float = 0.0
    
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
        guard !readings.isEmpty else {
            self.vertexBuffer = nil
            self.vertexCount = 0
            return
        }
        
        let minAlt = readings.map { $0.relativeAltitude }.min() ?? 0
        let maxAlt = readings.map { $0.relativeAltitude }.max() ?? 10
        let altRange = max(1.0, maxAlt - minAlt)
        self.totalClimbHeight = Float(altRange)
        
        // --- 1. SET THE STAGE (Landmark scale) ---
        let landmarkSamples = Landmark.samples
        let targetLandmark = landmarkSamples.first(where: { Float($0.height) > Float(altRange) }) ?? landmarkSamples[0]
        self.landmarkHeight = Float(targetLandmark.height)
        
        let boxHeight: Float = 3.2
        let scaleFactor = boxHeight / self.landmarkHeight
        
        // --- 2. GENERATE USER CLIMB (The Hero) ---
        var vertices: [SpiralVertex] = []
        let stepHeight: Float = 0.18
        let totalSteps = Int(Float(altRange) / stepHeight)
        
        for i in 0..<totalSteps {
            let t = Float(i) / Float(max(1, totalSteps - 1))
            let angle = t * .pi * 2.0 * 8.0 // Consistently elegant 8 turns
            
            let radius: Float = 0.6
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            let y = (Float(i) * stepHeight * scaleFactor) - (boxHeight / 2.0)
            
            // Dynamic coloration: Blue (0) -> Cyan (Target) -> Pink/Orange (Peak)
            let color = mix(SIMD3<Float>(0, 0.8, 1), SIMD3<Float>(1, 0.4, 0.8), t: t)
            
            vertices.append(SpiralVertex(
                position: SIMD4<Float>(x, y, z, 1.0),
                color: SIMD4<Float>(color.x, color.y, color.z, 1.0)
            ))
        }
        
        // --- 3. GENERATE THE "MONOLITH" (Fixed Landmark Structure) ---
        var landmarkVertices: [SpiralVertex] = []
        
        // We build a vertical crystalline "Guide Column"
        let columns = 4
        let columnHeightPoints = 200
        for c in 0..<columns {
            let angle = Float(c) / Float(columns) * .pi * 2.0
            let r: Float = 0.7 // Slightly outside the user path
            for h in 0..<columnHeightPoints {
                let ht = Float(h) / Float(columnHeightPoints)
                let y = (ht * boxHeight) - (boxHeight / 2.0)
                
                // Add "ticks" every 10 meters roughly
                let isTick = h % 20 == 0
                let color = isTick ? SIMD4<Float>(1,1,1, 0.15) : SIMD4<Float>(1,1,1, 0.05)
                
                landmarkVertices.append(SpiralVertex(
                    position: SIMD4<Float>(r * cos(angle), y, r * sin(angle), 1.0),
                    color: color
                ))
            }
        }
        
        // Ground Grid (Small & subtle)
        for r in 0...2 {
            let ringRadius = Float(r) * 0.4
            for i in 0..<40 {
                let angle = Float(i) / 40.0 * .pi * 2.0
                landmarkVertices.append(SpiralVertex(
                    position: SIMD4<Float>(ringRadius * cos(angle), -boxHeight/2.0, ringRadius * sin(angle), 1.0),
                    color: SIMD4<Float>(1, 1, 1, 0.1)
                ))
            }
        }
        
        self.vertexCount = vertices.count
        self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SpiralVertex>.stride, options: .storageModeShared)
        
        self.landmarkVertexCount = landmarkVertices.count
        self.landmarkBuffer = device.makeBuffer(bytes: landmarkVertices, length: landmarkVertices.count * MemoryLayout<SpiralVertex>.stride, options: .storageModeShared)
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
            mvpMatrix: projectionMatrix * viewMatrix,
            rotationMatrix: rotationMatrix,
            landmarkHeight: self.landmarkHeight,
            currentClimb: self.totalClimbHeight
        )
        
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        
        if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) {
            encoder.setRenderPipelineState(pipelineState)
            
            // Pass 1: Landmark Ghost (Background)
            if let landmarkBuffer = landmarkBuffer {
                encoder.setVertexBuffer(landmarkBuffer, offset: 0, index: 0)
                encoder.setVertexBytes(&uniforms, length: MemoryLayout<SpiralUniforms>.stride, index: 1)
                encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: landmarkVertexCount)
            }
            
            // Pass 2: Main Staircase Points
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setVertexBytes(&uniforms, length: MemoryLayout<SpiralUniforms>.stride, index: 1)
            encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexCount)
            
            encoder.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
