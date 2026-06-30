# PencilCapture

An iPad app for capturing Apple Pencil handwriting data as part of a dyslexia screening research project.

## Overview

PencilCapture records raw Apple Pencil stroke data when a child writes letters on the iPad. Each letter entry is saved as a single row in a CSV file containing aggregated handwriting features that can be used to approximate the probability of dyslexia.

The app captures data that is not accessible through web or cross-platform frameworks — specifically the full Apple Pencil sensor stream including pressure, tilt angle, and azimuth angle at near-240Hz sampling rate.

## Research Background

Based on findings from multiple peer-reviewed studies:

- Children with dyslexia frequently show poor and slow handwriting, particularly on graphically complex letters (ScienceDirect, 2019)
- Graphomotor difficulties in dyslexia exist independently of spelling deficits
- Structural handwriting features — loops, slant, stroke thickness, pressure — can be extracted automatically to identify behavioural and neurological patterns (IET Research, 2019)
- Writing involves transcription, working memory, and executive function — all areas where dyslexic individuals may show deficits

## Features

- Apple Pencil only input — finger touches are rejected
- Real-time live readout of force, altitude angle, azimuth angle, and position
- Drawing canvas showing strokes in real time
- Accept & Save — aggregates all strokes for one letter into a single CSV row
- Export CSV — exports the full session file via AirDrop or Files, then resets for a new session
- Clear — wipes the canvas without saving

## CSV Output

Each row represents one letter entry (one tap of Accept & Save), regardless of how many strokes were used to write it.

| Column | Description |
|---|---|
| `entry_index` | Sequential entry number |
| `total_strokes` | Number of pen-down/up sequences used to write the letter |
| `total_points` | Total sample points captured across all strokes |
| `total_duration_ms` | Time from first to last point in milliseconds |
| `mean_force` | Average Apple Pencil pressure across all points |
| `min_force` | Minimum pressure recorded |
| `max_force` | Maximum pressure recorded |
| `force_variance` | Variance in pressure — high value indicates unstable motor control |
| `mean_altitude` | Average tilt angle of the pencil in radians |
| `mean_azimuth` | Average compass direction of the pencil in radians |
| `path_length` | Total distance traveled by the pencil tip in pixels |
| `mean_speed_px_per_sec` | Average writing speed in pixels per second |

## Dyslexia Parameters

These features map directly to indicators identified in the research literature:

- **force_variance** — high variance signals graphomotor instability
- **total_strokes** — more strokes per letter may indicate motor planning difficulty
- **total_duration_ms** — slower writing on complex letters is a documented dyslexia indicator
- **mean_altitude / mean_azimuth** — grip consistency across letters
- **path_length** — long path for a simple letter suggests shakiness or tremor
- **mean_speed_px_per_sec** — speed drop on complex letters vs simple ones

## Project Structure
PencilCapture/
├── PencilCaptureApp.swift      — App entry point (@main)
├── Models.swift                — StrokePoint and Stroke data models
├── PencilCaptureView.swift     — UIKit touch capture via UITouch and coalescedTouches
├── PencilCanvasBridge.swift    — SwiftUI wrapper around PencilCaptureView
├── StrokeDrawingView.swift     — SwiftUI Canvas drawing layer
├── ShareSheet.swift            — UIActivityViewController wrapper for export
├── CSVManager.swift            — All CSV file logic (append, export, delete)
└── ContentView.swift           — Main screen UI

## Requirements

- iPad with Apple Pencil (1st or 2nd generation)
- iPadOS 16.0 or later
- Xcode 15 or later for building

## Important Note

This app is a **screening tool**, not a diagnostic instrument. Output should be used as a risk indicator alongside professional clinical assessment. A high score does not confirm dyslexia — it flags cases that warrant further evaluation by a qualified professional.

## References

- International Dyslexia Association — Dyslexia Basics
- British Dyslexia Association — Signs of Dyslexia (Primary Age)
- PMC — Defining and Understanding Dyslexia: Past, Present and Future
- ScienceDirect — Do children with dyslexia present a handwriting deficit?
- IET Research — Graphology based handwritten character analysis for human behaviour identification
- PMC — Handprints of the Mind: Decoding Personality Traits and Handwriting
