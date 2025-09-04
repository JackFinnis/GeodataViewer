//
//  NavData.swift
//  Geodata
//
//  Created by Jack Finnis on 31/08/2025.
//

enum NavData: Hashable {
    case allFiles
    case files
    case record(Folder?)
    case folder(Folder)
    case mapFolder(Folder, MapData)
    case mapFile(File, MapData)
}
