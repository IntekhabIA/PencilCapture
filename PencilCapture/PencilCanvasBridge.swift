import SwiftUI

// SwiftUI wrapper around PencilCaptureView.
// Bridges UIKit touch callbacks into SwiftUI-friendly closures.
struct PencilCanvasBridge: UIViewRepresentable {

    var onPointsUpdate: ([StrokePoint]) -> Void
    var onStrokeEnd: () -> Void

    func makeUIView(context: Context) -> PencilCaptureView {
        let view = PencilCaptureView()
        view.onStrokeUpdate = { points in onPointsUpdate(points) }
        view.onStrokeEnd = { onStrokeEnd() }
        return view
    }

    func updateUIView(_ uiView: PencilCaptureView, context: Context) {}
}
