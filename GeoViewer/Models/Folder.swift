//
//  Folder.swift
//  Geojson
//
//  Created by Jack Finnis on 10/07/2024.
//

import Foundation
import SwiftData

@Model
class Folder {
    var id = UUID()
    var name: String
    var date: Date
    var files: [File]
    
    init(name: String = "New Folder", date: Date = .now, files: [File] = []) {
        self.name = name
        self.date = date
        self.files = files
    }
}
