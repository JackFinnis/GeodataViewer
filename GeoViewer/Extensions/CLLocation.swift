//
//  CLLocation.swift
//  Geodata
//
//  Created by Jack Finnis on 31/08/2025.
//

import MapKit
import CoreGPX

extension CLLocation {
    var point: GPXTrackPoint {
        .init(elevation: altitude, time: timestamp, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension Array where Element == CLLocation {
    var meters: Double {
        zip(self, dropFirst()).reduce(0) { $0 + $1.0.distance(from: $1.1) }
    }
    
    var polyline: MKPolyline {
        .init(coords: map(\.coordinate))
    }
    
    var segment: GPXTrackSegment {
        .init(points: map(\.point))
    }
}
