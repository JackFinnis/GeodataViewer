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
    override func isVisible(in rect: MKMapRect) -> Bool {
        rect.contains(coordinate.point)
    }
    
    @MainActor
    func openInMaps() async throws {
        let mapItem: MKMapItem
        if #available(iOS 26, *) {
            guard let request = MKReverseGeocodingRequest(location: coordinate.location),
                  let item = try await request.mapItems.first
            else { return }
            mapItem = item
        } else {
            guard let placemark = try await CLGeocoder().reverseGeocodeLocation(coordinate.location).first else { return }
            mapItem = MKMapItem(placemark: .init(placemark: placemark))
        }
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
        self.init(file: file, coordinate: coordinate, properties: properties ?? [:], color: properties?.color)
    }
}
