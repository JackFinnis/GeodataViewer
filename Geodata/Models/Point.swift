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
        guard let placemark = try await CLGeocoder().reverseGeocodeLocation(coordinate.location).first else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
        mapItem.name = properties.title ?? mapItem.name
        mapItem.openInMaps()
    }
}

extension Point {
    convenience init?(waypoint: GPXWaypoint) {
        guard let coord = waypoint.coord else { return nil }
        self.init(coordinate: coord, properties: waypoint.properties, color: nil)
    }
    
    convenience init(point: GMUPoint, placemark: GMUPlacemark, style: GMUStyle?) {
        self.init(coordinate: point.coordinate, properties: placemark.properties, color: style?.fillColor)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D, properties: Properties?) {
        self.init(coordinate: coordinate, properties: properties ?? .empty, color: properties?.color)
    }
}
