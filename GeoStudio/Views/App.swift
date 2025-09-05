//
//  GeoStudioApp.swift
//  GeoStudio
//
//  Created by Jack Finnis on 19/11/2022.
//

import SwiftUI
import SwiftData

// Android version
// Also, I usually copy/paste the coordinate just to see if it falls in the polygon.

// https://cycling.data.tfl.gov.uk/CycleRoutes/CycleRoutes.json
// https://www.google.com/maps/d/u/0/edit?mid=1SvfUi70Q0zSnkRsslNNGDfLixF39NmA
// https://www.google.com/maps/d/u/0/kml?mid=1SvfUi70Q0zSnkRsslNNGDfLixF39NmA&forcekml=1

let defaultColor = UIColor(.orange)

@main
struct GeoStudioApp: App {
    var body: some Scene {
        WindowGroup {
            FoldersView()
                .monospacedDigit()
        }
        .modelContainer(for: File.self)
    }
}
