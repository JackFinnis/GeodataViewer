//
//  NavData.swift
//  GeoStudio
//
//  Created by Jack Finnis on 31/08/2025.
//

enum Nav: Hashable {
    case allFiles
    case files
    case folder(Folder)
    
    var folder: Folder? {
        switch self {
        case .allFiles, .files:
            return nil
        case .folder(let folder):
            return folder
        }
    }
}


