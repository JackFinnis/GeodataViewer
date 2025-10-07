//
//  RecordModel.swift
//  GeoStudio
//
//  Created by Jack Finnis on 31/08/2025.
//

import Foundation
import MapKit

enum RecordState {
    case notStarted
    case recording
    case paused
    case stopped
}

@MainActor
@Observable
class RecordModel: NSObject, Identifiable {
    var showRecordView: Bool
    var state: RecordState = .notStarted
    var currentStart: Date = .distantPast
    var previousSeconds: Double = 0
    var currentLine: [CLLocation] = []
    var previousLines: [[CLLocation]] = []
    
    var isRecording: Bool {
        state != .notStarted
    }
    var duration: Duration {
        .seconds(previousSeconds + (state == .recording ? currentStart.distance(to: .now) : 0))
    }
    var lines: [[CLLocation]] {
        previousLines + [currentLine]
    }
    var polylines: [MKPolyline] {
        lines.map(\.polyline)
    }
    var metres: Double {
        lines.map(\.meters).reduce(0) { $0 + $1 }
    }
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private let locationManager = CLLocationManager()
    
    init(showRecordView: Bool = false) {
        self.showRecordView = showRecordView
        super.init()
        setupLocationManager()
    }
    
    func start() {
        resume()
    }
    
    func resume() {
        startUpdatingLocation()
        currentStart = .now
        state = .recording
    }
    
    func pause() {
        stopUpdatingLocation()
        previousSeconds += currentStart.distance(to: .now)
        state = .paused
        if currentLine.isNotEmpty {
            previousLines.append(currentLine)
            currentLine = []
        }
    }
    
    func stop() {
        if state == .recording {
            pause()
        }
        state = .stopped
    }
}

extension RecordModel: CLLocationManagerDelegate {
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard state == .recording else { return }
            self.currentLine.append(contentsOf: locations)
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorizationStatus = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = authorizationStatus
        }
    }
}
