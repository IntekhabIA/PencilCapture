import SwiftUI

struct StrokeDrawingView: View {

    let completedStrokes: [Stroke]
    let livePoints: [StrokePoint]

    var body: some View {
        Canvas { context, _ in
            for stroke in completedStrokes {
                drawStroke(stroke.points, in: &context)
            }
            drawStroke(livePoints, in: &context)
        }
    }

    private func drawStroke(_ points: [StrokePoint], in context: inout GraphicsContext) {
        guard points.count > 1 else { return }
        var path = Path()
        path.move(to: CGPoint(x: points[0].x, y: points[0].y))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point.x, y: point.y))
        }
        context.stroke(path, with: .color(.black), lineWidth: 2)
    }
}
