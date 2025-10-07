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
    let showFolder: Bool
    
    @Environment(\.modelContext) var modelContext
    @Environment(Model.self) var model
    @Query(sort: \Folder.name) var folders: [Folder]
    @State var data: GeoData?
    @State var mapModel = MapModel()
    
    var body: some View {
        Button {
            model.load(file: file)
        } label: {
            VStack {
                ZStack {
                    if let data {
                        MapViewRepresentable(mapModel: nil, recordModel: nil, data: data, preview: true)
                    } else {
                        Rectangle()
                            .fill(.fill)
                            .onAppear {
                                data = try? GeoParser().parse(file: file)
                            }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(16)
                .allowsHitTesting(false)
                .compositingGroup()
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.separator))
                
                Text(file.name)
                    .font(.callout)
                if showFolder {
                    Text(file.folder?.name ?? "Files")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
            .background(.background)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Section(file.name) {
                if let url = file.webURL {
                    Button {
                        Task {
                            file.delete()
                            await model.handleFetchFile(webURL: url, context: modelContext)
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                Menu {
                    Picker("Move", selection: $file.folder) {
                        Label("Files", systemImage: "folder")
                            .tag(nil as Folder?)
                        ForEach(folders) { folder in
                            Label(folder.name, systemImage: "folder")
                                .tag(folder as Folder?)
                        }
                    }
                    Divider()
                    Button {
                        let folder = Folder()
                        modelContext.insert(folder)
                        file.folder = folder
                        model.nav = .folder(folder)
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                } label: {
                    Label("Move", systemImage: "folder")
                }
                ShareLink(item: file.exportURL) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    file.delete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        } preview: {
            if let data {
                MapViewRepresentable(mapModel: nil, recordModel: nil, data: data, preview: true)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: File.self)
    return FoldersView().modelContainer(container)
}
