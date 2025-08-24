//
//  GeojsonApp.swift
//  Geojson
//
//  Created by Jack Finnis on 19/11/2022.
//

import SwiftUI
import SwiftData

// Add more than one file
// Query on the name attribute or others
// Android version

// 1) Both GeoJSON “properties” by key and value, and by lat long coordinate would be great. For example. I have the city name as one of the properties. It would be great if it is searchable (e.g. Belgrade). Also, I usually copy/paste the coordinate just to see if it falls in the polygon.
// 2) Yes and no. By traces I mean a feature that tracks your location for a period of time, but it doesn't need to save the track (it is called GPX trace and it is LineString). App should keep my traces visible for the current session (if the feature is turned on). It would be a great addition if the app can save the trace file (GPX LineString) to a file that could be then viewed!
// 3) Please, if possible, add an option Always on screen, since I'm now doing a workaround - go to settings and change auto-lock function to maximum 5 minutes.

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
