//
//  ImportButton.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import SwiftUI
import SwiftData

struct ImportButton: View {
    @Environment(Model.self) var model
    @Environment(\.modelContext) var modelContext
    @State var showFileImporter = false
    
    var body: some View {
        Menu {
            Section("Import") {
                Button {
                    showFileImporter = true
                } label: {
                    Text("Choose Files")
                    Text(".gpx, .kml, .geojson")
                    Image(systemName: "folder")
                }
                Button {
                    guard let string = UIPasteboard.general.string,
                          let url = URL(string: string)
                    else { return }
                    Task {
                        await model.handleFetchFile(webURL: url, context: modelContext)
                    }
                } label: {
                    Text("Paste Link")
                    Text("https://example.com/route.gpx")
                    Image(systemName: "link")
                }
            }
            Section("Create") {
                Button {
                    model.map = .record
                } label: {
                    Text("Record Route")
                    Text("Saves as .gpx")
                    Image(systemName: "record.circle")
                }
            }
        } label: {
            Label("Import Files", systemImage: "plus")
        }
        .menuOrder(.fixed)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: GeoFileType.allCases.map(\.type), allowsMultipleSelection: true) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let urls):
                if urls.count == 1 {
                    model.handleImportFile(url: urls.first!, context: modelContext)
                } else {
                    model.handleImportFiles(urls: urls, context: modelContext)
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: File.self)
    return FoldersView().modelContainer(container)
}
