//
//  Polyline.swift
//  Geojson
//
//  Created by Jack Finnis on 07/02/2025.
//

import Foundation
import MapKit
import GoogleMapsUtils
import CoreGPX

class Polyline: Annotation {
    let mkPolyline: MKPolyline
    
    init(mkPolyline: MKPolyline, color: UIColor?, properties: Properties) {
        self.mkPolyline = mkPolyline
        let coordinate = mkPolyline.coordinates.middle ?? mkPolyline.coordinate
        super.init(coordinate: coordinate, properties: properties, color: color)
    }
}

extension Polyline {
    convenience init(route: GPXRoute) {
        let coords = route.points.compactMap(\.coord)
        let mkPolyline = MKPolyline(coords: coords)
        self.init(mkPolyline: mkPolyline, color: nil, properties: route.properties)
    }
    
    convenience init(segment: GPXTrackSegment) {
        let coords = segment.points.compactMap(\.coord)
        let mkPolyline = MKPolyline(coords: coords)
        self.init(mkPolyline: mkPolyline, color: nil, properties: .empty)
    }
    
    convenience init(mkPolyline: MKPolyline, properties: Properties?) {
        self.init(mkPolyline: mkPolyline, color: properties?.color, properties: properties ?? .empty)
    }
    
    convenience init(line: GMULineString, placemark: GMUPlacemark, style: GMUStyle?) {
        let mkPolyline = MKPolyline(coords: line.path.coords)
        self.init(mkPolyline: mkPolyline, color: style?.strokeColor, properties: placemark.properties)
    }
}

class MultiPolyline: NSObject {
    let mkMultiPolyline: MKMultiPolyline
    let color: UIColor?
    
    init(color: UIColor?, polylines: [Polyline]) {
        self.mkMultiPolyline = MKMultiPolyline(polylines.map(\.mkPolyline))
        self.color = color
    }
}

extension MultiPolyline: MKOverlay {
    var coordinate: CLLocationCoordinate2D { mkMultiPolyline.coordinate }
    var boundingMapRect: MKMapRect { mkMultiPolyline.boundingMapRect }
}
