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
    let data: GeoData
    
    @Environment(Model.self) var model
    @State var searchText = ""
    @State var isSearching = false
    @State var sort = false
    @State var filterTypes: Set<AnnotationType> = []
    @State var filterVisible = false
    @State var detent: PresentationDetent = .mediumDetent
    @State var selectedAnnotationPoint: CGPoint?
    
    var body: some View {
        let annotations = sort ? data.annotations.sorted(using: SortDescriptor(\.title)) : data.annotations
        let filteredAnnotations = annotations.filter {
            filterTypes.isEmpty || filterTypes.contains($0.type)
        }.filter {
            searchText.isEmpty
            || $0.file.name.localizedStandardContains(searchText)
            || $0.properties.string.localizedStandardContains(searchText)
        }.filter {
            !filterVisible
            || $0.isVisible(in: mapModel.visibleMapRect ?? mapModel.mapView.visibleMapRect)
        }
        let isFiltering = filterTypes.isNotEmpty || filterVisible
        let isFinding = isFiltering || searchText.isNotEmpty
        let groupedAnnotations = Dictionary(grouping: filteredAnnotations, by: \.file)
        
        NavigationStack {
            List {
                ForEach(groupedAnnotations.keys.sorted(using: SortDescriptor(\File.name))) { file in
                    let annotations = Array(groupedAnnotations[file]!)
                    if groupedAnnotations.keys.count == 1 {
                        ForEach(annotations) { annotation in
                            Button {
                                mapModel.selectedAnnotation = annotation
                                mapModel.zoomToAnnotation(annotation)
                            } label: {
                                Label(annotation.title ?? annotation.file.name, systemImage: annotation.type.systemImage)
                            }
                        }
                    } else {
                        DisclosureGroup {
                            ForEach(annotations) { annotation in
                                Button {
                                    mapModel.selectedAnnotation = annotation
                                    mapModel.zoomToAnnotation(annotation)
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
            .searchable(text: $searchText.animation(), isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Features"))
            .scrollDismissesKeyboard(.immediately)
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .navigationTitle($title)
            .navigationSubtitle(filteredAnnotations.count.formatted(singular: isFinding ? "Result" : "Feature"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        recordModel.showRecordView = true
                        detent = .mediumDetent
                    } label: {
                        Label("Record Route", systemImage: "record.circle")
                    }
                    .tint(recordModel.isRecording ? .red : .none)
                }
                ToolbarItem(placement: .primaryAction) {
                    Toggle(isOn: .init {
                        isFiltering
                    } set: { _ in }) {
                        Menu {
                            Toggle("Sort by Name", isOn: $sort.animation())
                            Divider()
                            Menu {
                                Toggle("All Features", systemImage: "list.bullet", isOn: .init {
                                    !isFiltering
                                } set: { _ in
                                    filterVisible = false
                                    filterTypes = []
                                })
                                Divider()
                                Toggle("Visible", systemImage: "eye", isOn: $filterVisible)
                                ForEach(AnnotationType.allCases, id: \.self) { type in
                                    Toggle(type.plural, systemImage: type.systemImage, isOn: .init {
                                        filterTypes.contains(type)
                                    } set: { _ in
                                        filterTypes.toggle(type)
                                    })
                                }
                            } label: {
                                Text("Filter")
                                Text((filterTypes.map(\.plural) + (filterVisible ? ["Visible"] : [])).joined(separator: ", "))
                            }
                            .menuActionDismissBehavior(.disabled)
                            if isFiltering {
                                Button {
                                    filterVisible = false
                                    filterTypes = []
                                } label: {
                                    Label("Remove Filter", systemImage: "minus.circle")
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(isFiltering ? .white : .primary)
                        }
                        .menuOrder(.fixed)
                        .menuStyle(.button)
                        .buttonBorderShape(.circle)
                        .toggleStyle(.button)
                    }
                }
            }
            .navigationDestination(item: $mapModel.selectedAnnotation) { annotation in
                AnnotationView(mapModel: mapModel, annotation: annotation)
            }
            .navigationDestination(isPresented: $recordModel.showRecordView) {
                RecordView(mapModel: mapModel, recordModel: $recordModel, detent: detent)
            }
        }
        .interactiveDismissDisabled()
        .presentationBackground(.bar)
        .presentationBackgroundInteraction(.enabled)
        .presentationDetents([.smallDetent, .mediumDetent, .largeDetent], selection: $detent)
        .inspectorColumnWidth(ideal: 350)
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
                mapModel.zoomToAnnotation(annotation)
            }
        }
    }
}

extension PresentationDetent {
    static let smallDetent: Self    = .height(101)
    static let mediumDetent: Self   = .height(350)
    static let largeDetent: Self    = .large
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
