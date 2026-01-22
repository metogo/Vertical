import Foundation
import Metal
import MetalKit
import os.log

private let logger = Logger(subsystem: "com.vertical.rendering", category: "ParticleRenderer")

/// Configuration for the particle system
enum ParticleConfiguration {
    /// Number of particles in the system
    static let particleCount = 2000
    /// Peak VAM for color interpolation
    static let peakVam: Float = 1200
    /// VAM divisor for speed scaling (lower = faster response)
    static let speedScaleDivisor: Float = 300
}

/// Renders a particle system using Metal
final class ParticleRenderer: NSObject {
    // MARK: - Metal Objects
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let computePipeline: MTLComputePipelineState
    private let renderPipeline: MTLRenderPipelineState
    
    // MARK: - Buffers (Triple Buffered)
    
    private var particleBuffers: [MTLBuffer]
    private var uniformBuffers: [MTLBuffer]
    private var currentBufferIndex = 0
    private let inflightSemaphore = DispatchSemaphore(value: 3)
    
    // MARK: - State
    
    private var lastUpdateTime: CFTimeInterval = 0
    
    /// Current VAM value - thread-safe via atomic access pattern
    private var _vam: Float = 0
    private let vamLock = NSLock()
    
    var vam: Float {
        get {
            vamLock.lock()
            defer { vamLock.unlock() }
            return _vam
        }
        set {
            vamLock.lock()
            _vam = newValue
            vamLock.unlock()
        }
    }
    
    // MARK: - Initialization
    
    init?(device: MTLDevice) {
        self.device = device
        
        guard let queue = device.makeCommandQueue() else {
            logger.error("Failed to create command queue")
            return nil
        }
        self.commandQueue = queue
        
        // Load shaders
        guard let library = device.makeDefaultLibrary() else {
            logger.error("Failed to load Metal library")
            return nil
        }
        
        // Create compute pipeline
        guard let computeFunction = library.makeFunction(name: "updateParticles"),
              let computePipeline = try? device.makeComputePipelineState(function: computeFunction) else {
            logger.error("Failed to create compute pipeline")
            return nil
        }
        self.computePipeline = computePipeline
        
        // Create render pipeline
        let renderDescriptor = MTLRenderPipelineDescriptor()
        renderDescriptor.vertexFunction = library.makeFunction(name: "particleVertex")
        renderDescriptor.fragmentFunction = library.makeFunction(name: "particleFragment")
        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Enable alpha blending
        renderDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderDescriptor.colorAttachments[0].rgbBlendOperation = .add
        renderDescriptor.colorAttachments[0].alphaBlendOperation = .add
        renderDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        guard let renderPipeline = try? device.makeRenderPipelineState(descriptor: renderDescriptor) else {
            logger.error("Failed to create render pipeline")
            return nil
        }
        self.renderPipeline = renderPipeline
        
        // Create particle buffers (triple buffering)
        let particleSize = MemoryLayout<Particle>.stride * ParticleConfiguration.particleCount
        self.particleBuffers = (0..<3).compactMap { _ in
            device.makeBuffer(length: particleSize, options: .storageModeShared)
        }
        
        // Create uniform buffers (triple buffering)
        let uniformSize = MemoryLayout<ParticleUniforms>.stride
        self.uniformBuffers = (0..<3).compactMap { _ in
            device.makeBuffer(length: uniformSize, options: .storageModeShared)
        }
        
        guard particleBuffers.count == 3, uniformBuffers.count == 3 else {
            logger.error("Failed to create buffers")
            return nil
        }
        
        super.init()
        
        // Initialize particles in first buffer, then copy to others
        initializeParticles()
        logger.info("ParticleRenderer initialized with \(ParticleConfiguration.particleCount) particles")
    }
    
    private func initializeParticles() {
        // Initialize first buffer
        let firstBuffer = particleBuffers[0]
        let particles = firstBuffer.contents().bindMemory(to: Particle.self, capacity: ParticleConfiguration.particleCount)
        for i in 0..<ParticleConfiguration.particleCount {
            particles[i] = Particle.random()
        }
        
        // Copy to other buffers for consistency
        let size = MemoryLayout<Particle>.stride * ParticleConfiguration.particleCount
        for i in 1..<particleBuffers.count {
            memcpy(particleBuffers[i].contents(), firstBuffer.contents(), size)
        }
    }
}

// MARK: - MTKViewDelegate

extension ParticleRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle resize if needed
    }
    
    func draw(in view: MTKView) {
        // Wait for available buffer
        _ = inflightSemaphore.wait(timeout: .distantFuture)
        
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            inflightSemaphore.signal()
            return
        }
        
        // Calculate delta time
        let currentTime = CACurrentMediaTime()
        let deltaTime = lastUpdateTime == 0 ? 0.016 : Float(currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        // Read VAM thread-safely
        let currentVam = vam
        
        // Update uniforms
        let uniformBuffer = uniformBuffers[currentBufferIndex]
        let uniforms = uniformBuffer.contents().bindMemory(to: ParticleUniforms.self, capacity: 1)
        uniforms.pointee.speedMultiplier = max(0.5, currentVam / ParticleConfiguration.speedScaleDivisor)
        uniforms.pointee.deltaTime = min(deltaTime, 0.1) // Cap delta time to prevent jumps
        uniforms.pointee.colorFactor = min(currentVam / ParticleConfiguration.peakVam, 1.0)
        
        let particleBuffer = particleBuffers[currentBufferIndex]
        
        // Compute pass - update particles
        if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
            computeEncoder.setComputePipelineState(computePipeline)
            computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
            computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 1)
            
            let threadsPerThreadgroup = MTLSize(width: min(256, ParticleConfiguration.particleCount), height: 1, depth: 1)
            let threadgroups = MTLSize(
                width: (ParticleConfiguration.particleCount + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width,
                height: 1,
                depth: 1
            )
            computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
            computeEncoder.endEncoding()
        }
        
        // Render pass - draw particles
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
            renderEncoder.setRenderPipelineState(renderPipeline)
            renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: ParticleConfiguration.particleCount)
            renderEncoder.endEncoding()
        }
        
        commandBuffer.present(drawable)
        
        commandBuffer.addCompletedHandler { [weak self] _ in
            self?.inflightSemaphore.signal()
        }
        
        commandBuffer.commit()
        
        // Cycle buffers
        currentBufferIndex = (currentBufferIndex + 1) % 3
    }
}
