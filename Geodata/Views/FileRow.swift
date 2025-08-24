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
    @State var geoData: GeoData?
    
    var body: some View {
        Button {
            model.loadFile(file: file, context: context)
        } label: {
            VStack(alignment: .leading) {
                ZStack {
                    if let geoData {
                        MapView(selectedAnnotation: .constant(.none), file: file, data: geoData, mapStandard: true, preview: true)
                    } else {
                        Rectangle()
                            .fill(.fill)
                            .overlay {
                                ProgressView()
                            }
                            .onAppear {
                                geoData = try? GeoParser().parse(url: file.url)
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
                if showFolder {
                    Label(file.folder?.name ?? "Files", systemImage: "folder")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
            .padding(8)
            .background(.background)
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
