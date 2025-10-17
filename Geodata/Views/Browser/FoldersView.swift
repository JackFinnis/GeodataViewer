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
    @AppStorage("featuresUsed") var featuresUsed = 0
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
            .navigationSubtitle(folders.count.formatted(singular: "Folder"))
            .navigationBarTitleDisplayMode(.inline)
            .contentMargins(.top, 0)
            .toolbarTitleMenu {
                Section("Geodata") {
                    Button {
                        requestReview()
                    } label: {
                        Label("Rate This App", systemImage: "star")
                    }
                    Link(destination: URL(string: "https://apps.apple.com/app/id6444589175?action=write-review")!) {
                        Label("Leave a Review", systemImage: "quote.bubble")
                    }
                    Link(destination: URL(string: "mailto:jack@jackfinnis.com?subject=Geodata%20Feedback")!) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://apps.apple.com/developer/1633101066")!) {
                        Label("More Apps by Jack", systemImage: "square.grid.2x2")
                    }
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
        .onChange(of: model.map) { _, _ in
            if model.map == nil {
                featuresUsed += 1
            }
        }
        .onChange(of: featuresUsed) { _, _ in
            if featuresUsed.isMultiple(of: 10) {
                requestReview()
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: File.self)
    return FoldersView().modelContainer(container)
}
