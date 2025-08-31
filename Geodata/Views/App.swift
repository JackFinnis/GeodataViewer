//
//  GeojsonApp.swift
//  Geojson
//
//  Created by Jack Finnis on 19/11/2022.
//

import SwiftUI
import SwiftData

// Android version
// Also, I usually copy/paste the coordinate just to see if it falls in the polygon.
// 2) Yes and no. By traces I mean a feature that tracks your location for a period of time, but it doesn't need to save the track (it is called GPX trace and it is LineString). App should keep my traces visible for the current session (if the feature is turned on). It would be a great addition if the app can save the trace file (GPX LineString) to a file that could be then viewed!

// https://cycling.data.tfl.gov.uk/CycleRoutes/CycleRoutes.json
// https://www.google.com/maps/d/u/0/edit?mid=1SvfUi70Q0zSnkRsslNNGDfLixF39NmA
// https://www.google.com/maps/d/u/0/kml?mid=1SvfUi70Q0zSnkRsslNNGDfLixF39NmA&forcekml=1

let defaultColor = UIColor(.orange)

@main
struct GeodataApp: App {
    var body: some Scene {
        WindowGroup {
            FoldersView()
        }
        .modelContainer(for: File.self)
    }
}
