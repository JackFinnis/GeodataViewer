//
//  File.swift
//  Geojson
//
//  Created by Jack Finnis on 07/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class File {
    var id = UUID()
    var fileExtension: String
    var name: String
    var date: Date
    var webURL: URL?
    var folder: Folder?
    var titleKey: String?
    
    init(fileExtension: String, name: String, webURL: URL? = nil, folder: Folder? = nil) {
        self.fileExtension = fileExtension
        self.name = name
        self.date = .now
        self.webURL = webURL
        self.folder = folder
    }
    
    func delete() {
        try? FileManager.default.removeItem(at: url)
        modelContext?.delete(self)
        try? modelContext?.save()
    }
    
    var url: URL {
        URL
            .documentsDirectory
            .appending(path: id.uuidString)
            .appendingPathExtension(fileExtension)
    }
}
