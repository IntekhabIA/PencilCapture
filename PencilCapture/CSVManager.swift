import Foundation

class CSVManager {

    static let shared = CSVManager()
    private init() {}

    // MARK: - File location
    var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("pencil_strokes.csv")
    }

    // MARK: - How many data rows have been saved so far
    var currentEntryCount: Int {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let existing = try? String(contentsOf: fileURL, encoding: .utf8)
        else { return 0 }
        return max(0, existing
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .count - 1)
    }

    // MARK: - Append one aggregated row from all strokes on screen
    // Returns an error string on failure, nil on success
    func appendEntry(from strokes: [Stroke]) -> String? {
        let fileManager = FileManager.default
        var newRows     = ""

        // Write header only if file doesn't exist yet
        if !fileManager.fileExists(atPath: fileURL.path) {
            newRows += "entry_index,total_strokes,total_points,total_duration_ms,"
            newRows += "mean_force,min_force,max_force,force_variance,"
            newRows += "mean_altitude,mean_azimuth,"
            newRows += "path_length,mean_speed_px_per_sec\n"
        }

        let nextIndex = currentEntryCount

        // Flatten all points across all strokes
        let allPoints = strokes.flatMap { $0.points }
        guard allPoints.count > 1 else {
            return "Not enough data to save. Write more before accepting."
        }

        let totalStrokes   = strokes.count
        let totalPoints    = allPoints.count
        let firstTimestamp = strokes.first!.points.first!.timestamp
        let lastTimestamp  = strokes.last!.points.last!.timestamp
        let totalDuration  = (lastTimestamp - firstTimestamp) * 1000

        // Force stats
        let forces    = allPoints.map { $0.force }
        let meanForce = forces.reduce(0, +) / Double(forces.count)
        let minForce  = forces.min() ?? 0
        let maxForce  = forces.max() ?? 0
        let forceVar  = forces.map { pow($0 - meanForce, 2) }
                              .reduce(0, +) / Double(forces.count)

        // Angle stats
        let meanAlt = allPoints.map { $0.altitudeAngle }.reduce(0, +) / Double(allPoints.count)
        let meanAz  = allPoints.map { $0.azimuthAngle  }.reduce(0, +) / Double(allPoints.count)

        // Path length — calculated within each stroke, not across pen lifts
        var pathLength = 0.0
        for stroke in strokes {
            let pts = stroke.points
            for j in 1..<pts.count {
                let dx = pts[j].x - pts[j-1].x
                let dy = pts[j].y - pts[j-1].y
                pathLength += sqrt(dx*dx + dy*dy)
            }
        }

        // Mean speed
        let totalSec  = lastTimestamp - firstTimestamp
        let meanSpeed = totalSec > 0 ? pathLength / totalSec : 0

        // Build row
        newRows += "\(nextIndex),\(totalStrokes),\(totalPoints),"
        newRows += "\(String(format: "%.2f",  totalDuration)),"
        newRows += "\(String(format: "%.6f",  meanForce)),"
        newRows += "\(String(format: "%.6f",  minForce)),"
        newRows += "\(String(format: "%.6f",  maxForce)),"
        newRows += "\(String(format: "%.6f",  forceVar)),"
        newRows += "\(String(format: "%.6f",  meanAlt)),"
        newRows += "\(String(format: "%.6f",  meanAz)),"
        newRows += "\(String(format: "%.4f",  pathLength)),"
        newRows += "\(String(format: "%.4f",  meanSpeed))\n"

        // Append to file
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                let handle = try FileHandle(forWritingTo: fileURL)
                handle.seekToEndOfFile()
                if let data = newRows.data(using: .utf8) {
                    handle.write(data)
                }
                handle.closeFile()
            } else {
                try newRows.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            return nil  // success
        } catch {
            return "Failed to save: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete the CSV file (called after export)
    func deleteFile() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
