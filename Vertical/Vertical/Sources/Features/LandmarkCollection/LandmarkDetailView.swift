import SwiftUI
import SceneKit

struct LandmarkDetailView: View {
    let landmark: Landmark
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                HStack {
                    Button {
                        // Action handled by parent normally, but for simplicity here
                        // we can pass a closure or use NotificationCenter.
                        // In TCA, we'd go through the store.
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .opacity(0) // Hidden for alignment
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey(landmark.name))
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(.white)
                        
                        Text("\(Int(landmark.height)) \(String(localized: "METERS"))")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.cyan)
                            .kerning(4)
                    }
                    
                    Spacer()
                    
                    Button {
                        // Share logic will be triggered here
                        NotificationCenter.default.post(name: NSNotification.Name("ShareLandmark"), object: landmark)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundStyle(.cyan)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                // 3D Scene View
                Landmark3DView(landmark: landmark)
                    .frame(height: 350)
                    .background(
                        RadialGradient(
                            colors: [.cyan.opacity(0.15), .black],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                
                // Information
                VStack(alignment: .leading, spacing: 16) {
                    Label(String(localized: "COLLECTORS_NOTE"), systemImage: "quote.opening")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.white.opacity(0.4))
                        .kerning(2)
                    
                    Text(LocalizedStringKey(landmark.description))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding(32)
                .background(RoundedRectangle(cornerRadius: 32).fill(Color.white.opacity(0.05)))
                .padding(.horizontal)
                
                Spacer()
                
                // Achievement Badge
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.cyan)
                    Text(String(localized: "VERTICALLY_CONQUERED"))
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Capsule().stroke(Color.cyan.opacity(0.5), lineWidth: 1))
                .padding(.bottom, 40)
            }
        }
    }
}

struct Landmark3DView: UIViewRepresentable {
    let landmark: Landmark
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false // We'll use custom lighting
        
        let scene = SCNScene()
        
        // 1. Create Procedural Model based on landmark type
        let node = createProceduralModel(for: landmark)
        
        // 2. Add Holographic Shader Effect
        applyHolographicShader(to: node)
        
        scene.rootNode.addChildNode(node)
        
        // 3. Setup Lights
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.cyan.withAlphaComponent(0.2)
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.color = UIColor.white
        omniLight.intensity = 1000
        let omniNode = SCNNode()
        omniNode.light = omniLight
        omniNode.position = SCNVector3(x: 5, y: 10, z: 10)
        scene.rootNode.addChildNode(omniNode)
        
        // 4. Add Grid Floor for scale reference
        let gridPlane = SCNPlane(width: 10, height: 10)
        gridPlane.firstMaterial?.diffuse.contents = createGridImage()
        gridPlane.firstMaterial?.isDoubleSided = true
        let gridNode = SCNNode(geometry: gridPlane)
        gridNode.rotation = SCNVector4(1, 0, 0, -Float.pi / 2)
        gridNode.position = SCNVector3(0, -1.0, 0)
        gridNode.opacity = 0.3
        scene.rootNode.addChildNode(gridNode)
        
        // 5. Rotation Animation
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 15
        rotation.repeatCount = .infinity
        node.addAnimation(rotation, forKey: "rotation")
        
        // 6. Scanning Line Animation (via Shader)
        let scanningAnim = CABasicAnimation(keyPath: "geometry.firstMaterial.shaderModifiers")
        // We'll actually drive a uniform if we were using custom shaders, 
        // but for simplicity we can use a simpler approach or just let the shader fly.
        
        scnView.scene = scene
        
