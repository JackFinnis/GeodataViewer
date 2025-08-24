//
//  Polygon.swift
//  Geojson
//
//  Created by Jack Finnis on 07/02/2025.
//

import Foundation
import MapKit
import GoogleMapsUtils

class Polygon: Annotation {
    let mkPolygon: MKPolygon
    
    init(mkPolygon: MKPolygon, color: UIColor?, properties: Properties) {
        self.mkPolygon = mkPolygon
        super.init(coordinate: mkPolygon.coordinate, properties: properties, color: color)
    }
}

extension Polygon {
    convenience init(polygon: GMUPolygon, placemark: GMUPlacemark, style: GMUStyle?) {
        let exteriorCoords = polygon.paths.first?.coords ?? []
        let interiorCoords = polygon.paths.dropFirst().map(\.coords)
        let mkPolygon = MKPolygon(exteriorCoords: exteriorCoords, interiorCoords: interiorCoords)
        self.init(mkPolygon: mkPolygon, color: style?.strokeColor ?? style?.fillColor, properties: placemark.properties)
    }
    
    convenience init(mkPolygon: MKPolygon, properties: Properties?) {
        self.init(mkPolygon: mkPolygon, color: properties?.color, properties: properties ?? .empty)
    }
}

class MultiPolygon: NSObject {
    let mkMultiPolygon: MKMultiPolygon
    let color: UIColor?
    
    init(color: UIColor?, polygons: [Polygon]) {
        self.mkMultiPolygon = MKMultiPolygon(polygons.map(\.mkPolygon))
        self.color = color
    }
}

extension MultiPolygon: MKOverlay {
    var coordinate: CLLocationCoordinate2D { mkMultiPolygon.coordinate }
    var boundingMapRect: MKMapRect { mkMultiPolygon.boundingMapRect }
}
