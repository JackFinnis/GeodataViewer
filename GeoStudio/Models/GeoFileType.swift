//
//  GeoFileType.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import UniformTypeIdentifiers

enum GeoFileType: String, CaseIterable {
    case geojson
    case kml
    case gpx
    
    var type: UTType {
        switch self {
        case .geojson:
            return .geojson
        case .kml:
            return .kml
        case .gpx:
            return .gpx
        }
    }
}

extension UTType {
    static let geojson = UTType("public.geojson")!
    static let gpx = UTType("com.topografix.gpx")!
    static let kml = UTType("com.google.earth.kml")!
}
