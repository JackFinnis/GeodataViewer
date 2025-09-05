//
//  ImportButton.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import SwiftUI
import SwiftData

struct ImportButton: View {
    let folder: Folder?
    
    @Environment(Model.self) var model
    @Environment(\.modelContext) var modelContext
    @State var showFileImporter = false
    
    var body: some View {
        Menu {
            Section("Import Files") {
                Button {
                    showFileImporter = true
                } label: {
                    Label("Choose Files", systemImage: "folder")
                }
                Button {
                    guard let string = UIPasteboard.general.string,
                          let url = URL(string: string)
                    else { return }
                    Task {
                        await model.handleFetchFile(webURL: url, folder: folder, context: modelContext)
                    }
                } label: {
                    Label("Paste File URL", systemImage: "document.on.clipboard")
                }
            }
            Section("Create Files") {
                Button {
                    model.path.append(.record(folder))
                } label: {
                    Label("Record Route", systemImage: "record.circle")
                }
            }
        } label: {
            Label("Import Files", systemImage: "plus")
        }
        .foregroundStyle(.background)
        .font(.headline)
        .menuStyle(.button)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.circle)
        .menuOrder(.fixed)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: GeoFileType.allCases.map(\.type), allowsMultipleSelection: true) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let urls):
                if urls.count == 1 {
                    model.handleImportFile(url: urls.first!, folder: folder, context: modelContext)
                } else {
                    model.handleImportFiles(urls: urls, folder: folder, context: modelContext)
                }
            }
        }
    }
}
