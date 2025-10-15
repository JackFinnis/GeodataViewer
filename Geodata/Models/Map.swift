//
//  Map.swift
//  Geodata
//
//  Created by Jack Finnis on 06/10/2025.
//

enum Map: Hashable, Identifiable {
    case record
    case folder(Folder, GeoData)
    case file(File, GeoData)
    
    var id: GeoData? {
        switch self {
        case .record:
            return nil
        case .folder(_, let mapData), .file(_, let mapData):
            return mapData
        }
    }
}
