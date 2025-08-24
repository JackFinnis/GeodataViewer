//
//  GeoData.swift
//  Geojson
//
//  Created by Jack Finnis on 10/03/2024.
//

import Foundation
import MapKit

struct GeoData: Hashable {
    let points: [Point]
    let polylines: [Polyline]
    let polygons: [Polygon]
    
    let multiPolylines: [MultiPolyline]
    let multiPolygons: [MultiPolygon]
    
    init(points: [Point], polylines: [Polyline], polygons: [Polygon]) {
        self.points = points
        self.polylines = polylines
        self.polygons = polygons
        self.multiPolylines = Dictionary(grouping: polylines, by: \.color).map(MultiPolyline.init)
        self.multiPolygons = Dictionary(grouping: polygons, by: \.color).map(MultiPolygon.init)
    }
    
    var rect: MKMapRect { multiPolygons.rect.union(multiPolylines.rect).union(points.rect) }
    var empty: Bool { points.isEmpty && polylines.isEmpty && polygons.isEmpty }
    
    func closestOverlay(to targetCoord: CLLocationCoordinate2D) -> Annotation? {
        var closestOverlay: Annotation?
        var closestDistance: Double = .greatestFiniteMagnitude
        
        for polygon in polygons where polygon.mkPolygon.boundingMapRect.padding().contains(targetCoord.point) {
            let render = MKPolygonRenderer(polygon: polygon.mkPolygon)
            let point = render.point(for: targetCoord.point)
            if render.path.contains(point) {
                return polygon
            }
        }
        
        for polyline in polylines where polyline.mkPolyline.boundingMapRect.padding().contains(targetCoord.point) {
            for coord in polyline.mkPolyline.coordinates {
                let delta = coord.distance(to: targetCoord)
                if delta < closestDistance && delta < 10000 {
                    closestOverlay = polyline
                    closestDistance = delta
                }
            }
        }
        
        return closestOverlay
    }
    
    static var empty: GeoData {
        .init(points: [], polylines: [], polygons: [])
    }
}
