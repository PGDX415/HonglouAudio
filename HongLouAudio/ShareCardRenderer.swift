//
//  ShareCardRenderer.swift
//  HongLouAudio
//
//  Created by Paul Dexin Gong on 2026/8/4.
//

import SwiftUI

/// Renders a SwiftUI view into a UIImage for sharing.
struct ShareCardRenderer {
    /// Renders a view into a UIImage at the given size
    @MainActor
    static func render<V: View>(_ view: V, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        let window = UIWindow(windowScene: windowScene)
        window.frame = CGRect(origin: .zero, size: size)
        window.rootViewController = controller

        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            controller.view.drawHierarchy(in: ctx.format.bounds, afterScreenUpdates: true)
        }
    }

    /// Present the system share sheet with image
    @MainActor
    static func share(image: UIImage, items: [Any] = []) {
        var activityItems: [Any] = [image]
        activityItems.append(contentsOf: items)
        let av = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            if let popover = av.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(av, animated: true)
        }
    }
}
