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
    @Binding var setUserTrackingMode: MKUserTrackingMode?
    @Binding var refreshAnnotations: Bool
    @Binding var recordModel: RecordModel
    let data: MapData
    
    @Environment(Model.self) var model
    @State var searchText = ""
    @State var isSearching = false
    @State var sort = false
    @State var filterType: AnnotationType?
    @State var detent: PresentationDetent = .mediumDetent
    
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
                                selectAnnotation(annotation)
                            } label: {
                                Label(annotation.title ?? annotation.file.name, systemImage: annotation.type.systemImage)
                            }
                        }
                    } else {
                        DisclosureGroup {
                            ForEach(annotations) { annotation in
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
            .searchable(text: $searchText.animation(), isPresented: $isSearching, prompt: Text("Search \(name)s"))
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle($title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(removing: detent == .smallDetent ? .title : nil)
            .toolbar {
                if detent != .smallDetent {
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
        .sheet(item: $selectedAnnotation) { annotation in
            AnnotationView(refreshAnnotations: $refreshAnnotations, zoomToAnnotation: $zoomToAnnotation, annotation: annotation)
        }
        .sheet(isPresented: $recordModel.showRecordView) {
            RecordView(recordModel: $recordModel, setUserTrackingMode: $setUserTrackingMode)
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
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
