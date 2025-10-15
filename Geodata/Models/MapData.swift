//
//  MapData.swift
//  Geojson
//
//  Created by Jack Finnis on 10/03/2024.
//

import Foundation
import MapKit

extension Array where Element == GeoData {
    var data: GeoData {
        let points = flatMap(\.points)
        let polylines = flatMap(\.polylines)
        let polygons = flatMap(\.polygons)
        return .init(points: points, polylines: polylines, polygons: polygons)
    }
}

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
    var isEmpty: Bool { points.isEmpty && polylines.isEmpty && polygons.isEmpty }
    var annotations: [Annotation] { points + polylines + polygons }
    
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
    
    @MainActor
    static let empty = GeoData(points: [], polylines: [], polygons: [])
    @MainActor
    static let example = GeoData(points: [
        .init(file: .example, coordinate: .init(latitude: 51, longitude: 0), properties: nil)
    ], polylines: [
        .init(file: .example, mkPolyline: .init(), properties: nil)
    ], polygons: [
        .init(file: .example, mkPolygon: .init(), properties: nil)
    ])
}
