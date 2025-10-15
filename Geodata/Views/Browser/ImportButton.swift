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
                        await model.handleFetchFile(webURL: url, context: modelContext)
                    }
                } label: {
                    Label("Paste File URL", systemImage: "document.on.clipboard")
                }
            }
            Section("Create Files") {
                Button {
                    model.map = .record
                } label: {
                    Label("Record Route", systemImage: "record.circle")
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
