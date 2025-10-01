//
//  NavData.swift
//  Geodata
//
//  Created by Jack Finnis on 31/08/2025.
//

enum NavData: Hashable {
    case allFiles
    case files
    case record
    case folder(Folder)
    case mapFolder(Folder, MapData)
    case mapFile(File, MapData)
    
    var isMap: Bool {
        switch self {
        case .allFiles, .files, .record, .folder:
            return false
        case .mapFolder, .mapFile:
            return true
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
