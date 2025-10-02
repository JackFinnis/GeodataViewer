//
//  NavData.swift
//  Geodata
//
//  Created by Jack Finnis on 31/08/2025.
//

enum Nav: Hashable {
    case allFiles
    case files
    case record
    case folder(Folder)
    case mapFolder(Folder, MapData)
    case mapFile(File, MapData)
    
    var mapData: MapData? {
        switch self {
        case .allFiles, .files, .record, .folder:
            return nil
        case .mapFolder(_, let data), .mapFile(_, let data):
            return data
        }
    }
    
    var file: File? {
        switch self {
        case .allFiles, .files, .record, .folder, .mapFolder:
            return nil
        case .mapFile(let file, _):
            return file
        }
    }
    
    var folder: Folder? {
        switch self {
        case .allFiles, .files, .record:
            return nil
        case .folder(let folder):
            return folder
        case .mapFolder(let folder, _):
            return folder
        case .mapFile(let file, _):
            return file.folder
        }
    }
}
