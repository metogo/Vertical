import SwiftUI
import MetalKit

struct SpiralView: UIViewRepresentable {
    let readings: [SensorReading]
    @Binding var rotation: SIMD2<Float>
    
    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return MTKView()
        }
        
        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0)
        mtkView.backgroundColor = .clear
        mtkView.isOpaque = false
        
        if let renderer = SpiralRenderer(device: device) {
            renderer.updateData(readings: readings)
            context.coordinator.renderer = renderer
            mtkView.delegate = renderer
        }
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.renderer?.rotation = rotation
        // For efficiency, we only update data if it changed significantly, 
        // but for the Result view, it's usually static data.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var renderer: SpiralRenderer?
    }
}

struct SpiralContainerView: View {
    let readings: [SensorReading]
    @State private var rotation: SIMD2<Float> = .zero
    @State private var lastTranslation: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Atmospheric Background
            Color.black
            
            RadialGradient(
                colors: [.blue.opacity(0.15), .black],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [.purple.opacity(0.1), .black],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            
            SpiralView(readings: readings, rotation: $rotation)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let deltaX = Float(value.translation.width - lastTranslation.width) * 0.01
                            let deltaY = Float(value.translation.height - lastTranslation.height) * 0.01
                            rotation.x += deltaX
                            rotation.y += deltaY
                            lastTranslation = value.translation
                        }
                        .onEnded { _ in
                            lastTranslation = .zero
                        }
                )
        }
    }
}
