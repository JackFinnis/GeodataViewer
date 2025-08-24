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
    @Environment(\.modelContext) var context
    @State var showFileImporter = false
    
    var body: some View {
        Menu {
            Section("Import File") {
                Button {
                    showFileImporter = true
                } label: {
                    Label("Choose File...", systemImage: "folder")
                }
                Button {
                    guard let string = UIPasteboard.general.string,
                          let url = URL(string: string)
                    else { return }
                    Task {
                        await model.fetchFile(url: url, folder: folder, context: context)
                    }
                } label: {
                    Label("Paste File URL", systemImage: "document.on.clipboard")
                }
            }
        } label: {
            Label("Import File", systemImage: "plus")
        }
        .menuOrder(.fixed)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: GeoFileType.allCases.map(\.type)) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let url):
                model.importFile(url: url, webURL: nil, folder: folder, context: context)
            }
        }
    }
}
