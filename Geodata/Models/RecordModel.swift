//
//  RecordModel.swift
//  Geodata
//
//  Created by Jack Finnis on 31/08/2025.
//

import Foundation
import MapKit

@MainActor
@Observable
class RecordModel: NSObject {
    var state: RecordState = .notStarted
    
    var currentStart: Date = .distantPast
    var previousSeconds: Double = 0
    var duration: Duration {
        .seconds(previousSeconds + (state == .recording ? currentStart.distance(to: .now) : 0))
    }
    
    var currentLine: [CLLocation] = []
    var previousLines: [[CLLocation]] = []
    var lines: [[CLLocation]] {
        previousLines + [currentLine]
    }
    var polylines: [MKPolyline] {
        lines.map(\.polyline)
    }
    var metres: Double {
        lines.map(\.meters).reduce(0) { $0 + $1 }
    }
    
    var requested = false
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func requestAuthorization() {
        requested = true
        locationManager.requestAlwaysAuthorization()
    }
    
    func start() {
        resume()
    }
    
    func resume() {
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
        currentStart = .now
        state = .recording
    }
    
    func pause() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        
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
