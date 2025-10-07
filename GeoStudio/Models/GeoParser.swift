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
    var data: GeoData {
        .init(points: points, polylines: polylines, polygons: polygons)
    }
    
    private var points: [Point] = []
    private var polylines: [Polyline] = []
    private var polygons: [Polygon] = []
    
    private let decoder = JSONDecoder()
    
    func reset() {
        points = []
        polylines = []
        polygons = []
    }
    
    func parse(file: File) throws(GeoError) -> GeoData {
        reset()
        
        guard let type = GeoFileType(rawValue: file.url.pathExtension) else {
            throw GeoError.unsupportedFileType
        }
        
        switch type {
        case .geojson:
            try parseGeoJSON(file: file)
        case .kml:
            try parseKML(file: file)
        case .gpx:
            try parseGPX(file: file)
        }
        
        guard !data.isEmpty else {
            throw GeoError.fileEmpty
        }
        
        return data
    }
    
    // MARK: - Parse GeoJSON
    func parseGeoJSON(file: File) throws(GeoError) {
        let objects: [MKGeoJSONObject]
        do {
            let data = try Data(contentsOf: file.url)
            objects = try MKGeoJSONDecoder().decode(data)
        } catch {
            print(error)
            throw GeoError.invalidGeoJSON
        }
        
        objects.forEach { handleGeoJSONObject($0, properties: nil, file: file) }
    }
    
    func handleGeoJSONObject(_ object: MKGeoJSONObject, properties: Properties?, file: File) {
        if let feature = object as? MKGeoJSONFeature {
            let dict = try? JSONSerialization.jsonObject(with: feature.properties ?? .init()) as? [String : Any]
            let properties = dict.map(Properties.init)
            feature.geometry.forEach { handleGeoJSONObject($0, properties: properties, file: file) }
        } else if let point = object as? MKPointAnnotation {
            points.append(Point(file: file, coordinate: point.coordinate, properties: properties))
        } else if let mkPolyline = object as? MKPolyline {
            polylines.append(Polyline(file: file, mkPolyline: mkPolyline, properties: properties))
        } else if let multiPolyline = object as? MKMultiPolyline {
            polylines.append(contentsOf: multiPolyline.polylines.map { Polyline(file: file, mkPolyline: $0, properties: properties) })
        } else if let mkPolygon = object as? MKPolygon {
            polygons.append(Polygon(file: file, mkPolygon: mkPolygon, properties: properties))
        } else if let multiPolygon = object as? MKMultiPolygon {
            polygons.append(contentsOf: multiPolygon.polygons.map { Polygon(file: file, mkPolygon: $0, properties: properties) })
        } else if let multiPoint = object as? MKMultiPoint {
            points.append(contentsOf: multiPoint.coordinates.map { Point(file: file, coordinate: $0, properties: properties) })
        }
    }
    
    // MARK: - Parse GPX
    func parseGPX(file: File) throws(GeoError) {
        guard let parser = GPXParser(withURL: file.url),
              let root = parser.parsedData() else {
            throw GeoError.invalidGPX
        }
        
        points.append(contentsOf: root.waypoints.compactMap { Point(file: file, waypoint: $0) })
        polylines.append(contentsOf: root.routes.map { Polyline(file: file, route: $0) })
        polylines.append(contentsOf: root.tracks.flatMap(\.segments).map { Polyline(file: file, segment: $0) })
    }
    
    // MARK: - Parse KML
    func parseKML(file: File) throws(GeoError) {
        let parser = GMUKMLParser(url: file.url)
        parser.parse()
        
        let placemarks = parser.placemarks.compactMap { $0 as? GMUPlacemark }
        placemarks.forEach { placemark in
            let style = parser.styles.first { $0.styleID.removingStyleVariant == placemark.styleUrl }
            if let point = placemark.geometry as? GMUPoint {
                points.append(Point(file: file, point: point, placemark: placemark, style: style))
            } else if let line = placemark.geometry as? GMULineString {
                polylines.append(Polyline(file: file, line: line, placemark: placemark, style: style))
            } else if let polygon = placemark.geometry as? GMUPolygon {
                polygons.append(Polygon(file: file, polygon: polygon, placemark: placemark, style: style))
            }
        }
    }
}

