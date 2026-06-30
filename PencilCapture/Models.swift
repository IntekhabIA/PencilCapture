import Foundation

// A single sample point captured from the Apple Pencil
struct StrokePoint: Codable {
    let x: Double
    let y: Double
    let timestamp: Double       // high-precision seconds
    let force: Double           // pressure: 0.0 – 1.0+
    let altitudeAngle: Double   // radians: 0 = flat, π/2 = upright
    let azimuthAngle: Double    // radians: compass direction of pencil
}

// A single stroke — one pen-down to pen-up sequence
struct Stroke: Codable {
    var points: [StrokePoint] = []
}
