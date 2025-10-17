//
//  FolderView.swift
//  Geojson
//
//  Created by Jack Finnis on 10/07/2024.
//

import SwiftUI
import SwiftData

struct FolderView: View {
    let folder: Folder?
    let files: [File]
    let showFolder: Bool
    
    @Environment(Model.self) var model
    @State var searchText: String = ""
    
    var body: some View {
        let filteredFiles = files.filter { file in
            searchText.isEmpty
            || file.name.localizedStandardContains(searchText)
            || file.folder?.name.localizedStandardContains(searchText) ?? false
        }
        .sorted(using: SortDescriptor(\File.name))
        
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16, alignment: .top)], spacing: 16) {
                ForEach(filteredFiles) { file in
                    FileRow(file: file, showFolder: showFolder)
                }
            }
            .padding()
        }
        .overlay {
            if files.isEmpty {
                ContentUnavailableView("No Files Yet", systemImage: "mappin.and.ellipse", description: Text("Long press on a file to move it into this folder.\nTap + to import a new file."))
                    .allowsHitTesting(false)
            } else if filteredFiles.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .allowsHitTesting(false)
            }
        }
        .searchable(text: $searchText.animation())
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
        .navigationSubtitle(filteredFiles.count.formatted(singular: searchText.isEmpty ? "File" : "Result"))
        .toolbar {
            if let folder, folder.files.isNotEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        model.load(folder: folder)
                    } label: {
                        Label("View on Map", systemImage: "map")
                    }
                }
            }
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(placement: .bottomBar)
            ToolbarItemGroup(placement: .bottomBar) {
                ImportButton()
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: File.self)
    return FoldersView().modelContainer(container)
}
