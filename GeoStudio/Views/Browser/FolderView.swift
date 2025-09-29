//
//  FolderView.swift
//  Geojson
//
//  Created by Jack Finnis on 10/07/2024.
//

import SwiftUI
import SwiftData

struct FolderView: View {
    let files: [File]
    let folder: Folder?
    let showFolder: Bool
    
    @Environment(Model.self) var model
    @State var searchText: String = ""
    @State var isSearching: Bool = false
    
    var body: some View {
        let filteredFiles = files.filter { filter in
            searchText.isEmpty
            || filter.name.localizedStandardContains(searchText)
            || filter.folder?.name.localizedStandardContains(searchText) ?? false
        }
        
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 0, alignment: .top)], spacing: 0) {
                ForEach(filteredFiles) { file in
                    FileRow(file: file, showFolder: showFolder)
                }
            }
            .padding(.horizontal, 8)
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
        .navigationSubtitle(files.count.formatted(singular: "File"))
        .searchable(text: $searchText, isPresented: $isSearching)
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
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
                ImportButton(folder: folder)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: File.self)
    return FoldersView().modelContainer(container)
}
