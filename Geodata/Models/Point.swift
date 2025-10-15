//
//  Point.swift
//  Geojson
//
//  Created by Jack Finnis on 11/05/2023.
//

import Foundation
import MapKit
import CoreGPX
import GoogleMapsUtils

class Point: Annotation {
    func openInMaps() async throws {
        guard let request = MKReverseGeocodingRequest(location: coordinate.location) else { return }
        let mapItems = try await request.mapItems
        guard let mapItem = mapItems.first else { return }
        mapItem.name = properties.title ?? mapItem.name
        mapItem.openInMaps()
    }
}

extension Point {
    convenience init?(file: File, waypoint: GPXWaypoint) {
        guard let coord = waypoint.coord else { return nil }
        self.init(file: file, coordinate: coord, properties: waypoint.properties, color: nil)
    }
    
    convenience init(file: File, point: GMUPoint, placemark: GMUPlacemark, style: GMUStyle?) {
        self.init(file: file, coordinate: point.coordinate, properties: placemark.properties, color: style?.fillColor)
    }
    
    convenience init(file: File, coordinate: CLLocationCoordinate2D, properties: Properties?) {
        self.init(file: file, coordinate: coordinate, properties: properties ?? .empty, color: properties?.color)
    }
}
