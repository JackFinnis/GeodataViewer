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
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Folder.name) var folders: [Folder]
    @Query(sort: \File.name) var files: [File]
    
    var body: some View {
        let noFolder = files.filter { $0.folder == nil }
        
        NavigationStack(path: $model.path) {
            List {
                if folders.isNotEmpty {
                    NavigationLink(value: NavData.allFiles) {
                        Label("All Files", systemImage: "folder")
                            .badge(files.isEmpty ? "0" : String(files.count))
                    }
                }
                NavigationLink(value: NavData.files) {
                    Label("Files", systemImage: "folder")
                        .badge(noFolder.isEmpty ? "0" : String(noFolder.count))
                }
                ForEach(folders) { folder in
                    NavigationLink(value: NavData.folder(folder)) {
                        Label(folder.name, systemImage: "folder")
                            .badge(folder.files.isEmpty ? "0" : String(folder.files.count))
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(folder)
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
            .navigationDestination(for: NavData.self) { navData in
                switch navData {
                case .allFiles:
                    FolderView(files: files, folder: nil, showFolder: true)
                        .navigationTitle("All Files")
                case .files:
                    FolderView(files: noFolder, folder: nil, showFolder: false)
                        .navigationTitle("Files")
                case .folder(let folder):
                    @Bindable var folder = folder
                    FolderView(files: folder.files, folder: folder, showFolder: false)
                        .navigationTitle($folder.name)
                case .mapFile(let file, let data):
                    @Bindable var file = file
                    MapView(title: $file.name, data: data, folder: nil)
                case .mapFolder(let folder, let data):
                    @Bindable var folder = folder
                    MapView(title: $folder.name, data: data, folder: folder)
                case .record(let folder):
                    MapView(title: .constant(""), data: .empty, folder: folder, recordModel: .init())
                }
            }
        }
        .alert("Import Failed", isPresented: $model.showAlert) {} message: {
            if let error = model.error {
                Text(error.description)
            }
        }
        .onOpenURL { url in
            model.handleImportFile(url: url, folder: nil, context: modelContext)
        }
        .onAppear {
            model.path.append(folders.isNotEmpty ? .allFiles : .files)
        }
        .environment(model)
    }
    
    func newFolder() {
        let folder = Folder()
        modelContext.insert(folder)
        model.path.append(.folder(folder))
    }
}

#Preview {
    FoldersView()
}

