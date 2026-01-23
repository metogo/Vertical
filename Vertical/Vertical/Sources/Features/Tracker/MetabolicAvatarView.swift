import SwiftUI
import SceneKit

struct MetabolicAvatarView: View {
    let intensity: Double // HRR% (0.0 to 1.0)
    let isAMPKActivated: Bool
    
    var body: some View {
        SceneView(
            scene: createScene(),
            options: [.allowsCameraControl, .autoenablesDefaultLighting]
        )
        .background(Color.black) // Ensure black background to fix white box issue
        .transition(.opacity)
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // 1. Dark Bio-Tech Background
        scene.background.contents = UIColor.black
        
        // 2. Setup Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)
        scene.rootNode.addChildNode(cameraNode)
        
        // 3. Central "Biological Matrix" Node
        let rootNode = SCNNode()
        scene.rootNode.addChildNode(rootNode)
        
        // --- Inner Core (Metabolic Soul) ---
        let core = SCNSphere(radius: 0.3)
        let coreNode = SCNNode(geometry: core)
        coreNode.position = SCNVector3(0, 0.4, 0)
        
        let coreMat = SCNMaterial()
        coreMat.diffuse.contents = isAMPKActivated ? UIColor.systemOrange : UIColor.systemCyan
        coreMat.emission.contents = isAMPKActivated ? UIColor.systemRed : UIColor.systemBlue
        coreMat.emission.intensity = 2.0
        core.materials = [coreMat]
        
        let corePulse = SCNAction.sequence([
            .scale(to: 1.2 + (intensity * 0.4), duration: 0.6 - (intensity * 0.3)),
            .scale(to: 1.0, duration: 0.6 - (intensity * 0.3))
        ])
        coreNode.runAction(.repeatForever(corePulse))
        rootNode.addChildNode(coreNode)
        
        // --- Mitochondrial Matrix Shell ---
        let shell = SCNCapsule(capRadius: 0.7, height: 1.6)
        let shellNode = SCNNode(geometry: shell)
        
        let shellMat = SCNMaterial()
        shellMat.fillMode = .lines
        shellMat.diffuse.contents = isAMPKActivated ? UIColor.systemYellow : UIColor.white
        shellMat.emission.contents = (isAMPKActivated ? UIColor.orange : UIColor.blue).withAlphaComponent(0.3)
        shellMat.transparency = 0.5
        shell.materials = [shellMat]
        
        rootNode.addChildNode(shellNode)
        
        // --- Rotating Bio-Rings ---
        for i in 1...2 {
            let ring = SCNTorus(ringRadius: 1.1 + CGFloat(i) * 0.1, pipeRadius: 0.015)
            let ringNode = SCNNode(geometry: ring)
            
            let ringMat = SCNMaterial()
            ringMat.diffuse.contents = isAMPKActivated ? UIColor.systemYellow : UIColor.systemCyan
            ringMat.emission.contents = isAMPKActivated ? UIColor.orange : UIColor.cyan
            ring.materials = [ringMat]
            
            ringNode.rotation = SCNVector4(1, 0, 0, Double.pi / 2 * Double(i))
            let rotate = SCNAction.rotateBy(x: Double.pi * 2, y: Double.pi * (i == 1 ? 1 : -1), z: 0, duration: 12.0)
            ringNode.runAction(.repeatForever(rotate))
            rootNode.addChildNode(ringNode)
        }
        
        // --- Metabolic Energy Particles ---
        if intensity > 0.1 {
            let pSystem = SCNParticleSystem()
            pSystem.birthRate = CGFloat(intensity * 150)
            pSystem.particleSize = 0.03
            pSystem.particleLifeSpan = 1.2
            pSystem.particleVelocity = 1.0
            pSystem.particleColor = isAMPKActivated ? UIColor.orange : UIColor.cyan
            pSystem.emitterShape = shell
            pSystem.particleColorVariation = SCNVector4(0.1, 0.1, 0.1, 0)
            
            // Speed up based on intensity
            pSystem.speedFactor = CGFloat(0.5 + intensity)
            
            rootNode.addParticleSystem(pSystem)
        }
        
        // Gentle overall rotation
        rootNode.runAction(.repeatForever(.rotateBy(x: 0, y: 1.5, z: 0, duration: 10)))
        
        return scene
    }
}

#Preview {
    MetabolicAvatarView(intensity: 0.5, isAMPKActivated: true)
        .frame(width: 300, height: 400)
}
