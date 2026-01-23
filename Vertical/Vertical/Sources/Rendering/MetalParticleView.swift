import MetalKit
import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.vertical.rendering", category: "MetalParticleView")

/// A SwiftUI view that displays a Metal-rendered particle system
struct MetalParticleView: UIViewRepresentable {
    /// Current VAM value to control particle speed and color
    let vam: Double
    /// Whether AMPK metabolic activation is active
    let isAMPKActivated: Bool
    
    func makeUIView(context: Context) -> MTKView {
        // Gracefully handle devices without Metal support
        guard let device = MTLCreateSystemDefaultDevice() else {
            logger.warning("Metal is not supported on this device, returning empty view")
            let fallbackView = MTKView(frame: .zero)
            fallbackView.backgroundColor = .clear
            fallbackView.isOpaque = false
            return fallbackView
        }
        
        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.isOpaque = false
        mtkView.backgroundColor = .clear
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        
        // Create and set the renderer
        if let renderer = ParticleRenderer(device: device) {
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
        } else {
            logger.error("Failed to create ParticleRenderer, particles will not be displayed")
        }
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.renderer?.vam = Float(vam)
        context.coordinator.renderer?.isAMPKActivated = isAMPKActivated
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var renderer: ParticleRenderer?
    }
}

#Preview {
    ZStack {
        Color.black
        MetalParticleView(vam: 600, isAMPKActivated: true)
    }
    .ignoresSafeArea()
}
