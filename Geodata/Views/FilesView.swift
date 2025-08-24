//
//  FolderView.swift
//  Geojson
//
//  Created by Jack Finnis on 10/07/2024.
//

import SwiftUI
import SwiftData

struct FilesView: View {
    let files: [File]
    let folder: Folder?
    let namespace: Namespace.ID
    
    @State var searchText: String = ""
    @State var isSearching: Bool = false
    
    var body: some View {
        let folders = Set(files.map(\.folder))
        let filteredFiles = files.filter { filter in
            searchText.isEmpty
            || filter.name.localizedStandardContains(searchText)
            || filter.folder?.name.localizedStandardContains(searchText) ?? false
        }
        
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 0, alignment: .top)], spacing: 0) {
                ForEach(filteredFiles) { file in
                    FileRow(file: file, namespace: namespace, showFolder: folders.count > 1)
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
        .searchable(text: $searchText, isPresented: $isSearching)
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isSearching {
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("")
                }
                ToolbarItemGroup(placement: .status) {
                    Text(files.count.formatted(singular: "File"))
                        .font(.subheadline)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    ImportButton(folder: folder)
                }
            }
        }
    }
}
