//
//  GeoParser.swift
//  Geojson
//
//  Created by Jack Finnis on 10/03/2024.
//

import MapKit
import CoreGPX
import SwiftUI
import GoogleMapsUtils
import UniformTypeIdentifiers

class GeoParser {
    var geoData: GeoData {
        .init(points: points, polylines: polylines, polygons: polygons)
    }
    
    private var points: [Point] = []
    private var polylines: [Polyline] = []
    private var polygons: [Polygon] = []
    
    private let decoder = JSONDecoder()
    
    func parse(url: URL) throws(GeoError) -> GeoData {
        guard let type = GeoFileType(rawValue: url.pathExtension) else {
            throw GeoError.unsupportedFileType
        }
        
        switch type {
        case .geojson:
            try parseGeoJSON(url: url)
        case .kml:
            try parseKML(url: url)
        case .gpx:
            try parseGPX(url: url)
        }
        
        guard !geoData.empty else {
            throw GeoError.fileEmpty
        }
        
        return geoData
    }
    
    // MARK: - Parse GeoJSON
    func parseGeoJSON(url: URL) throws(GeoError) {
        let objects: [MKGeoJSONObject]
        do {
            let data = try Data(contentsOf: url)
            objects = try MKGeoJSONDecoder().decode(data)
        } catch {
            print(error)
            throw GeoError.invalidGeoJSON
        }
        
        objects.forEach { handleGeoJSONObject($0, properties: nil) }
    }
    
    func handleGeoJSONObject(_ object: MKGeoJSONObject, properties: Properties?) {
        if let feature = object as? MKGeoJSONFeature {
            let dict = try? JSONSerialization.jsonObject(with: feature.properties ?? .init()) as? [String : Any]
            let properties = dict.map(Properties.init)
            feature.geometry.forEach { handleGeoJSONObject($0, properties: properties) }
        } else if let point = object as? MKPointAnnotation {
            points.append(Point(coordinate: point.coordinate, properties: properties))
        } else if let mkPolyline = object as? MKPolyline {
            polylines.append(Polyline(mkPolyline: mkPolyline, properties: properties))
        } else if let multiPolyline = object as? MKMultiPolyline {
            polylines.append(contentsOf: multiPolyline.polylines.map { Polyline(mkPolyline: $0, properties: properties) })
        } else if let mkPolygon = object as? MKPolygon {
            polygons.append(Polygon(mkPolygon: mkPolygon, properties: properties))
        } else if let multiPolygon = object as? MKMultiPolygon {
            polygons.append(contentsOf: multiPolygon.polygons.map { Polygon(mkPolygon: $0, properties: properties) })
        } else if let multiPoint = object as? MKMultiPoint {
            points.append(contentsOf: multiPoint.coordinates.map { Point(coordinate: $0, properties: properties) })
        }
    }
    
    // MARK: - Parse GPX
    func parseGPX(url: URL) throws(GeoError) {
        guard let parser = GPXParser(withURL: url),
              let root = parser.parsedData() else {
            throw GeoError.invalidGPX
        }
        guard root.waypoints.isNotEmpty || root.routes.isNotEmpty || root.tracks.isNotEmpty else {
            throw GeoError.fileEmpty
        }
        
        points.append(contentsOf: root.waypoints.compactMap(Point.init))
        polylines.append(contentsOf: root.routes.map(Polyline.init))
        polylines.append(contentsOf: root.tracks.flatMap(\.segments).map(Polyline.init))
    }
    
    // MARK: - Parse KML
    func parseKML(url: URL) throws(GeoError) {
        let parser = GMUKMLParser(url: url)
        parser.parse()
        
        let placemarks = parser.placemarks.compactMap { $0 as? GMUPlacemark }
        placemarks.forEach { placemark in
            let style = parser.styles.first { $0.styleID.removingStyleVariant == placemark.styleUrl }
            if let point = placemark.geometry as? GMUPoint {
                points.append(Point(point: point, placemark: placemark, style: style))
            } else if let line = placemark.geometry as? GMULineString {
                polylines.append(Polyline(line: line, placemark: placemark, style: style))
            } else if let polygon = placemark.geometry as? GMUPolygon {
                polygons.append(Polygon(polygon: polygon, placemark: placemark, style: style))
            }
        }
    }
}

