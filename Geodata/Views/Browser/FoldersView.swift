//
//  FilesView.swift
//  Geojson
//
//  Created by Jack Finnis on 10/03/2024.
//

import SwiftUI
import SwiftData
import MapKit

struct FoldersView: View {
    @State var model = Model()
    @Environment(\.modelContext) var context
    @Query(sort: \Folder.name) var folders: [Folder]
    @Query(sort: \File.name) var files: [File]
    @Namespace var namespace
    
    var body: some View {
        let noFolder = files.filter { $0.folder == nil }
        
        NavigationStack(path: $model.path) {
            List {
                if folders.isNotEmpty {
                    NavigationLink(value: true) {
                        Label("All Files", systemImage: "folder")
                            .badge(files.isEmpty ? "0" : String(files.count))
                    }
                }
                NavigationLink(value: false) {
                    Label("Files", systemImage: "folder")
                        .badge(noFolder.isEmpty ? "0" : String(noFolder.count))
                }
                ForEach(folders) { folder in
                    NavigationLink(value: folder) {
                        Label(folder.name, systemImage: "folder")
                            .badge(folder.files.isEmpty ? "0" : String(folder.files.count))
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            context.delete(folder)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        newFolder()
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                }
                ToolbarItem(placement: .status) {
                    Text("")
                }
                ToolbarItem(placement: .bottomBar) {
                    ImportButton(folder: nil)
                }
            }
            .navigationDestination(for: Folder.self) { folder in
                @Bindable var folder = folder
                FolderView(files: folder.files, folder: folder, namespace: namespace, showFolder: false)
                    .navigationTitle($folder.name)
            }
            .navigationDestination(for: Bool.self) { all in
                FolderView(files: all ? files : noFolder, folder: nil, namespace: namespace, showFolder: all)
                    .navigationTitle(all ? "All Files" : "Files")
            }
            .navigationDestination(for: GeoFile.self) { geoFile in
                @Bindable var file = geoFile.file
                MapView(data: geoFile.data, folder: false)
                    .navigationTitle($file.name)
                    .zoomChild(id: file.id, in: namespace)
            }
            .navigationDestination(for: GeoFolder.self) { geoFolder in
                @Bindable var folder = geoFolder.folder
                MapView(data: geoFolder.data, folder: true)
                    .zoomChild(id: folder.id, in: namespace)
            }
        }
        .alert("Import Failed", isPresented: $model.showAlert) {} message: {
            if let error = model.error {
                Text(error.description)
            }
        }
        .onOpenURL { url in
            model.importFile(url: url, webURL: nil, folder: nil, context: context)
        }
        .onAppear {
            model.path.append(folders.isNotEmpty)
        }
        .environment(model)
    }
    
    func newFolder() {
        let folder = Folder()
        context.insert(folder)
        model.path.append(folder)
    }
}

#Preview {
    FoldersView()
}

