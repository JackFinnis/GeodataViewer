//
//  GeoError.swift
//  Geojson
//
//  Created by Jack Finnis on 08/05/2023.
//

import Foundation

enum GeoError: Error {
    case invalidURL
    case noInternet
    case unsupportedFileType
    case fileEmpty
    case invalidGeoJSON
    case invalidGPX
    case invalidKML
    case readFile
    case writeFile
    
    var description: String {
        switch self {
        case .unsupportedFileType:
            return "This file type is not supported. Only files with the following file extensions can be imported: .geojson, .gpx, .kml"
        case .readFile:
            return "Unable to read this file."
        case .writeFile:
            return "Unable to save this file."
        case .fileEmpty:
            return "This file contains no data that can be shown on the map."
        case .invalidGeoJSON:
            return "This file contains invalid GeoJSON data."
        case .invalidGPX:
            return "This file contains invalid GPX data."
        case .invalidKML:
            return "This file contains invalid KML data"
        case .noInternet:
            return "Check your internet connection and try again."
        case .invalidURL:
            return "Copy to your clipboard the URL of the file and try again."
        }
    }
}
