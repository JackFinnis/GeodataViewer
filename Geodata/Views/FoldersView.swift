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
                FilesView(files: folder.files, folder: folder, namespace: namespace)
                    .navigationTitle($folder.name)
            }
            .navigationDestination(for: Bool.self) { all in
                FilesView(files: all ? files : noFolder, folder: nil, namespace: namespace)
                    .navigationTitle(all ? "All Files" : "Files")
            }
            .navigationDestination(for: FileData.self) { fileData in
                FileView(file: fileData.file, data: fileData.data, namespace: namespace)
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

