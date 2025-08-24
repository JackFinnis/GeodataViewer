//
//  Model.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import SwiftUI
import SwiftData

@MainActor
@Observable
class Model {
    var path = NavigationPath()
    var error: GeoError?
    var showAlert: Bool = false
    
    func fetchFile(url: URL, folder: Folder?, context: ModelContext) async {
        guard UIApplication.shared.canOpenURL(url) else {
            fail(error: .invalidURL)
            return
        }
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            print(error)
            fail(error: .noInternet)
            return
        }
        
        guard let filename = response.suggestedFilename else {
            fail(error: .unsupportedFileType)
            return
        }
        
        do {
            let temp = URL.temporaryDirectory.appending(path: filename)
            try data.write(to: temp)
            importFile(url: temp, webURL: url, folder: folder, context: context)
        } catch {
            print(error)
            fail(error: .writeFile)
        }
    }
    
    func importFile(url source: URL, webURL: URL?, folder: Folder?, context: ModelContext) {
        let fileExtension = source.pathExtension
        let name = String(source.lastPathComponent.dropLast(fileExtension.count + 1))
        let file = File(fileExtension: fileExtension, name: name, webURL: webURL, folder: folder)
        
        do {
            try? FileManager.default.removeItem(at: file.url)
            _ = source.startAccessingSecurityScopedResource()
            try FileManager.default.copyItem(at: source, to: file.url)
            source.stopAccessingSecurityScopedResource()
            
            loadFile(file: file, context: context)
        } catch {
            print(error)
            fail(error: .writeFile)
        }
    }
    
    func loadFile(file: File, context: ModelContext) {
        do {
            let geoData = try GeoParser().parse(url: file.url)
            file.date = .now
            path.append(FileData(file: file, data: geoData))
            context.insert(file)
            Haptics.tap()
        } catch {
            fail(error: error)
        }
    }
    
    func fail(error: GeoError) {
        self.error = error
        self.showAlert = true
        Haptics.error()
    }
}
