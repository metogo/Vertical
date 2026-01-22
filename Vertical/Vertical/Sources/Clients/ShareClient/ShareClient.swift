import ComposableArchitecture
import UIKit

@DependencyClient
struct ShareClient {
    var shareImage: @Sendable (UIImage) async -> Void
}

extension ShareClient: DependencyKey {
    static let liveValue = Self(
        shareImage: { image in
            await MainActor.run {
                let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                
                // Find current window scene and root view controller
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    
                    // For iPad support
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = rootVC.view
                        popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    rootVC.present(activityVC, animated: true)
                }
            }
        }
    )
    
    static let testValue = Self(
        shareImage: { _ in }
    )
    
    static let previewValue = Self(
        shareImage: { _ in }
    )
}

extension DependencyValues {
    var shareClient: ShareClient {
        get { self[ShareClient.self] }
        set { self[ShareClient.self] = newValue }
    }
}
