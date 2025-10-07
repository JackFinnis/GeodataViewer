//
//  CLLocation.swift
//  GeoStudio
//
//  Created by Jack Finnis on 31/08/2025.
//

import MapKit
import CoreGPX

extension CLLocation {
    var point: GPXTrackPoint {
        let extensions = GPXExtensions()
        extensions.append(at: "gpxtpx:TrackPointExtension", contents: [
            "gpxtpx:speed": String(speed),
            "gpxtpx:speedAccuracy": String(speedAccuracy),
            "gpxtpx:course": String(course),
            "gpxtpx:courseAccuracy": String(courseAccuracy),
            "gpxtpx:horizontalAccuracy": String(horizontalAccuracy),
            "gpxtpx:verticalAccuracy": String(verticalAccuracy),
            "gpxtpx:ellipsoidalAltitude": String(ellipsoidalAltitude)
        ])
        return .init(
            elevation: altitude,
            time: timestamp,
            extensions: extensions,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
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