        // Set camera position
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 5)
        scene.rootNode.addChildNode(cameraNode)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    private func createProceduralModel(for landmark: Landmark) -> SCNNode {
        let rootNode = SCNNode()
        
        switch landmark.modelName {
        case "liberty_statue":
            // Complex stick-figure like representation
            let body = SCNCylinder(radius: 0.3, height: 2.0)
            let head = SCNSphere(radius: 0.2)
            let base = SCNBox(width: 1.2, height: 0.5, length: 1.2, chamferRadius: 0)
            
            let bodyNode = SCNNode(geometry: body)
            let headNode = SCNNode(geometry: head)
            headNode.position = SCNVector3(0, 1.1, 0)
            let baseNode = SCNNode(geometry: base)
            baseNode.position = SCNVector3(0, -1.0, 0)
            
            rootNode.addChildNode(bodyNode)
            rootNode.addChildNode(headNode)
            rootNode.addChildNode(baseNode)
            
        case "pyramid":
            let pyramid = SCNPyramid(width: 2.5, height: 1.5, length: 2.5)
            rootNode.geometry = pyramid
            
        case "eiffel_tower":
            // Procedural tapered lattice
            let base = SCNPyramid(width: 2.0, height: 1.0, length: 2.0)
            let mid = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
            let top = SCNCylinder(radius: 0.1, height: 1.5)
            
            let baseNode = SCNNode(geometry: base)
            baseNode.position = SCNVector3(0, -0.5, 0)
            let midNode = SCNNode(geometry: mid)
            midNode.position = SCNVector3(0, 0.5, 0)
            let topNode = SCNNode(geometry: top)
            topNode.position = SCNVector3(0, 1.5, 0)
            
            rootNode.addChildNode(baseNode)
            rootNode.addChildNode(midNode)
            rootNode.addChildNode(topNode)
            
        case "empire_state", "burj_khalifa":
            // Stacked boxes / cylinders for skyscrapers
            let count = landmark.modelName == "burj_khalifa" ? 5 : 3
            for i in 0..<count {
                let scale = 1.0 - (Double(i) * 0.2)
                let height = 0.8
                let geo = landmark.modelName == "burj_khalifa" ? SCNCylinder(radius: 0.4 * scale, height: height) : SCNBox(width: 0.8 * scale, height: height, length: 0.8 * scale, chamferRadius: 0.05)
                let towerNode = SCNNode(geometry: geo)
                towerNode.position = SCNVector3(0, (Double(i) * height) - 0.5, 0)
                rootNode.addChildNode(towerNode)
            }
            
        default:
            rootNode.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.2)
        }
        
        return rootNode
    }
    
    private func applyHolographicShader(to node: SCNNode) {
        let shaderModifier = [
            SCNShaderModifierEntryPoint.fragment: """
                #pragma transparent
                #pragma body
                
                // 1. Fresnel / Rim Lighting Effect
                float3 normal = normalize(_surface.normal);
                float3 view = normalize(_surface.view);
                float fresnel = 1.0 - max(0.0, dot(normal, view));
                fresnel = pow(fresnel, 3.0);
                
                // 2. Scanning Line Logic
                float scanPos = fract(u_time * 0.2); // Moves from 0 to 1
                float vertPos = fract(_surface.position.y * 0.5 + 0.5); // Normalized Y
                float scanLine = smoothstep(scanPos - 0.02, scanPos, vertPos) * (1.0 - smoothstep(scanPos, scanPos + 0.02, vertPos));
                
                // 3. Grid / Scanline pattern
                float grid = sin(_surface.position.y * 100.0) * 0.5 + 0.5;
                
                // Final Color Integration
                float3 baseTone = float3(0.0, 0.8, 1.0); // Cyan
                float3 finalColor = baseTone * (fresnel * 2.0 + scanLine * 5.0 + 0.2);
                
                _output.color.rgb = finalColor;
                _output.color.a = clamp(fresnel * 0.8 + scanLine + grid * 0.1, 0.0, 1.0);
            """
        ]
        
        func applyRecursive(_ n: SCNNode) {
            n.geometry?.shaderModifiers = shaderModifier
            n.geometry?.firstMaterial?.isDoubleSided = true
            n.geometry?.firstMaterial?.blendMode = .alpha
            for child in n.childNodes {
                applyRecursive(child)
            }
        }
        
        applyRecursive(node)
    }
    
    private func createGridImage() -> UIImage {
        let size: CGFloat = 128
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size, y: 0))
            path.addLine(to: CGPoint(x: size, y: size))
            path.addLine(to: CGPoint(x: 0, y: size))
            path.close()
            
            UIColor.cyan.withAlphaComponent(0.5).setStroke()
            path.lineWidth = 2
            path.stroke()
        }
    }
}

#Preview {
    LandmarkDetailView(landmark: Landmark.samples[2])
}
