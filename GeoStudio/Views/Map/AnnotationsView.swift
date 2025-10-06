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
    @Bindable var mapModel: MapModel
    @Binding var recordModel: RecordModel
    let data: MapData
    
    @Environment(Model.self) var model
    @State var searchText = ""
    @State var isSearching = false
    @State var sort = false
    @State var filterType: AnnotationType?
    @State var detent: PresentationDetent = .mediumDetent
    @State var selectedAnnotationPoint: CGPoint?
    
    var body: some View {
        let annotations = sort ? data.annotations.sorted(using: SortDescriptor(\Annotation.title)) : data.annotations
        let filteredAnnotations = annotations.filter {
            filterType == nil || $0.type == filterType
        }.filter {
            searchText.isEmpty
            || $0.file.name.localizedStandardContains(searchText)
            || $0.properties.string.localizedStandardContains(searchText)
        }
        let groupedAnnotations = Dictionary(grouping: filteredAnnotations, by: \.file)
        let name = searchText.isNotEmpty ? "Result" : (filterType == nil ? "Feature" : filterType!.name)
        
        NavigationStack {
            List {
                ForEach(groupedAnnotations.keys.sorted(using: SortDescriptor(\File.name))) { file in
                    let annotations = Array(groupedAnnotations[file]!)
                    if groupedAnnotations.keys.count == 1 {
                        ForEach(annotations) { annotation in
                            Button {
                                mapModel.selectedAnnotation = annotation
                            } label: {
                                Label(annotation.title ?? annotation.file.name, systemImage: annotation.type.systemImage)
                            }
                        }
                    } else {
                        DisclosureGroup {
                            ForEach(annotations) { annotation in
                                Button {
                                    mapModel.selectedAnnotation = annotation
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
            .searchable(text: $searchText.animation(), isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search \(name)s"))
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle($title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        recordModel.showRecordView.toggle()
                    } label: {
                        Label("Record Route", systemImage: "record.circle")
                    }
                    .tint(recordModel.isRecording ? .red : .none)
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Toggle("Sort by Name", isOn: $sort.animation())
                        Divider()
                        Picker(selection: $filterType.animation()) {
                            ForEach(AnnotationType.allCases, id: \.self) { type in
                                Label("\(type.name)s", systemImage: type.systemImage)
                                    .tag(type as AnnotationType?)
                            }
                        } label: {
                            if let filterType {
                                Label("Filter", systemImage: filterType.systemImage)
                            } else {
                                Text("Filter")
                            }
                        }
                        .pickerStyle(.menu)
                        if filterType != nil {
                            Button {
                                filterType = nil
                            } label: {
                                Label("Remove Filter", systemImage: "minus.circle")
                            }
                        }
                    } label: {
                        Image(systemName: filterType == nil ? "line.3.horizontal.decrease" : filterType!.systemImage)
                    }
                    .menuOrder(.fixed)
                }
            }
            .navigationDestination(item: $mapModel.selectedAnnotation) { annotation in
                AnnotationView(mapModel: mapModel, annotation: annotation)
            }
            .navigationDestination(isPresented: $recordModel.showRecordView) {
                RecordView(mapModel: mapModel, recordModel: $recordModel)
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
        .onChange(of: mapModel.selectedAnnotation) { _, selectedAnnotation in
            if selectedAnnotation != nil {
                detent = .mediumDetent
            }
        }
        .onSubmit(of: .search) {
            if filteredAnnotations.count == 1, let annotation = filteredAnnotations.first {
                mapModel.selectedAnnotation = annotation
            }
        }
    }
}

extension PresentationDetent {
    static let smallDetent: Self    = .height(130)
    static let mediumDetent: Self   = .height(350)
    static let largeDetent: Self    = .large
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
