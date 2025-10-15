//
//  FilesView.swift
//  Geojson
//
//  Created by Jack Finnis on 10/03/2024.
//

import SwiftUI
import SwiftData
import MapKit
import StoreKit

struct FoldersView: View {
    @State var model = Model()
    @Environment(\.modelContext) var modelContext
    @Environment(\.requestReview) var requestReview
    @Query(sort: \Folder.name) var folders: [Folder]
    @Query(sort: \File.name) var files: [File]
    
    var body: some View {
        let noFolder = files.filter { $0.folder == nil }
        
        NavigationSplitView {
            List(selection: $model.nav) {
                Label("All Files", systemImage: "folder")
                    .badge(files.isEmpty ? "0" : String(files.count))
                    .tag(Nav.allFiles)
                if folders.isNotEmpty {
                    Label("Files", systemImage: "folder")
                        .badge(noFolder.isEmpty ? "0" : String(noFolder.count))
                        .tag(Nav.files)
                }
                ForEach(folders) { folder in
                    Label(folder.name, systemImage: "folder")
                        .badge(folder.files.isEmpty ? "0" : String(folder.files.count))
                        .tag(Nav.folder(folder))
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(folder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("Geodata")
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(.top, 0)
            .toolbarTitleMenu {
                Button {
                    requestReview()
                } label: {
                    Label("Rate Geodata", systemImage: "star")
                }
                Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=Geodata%20Feedback")!) {
                    Label("Improve Geodata", systemImage: "envelope")
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        let folder = Folder()
                        modelContext.insert(folder)
                        model.nav = .folder(folder)
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                }
            }
        } detail: {
            switch model.nav {
            case .allFiles, nil:
                FolderView(folder: nil, files: files, showFolder: true)
                    .navigationTitle("All Files")
            case .files:
                FolderView(folder: nil, files: noFolder, showFolder: false)
                    .navigationTitle("Files")
            case .folder(let folder):
                @Bindable var folder = folder
                FolderView(folder: folder, files: folder.files, showFolder: false)
                    .navigationTitle($folder.name)
            }
        }
        .fullScreenCover(item: $model.map) { map in
            Group {
                switch map {
                case .file(let file, let data):
                    @Bindable var file = file
                    MapView(title: $file.name, data: data)
                case .folder(let folder, let data):
                    @Bindable var folder = folder
                    MapView(title: $folder.name, data: data)
                case .record:
                    MapView(title: .constant(""), data: .empty, recordModel: .init(showRecordView: true))
                }
            }
            .id(map)
        }
        .alert("Import Failed", isPresented: .init {
            model.error != nil
        } set: { _ in
            model.error = nil
        }) {} message: {
            if let error = model.error {
                Text(error.description)
            }
        }
        .onOpenURL { url in
            model.handleImportFile(url: url, context: modelContext)
        }
        .sensoryFeedback(.error, trigger: model.error)
        .sensoryFeedback(.impact, trigger: model.map)
        .environment(model)
        .monospacedDigit()
    }
}

#Preview {
    let container = try! ModelContainer(for: File.self)
    return FoldersView().modelContainer(container)
}
