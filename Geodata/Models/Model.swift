//
//  Model.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import SwiftUI
import SwiftData
import CoreLocation
import CoreGPX

@MainActor
@Observable
class Model {
    var path: [NavData] = []
    var error: GeoError?
    var showAlert: Bool = false
    
    func handleFetchFile(webURL: URL, folder: Folder?, context: ModelContext) async {
        do {
            let tempURL = try await fetchFile(webURL: webURL)
            let file = try importFile(from: tempURL, webURL: webURL, folder: folder, context: context)
            load(file: file)
        } catch {
            fail(error: error)
        }
    }
    
    func handleCreateFile(locations: [[CLLocation]], folder: Folder?, context: ModelContext) {
        do {
            let tempURL = try createFile(locations: locations)
            let file = try importFile(from: tempURL, webURL: nil, folder: folder, context: context)
            load(file: file)
        } catch {
            fail(error: error)
        }
    }
    
    func handleImportFile(url: URL, folder: Folder?, context: ModelContext) {
        do {
            let file = try importFile(from: url, webURL: nil, folder: folder, context: context)
            load(file: file)
        } catch {
            fail(error: error)
        }
    }
    
    func handleImportFiles(urls: [URL], folder: Folder?, context: ModelContext) {
        do {
            var files: [File] = []
            for url in urls {
                let file = try importFile(from: url, webURL: nil, folder: folder, context: context)
                files.append(file)
            }
            if folder == nil {
                path.append(.allFiles)
            }
        } catch {
            fail(error: error)
        }
    }
    
    func load(file: File) {
        do {
            let data = try GeoParser().parse(file: file)
            file.date = .now
            path.append(.mapFile(file, data))
            Haptics.tap()
        } catch {
            fail(error: error)
            file.delete()
        }
    }
    
    func load(folder: Folder) {
        do {
            let parser = GeoParser()
            let data = try folder.files.map(parser.parse).data
            path.append(.mapFolder(folder, data))
            Haptics.tap()
        } catch {
            fail(error: error)
        }
    }
    
    private func fail(error: GeoError) {
        self.error = error
        self.showAlert = true
        Haptics.error()
    }
    
    private func createFile(locations: [[CLLocation]]) throws(GeoError) -> URL {
        let segments = locations.map(\.segment)
        let track = GPXTrack(segments: segments)
        
        let root = GPXRoot(creator: "Geodata Viewer")
        root.add(track: track)
        
        do {
            let filename = "New Route"
            try root.outputToFile(saveAt: .temporaryDirectory, fileName: filename)
            return .temporaryDirectory.appending(path: filename).appendingPathExtension(for: .gpx)
        } catch {
            print(error)
            throw .saveFile
        }
    }
    
    private func fetchFile(webURL: URL) async throws(GeoError) -> URL {
        guard UIApplication.shared.canOpenURL(webURL) else {
            throw .invalidURL
        }
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: webURL)
        } catch {
            print(error)
            throw .noInternet
        }
        
        guard let filename = response.suggestedFilename else {
            throw .unsupportedFileType
        }
        
        do {
            let temp = URL.temporaryDirectory.appending(path: filename)
            try data.write(to: temp)
            return temp
        } catch {
            print(error)
            throw .saveFile
        }
    }
    
    private func importFile(from source: URL, webURL: URL?, folder: Folder?, context: ModelContext) throws(GeoError) -> File {
        let fileExtension = source.pathExtension
        let name = source.deletingPathExtension().lastPathComponent
        let file = File(fileExtension: fileExtension, name: name, webURL: webURL, folder: folder)
        
        do {
            try? FileManager.default.removeItem(at: file.url)
            _ = source.startAccessingSecurityScopedResource()
            try FileManager.default.copyItem(at: source, to: file.url)
            source.stopAccessingSecurityScopedResource()
            context.insert(file)
            return file
        } catch {
            print(error)
            throw .saveFile
        }
    }
}
