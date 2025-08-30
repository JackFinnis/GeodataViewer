//
//  FileRow.swift
//  Geojson
//
//  Created by Jack Finnis on 07/07/2024.
//

import SwiftUI
import SwiftData

struct FileRow: View {
    @Bindable var file: File
    let namespace: Namespace.ID
    let showFolder: Bool
    
    @Environment(\.modelContext) var context
    @Environment(Model.self) var model
    @Query(sort: \Folder.name) var folders: [Folder]
    @State var geoData: FileData?
    
    var body: some View {
        Button {
            model.load(file: file, context: context)
        } label: {
            VStack(alignment: .leading) {
                ZStack {
                    if let geoData {
                        Map(selectedAnnotation: .constant(.none), data: geoData, mapStandard: true, resetAnnotations: false, preview: true)
                    } else {
                        Rectangle()
                            .fill(.fill)
                            .overlay {
                                ProgressView()
                            }
                            .onAppear {
                                geoData = try? GeoParser().parse(file: file)
                            }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(10)
                .allowsHitTesting(false)
                .compositingGroup()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.separator))
                .zoomParent(id: file.id, in: namespace)
                
                Text(file.name)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                if showFolder {
                    Label(file.folder?.name ?? "Files", systemImage: "folder")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
            .padding(8)
            .background(Color(.systemGroupedBackground))
        }
        .buttonStyle(.plain)
        .contextMenu {
            if let url = file.webURL {
                Button {
                    Task {
                        file.delete()
                        await model.fetchFile(url: url, folder: file.folder, context: context)
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            Menu {
                Picker("Move...", selection: $file.folder) {
                    Label("Files", systemImage: "folder")
                        .tag(nil as Folder?)
                    ForEach(folders) { folder in
                        Label(folder.name, systemImage: "folder")
                            .tag(folder as Folder?)
                    }
                }
                Divider()
                Button {
                    moveToNewFolder()
                } label: {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
            } label: {
                Label("Move...", systemImage: "folder")
            }
            Button(role: .destructive) {
                file.delete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func moveToNewFolder() {
        let folder = Folder()
        file.folder = folder
        model.path.append(folder)
    }
}
