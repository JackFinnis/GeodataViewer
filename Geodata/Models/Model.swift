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
    var nav: Nav? = .allFiles
    var map: Map?
    var error: GeoError?
    
    func handleFetchFile(webURL: URL, context: ModelContext) async {
        do {
            let tempURL = try await fetchFile(webURL: webURL)
            let file = try importFile(from: tempURL, webURL: webURL, context: context)
            load(file: file)
        } catch {
            self.error = error
        }
    }
    
    func handleCreateFile(locations: [[CLLocation]], context: ModelContext) {
        do {
            let tempURL = try createFile(locations: locations)
            let file = try importFile(from: tempURL, webURL: nil, context: context)
            load(file: file)
        } catch {
            self.error = error
        }
    }
    
    func handleImportFile(url: URL, context: ModelContext) {
        do {
            let file = try importFile(from: url, webURL: nil, context: context)
            load(file: file)
        } catch {
            self.error = error
        }
    }
    
    func handleImportFiles(urls: [URL], context: ModelContext) {
        do {
            var files: [File] = []
            for url in urls {
                let file = try importFile(from: url, webURL: nil, context: context)
                files.append(file)
            }
        } catch {
            self.error = error
        }
    }
    
    func load(file: File) {
        do {
            let data = try GeoParser().parse(file: file)
            file.date = .now
            map = .file(file, data)
        } catch {
            self.error = error
            file.delete()
        }
    }
    
    func load(folder: Folder) {
        do {
            let parser = GeoParser()
            let data = try folder.files.map(parser.parse).data
            map = .folder(folder, data)
        } catch {
            self.error = error
        }
    }
    
    private func createFile(locations: [[CLLocation]]) throws(GeoError) -> URL {
        let segments = locations.map(\.segment)
        let track = GPXTrack(segments: segments)
        
        let metadata = GPXMetadata()
        metadata.name = "New Route"
        metadata.time = .now
        
        let root = GPXRoot(creator: "Geodata", metadata: metadata)
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
    
    private func importFile(from source: URL, webURL: URL?, context: ModelContext) throws(GeoError) -> File {
        let fileExtension = source.pathExtension
        let name = String(source.deletingPathExtension().lastPathComponent.split(separator: "-").first!)
        let file = File(fileExtension: fileExtension, name: name, webURL: webURL, folder: nav?.folder)
        
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
