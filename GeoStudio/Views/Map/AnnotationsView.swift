//
//  AnnotationsView.swift
//  Geodata
//
//  Created by Jack Finnis on 31/08/2025.
//

import SwiftUI
import MapKit

struct AnnotationsView: View {
    @Binding var title: String
    @Binding var zoomToAnnotation: Annotation?
    @Binding var selectedAnnotation: Annotation?
    let data: MapData
    let folder: Folder?
    
    @State var searchText = ""
    @State var isSearching = false
    @State var sort = false
    @State var detent: PresentationDetent = .mediumDetent
    
    var body: some View {
        let annotations = sort ? data.annotations.sorted(using: SortDescriptor(\Annotation.title)) : data.annotations
        let filteredAnnotations = annotations.filter {
            searchText.isEmpty
            || $0.file.name.localizedStandardContains(searchText)
            || $0.properties.string.localizedStandardContains(searchText)
        }
        let groupedAnnotations = Dictionary(grouping: filteredAnnotations, by: \.file)
        
        NavigationStack {
            List {
                ForEach(groupedAnnotations.keys.sorted(using: SortDescriptor(\File.name))) { file in
                    if folder == nil {
                        ForEach(Array(groupedAnnotations[file]!)) { annotation in
                            Button {
                                selectAnnotation(annotation)
                            } label: {
                                Label(annotation.title ?? annotation.file.name, systemImage: annotation.type.systemImage)
                            }
                        }
                    } else {
                        DisclosureGroup {
                            ForEach(Array(groupedAnnotations[file]!)) { annotation in
                                Button {
                                    selectAnnotation(annotation)
                                } label: {
                                    Label(annotation.title ?? annotation.file.name, systemImage: annotation.type.systemImage)
                                }
                            }
                        } label: {
                            Text(file.name)
                                .font(.headline)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .animation(.default, value: filteredAnnotations)
            .listStyle(.plain)
            .searchable(text: $searchText.animation(), isPresented: $isSearching, prompt: Text("Search Features"))
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle($title)
            .navigationSubtitle(filteredAnnotations.count.formatted(singular: searchText.isNotEmpty ? "Result" : "Feature"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(removing: detent == .smallDetent ? .title : nil)
            .toolbar {
                if detent != .smallDetent {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Toggle("Sort Features", isOn: $sort.animation())
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled)
        .presentationDetents([.smallDetent, .mediumDetent, .largeDetent], selection: $detent)
        .onChange(of: detent) { _, detent in
            if detent != .largeDetent {
                isSearching = false
                searchText = ""
            }
        }
        .onChange(of: isSearching) { _, isSearching in
            if isSearching {
                detent = .largeDetent
            }
        }
        .onSubmit(of: .search) {
            if filteredAnnotations.count == 1, let annotation = filteredAnnotations.first {
                selectAnnotation(annotation)
            }
        }
    }
    
    func selectAnnotation(_ annotation: Annotation) {
        zoomToAnnotation = annotation
        selectedAnnotation = annotation
        detent = .mediumDetent
    }
}

extension PresentationDetent {
    static let smallDetent: Self    = .height(105)
    static let mediumDetent: Self   = .height(350)
    static let largeDetent: Self    = .large
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example, folder: nil)
    }
    .environment(Model())
}
