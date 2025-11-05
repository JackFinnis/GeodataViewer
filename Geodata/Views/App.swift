//
//  GeodataApp.swift
//  Geodata
//
//  Created by Jack Finnis on 19/11/2022.
//

import SwiftUI
import SwiftData

// MARK: - Todo
// Mark annotations as visited (like London Churches) by storing another property in file Model
// It would be good to be able to add some pins (points) in gpx file. It could be done at three ways (which is most convenient for you):
// Send Paypal to Nemanja

// MARK: - Meh
// Android version
// I usually copy/paste the coordinate just to see if it falls in the polygon.
// Once I'm within the polygon to get an option to validate it: like tick or x, or anything you think it would be good. It could be also useful to have "validation mode" to do that even if I'm not in polygon.

// MARK: - Links
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
        .handlesExternalEvents(matching: ["*"])
    }
}
