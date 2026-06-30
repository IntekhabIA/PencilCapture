import UIKit

class PencilCaptureView: UIView {

    var onStrokeUpdate: (([StrokePoint]) -> Void)?
    var onStrokeEnd: (() -> Void)?

    private var currentPoints: [StrokePoint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isMultipleTouchEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func recordPoints(from touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard touch.type == .pencil else { return }

        let allTouches = event?.coalescedTouches(for: touch) ?? [touch]
        for t in allTouches {
            let location = t.location(in: self)
            let point = StrokePoint(
                x: Double(location.x),
                y: Double(location.y),
                timestamp: t.timestamp,
                force: Double(t.force),
                altitudeAngle: Double(t.altitudeAngle),
                azimuthAngle: Double(t.azimuthAngle(in: self))
            )
            currentPoints.append(point)
        }
        onStrokeUpdate?(currentPoints)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.type == .pencil else { return }
        currentPoints = []
        recordPoints(from: touches, event: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        recordPoints(from: touches, event: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.type == .pencil else { return }
        recordPoints(from: touches, event: event)
        onStrokeEnd?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.type == .pencil else { return }
        onStrokeEnd?()
    }
}
