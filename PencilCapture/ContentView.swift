import SwiftUI

// Main screen — coordinates the canvas, live readout, and buttons.
// All CSV logic is delegated to CSVManager.
// All drawing is delegated to StrokeDrawingView.
// All touch capture is delegated to PencilCanvasBridge.
struct ContentView: View {

    @State private var livePointCount: Int           = 0
    @State private var lastPoint: StrokePoint?       = nil
    @State private var completedStrokes: [Stroke]    = []
    @State private var capturedPoints: [StrokePoint] = []
    @State private var showingShareSheet             = false
    @State private var showingExportAlert            = false
    @State private var exportAlertMessage            = ""
    @State private var showingSaveConfirmation       = false
    @State private var lastSavedIndex: Int           = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Pencil Capture")
                .font(.headline)
                .padding(.top)

            // Live data readout
            VStack(alignment: .leading, spacing: 4) {
                Text("Points this stroke: \(livePointCount)")
                if let p = lastPoint {
                    Text(String(format: "force: %.3f", p.force))
                    Text(String(format: "altitude: %.3f rad", p.altitudeAngle))
                    Text(String(format: "azimuth: %.3f rad", p.azimuthAngle))
                    Text(String(format: "x: %.1f  y: %.1f", p.x, p.y))
                } else {
                    Text("Write with the Pencil in the box below")
                        .foregroundColor(.secondary)
                }
                Text("Completed strokes: \(completedStrokes.count)")

                if showingSaveConfirmation {
                    Text("✓ Saved as entry \(lastSavedIndex)")
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
            }
            .font(.system(.footnote, design: .monospaced))
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Canvas — 1/3 screen width, centered
            GeometryReader { geo in
                let canvasWidth  = geo.size.width / 3
                let canvasHeight = canvasWidth * 1.2

                ZStack {
                    Color.white
                    StrokeDrawingView(
                        completedStrokes: completedStrokes,
                        livePoints: capturedPoints
                    )
                    PencilCanvasBridge(
                        onPointsUpdate: { points in
                            self.livePointCount = points.count
                            self.lastPoint      = points.last
                            self.capturedPoints = points
                        },
                        onStrokeEnd: {
                            if !self.capturedPoints.isEmpty {
                                self.completedStrokes.append(Stroke(points: self.capturedPoints))
                            }
                            self.capturedPoints = []
                        }
                    )
                }
                .frame(width: canvasWidth, height: canvasHeight)
                .border(Color.gray, width: 1)
                .shadow(color: .gray.opacity(0.2), radius: 4)
                .position(
                    x: geo.size.width / 2,
                    y: geo.size.height / 2
                )
            }

            Spacer()

            // Buttons
            HStack(spacing: 12) {

                Button("Clear") {
                    clearCanvas()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(10)

                Button("Accept & Save") {
                    saveEntry()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(completedStrokes.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(completedStrokes.isEmpty)

                Button("Export CSV") {
                    exportCSV()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }

        .sheet(isPresented: $showingShareSheet, onDismiss: {
            CSVManager.shared.deleteFile()
            clearCanvas()
        }) {
            ShareSheet(items: [CSVManager.shared.fileURL])
        }
        .alert("Nothing to export", isPresented: $showingExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportAlertMessage)
        }
    }

    // MARK: - Actions

    private func clearCanvas() {
        completedStrokes        = []
        capturedPoints          = []
        livePointCount          = 0
        lastPoint               = nil
        showingSaveConfirmation = false
    }

    private func saveEntry() {
        if let error = CSVManager.shared.appendEntry(from: completedStrokes) {
            exportAlertMessage = error
            showingExportAlert = true
            return
        }
        lastSavedIndex = CSVManager.shared.currentEntryCount
        clearCanvas()
        withAnimation { showingSaveConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showingSaveConfirmation = false }
        }
    }

    private func exportCSV() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: CSVManager.shared.fileURL.path),
           let content = try? String(contentsOf: CSVManager.shared.fileURL, encoding: .utf8),
           !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showingShareSheet = true
        } else {
            exportAlertMessage = "No data saved yet. Write a letter and tap Accept & Save first."
            showingExportAlert = true
        }
    }
}

#Preview {
    ContentView()
}
