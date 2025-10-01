//
//  DataView.swift
//  Geojson
//
//  Created by Jack Finnis on 24/05/2024.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Binding var title: String
    let data: MapData
    
    @Environment(Model.self) var model
    @Environment(\.modelContext) var modelContext
    @State var mapStandard = true
    @State var showAnnotationsView = true
    @State var zoomToAnnotation: Annotation?
    @State var selectedAnnotation: Annotation?
    @State var setUserTrackingMode: MKUserTrackingMode?
    @State var refreshAnnotations = true
    @State var recordModel = RecordModel()
    @State var showRecordView = false
    @AppStorage("alwaysOnDisplay") var alwaysOnDisplay = false
    
    var body: some View {
        MapViewRepresentable(selectedAnnotation: $selectedAnnotation, zoomToAnnotation: $zoomToAnnotation, refreshAnnotations: $refreshAnnotations, setUserTrackingMode: $setUserTrackingMode, recordModel: recordModel, data: data, mapStandard: mapStandard, preview: false)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismissMap()
                    } label: {
                        Label("Dismiss", systemImage: "chevron.backward")
                    }
                    .disabled(recordModel.isRecording)
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showRecordView.toggle()
                    } label: {
                        Label("Record Route", systemImage: "record.circle")
                    }
                    .tint(recordModel.isRecording ? .red : .none)
                    Menu {
                        Toggle("Always On Display", isOn: $alwaysOnDisplay)
                    } label: {
                        Label("Always On Display", systemImage: "eye")
                            .symbolVariant(alwaysOnDisplay ? .none : .slash)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    Button {
                        mapStandard.toggle()
                    } label: {
                        Label("Map Type", systemImage: mapStandard ? "map" : "globe.europe.africa.fill")
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
            }
            .sheet(isPresented: $showAnnotationsView) {
                AnnotationsView(title: $title, zoomToAnnotation: $zoomToAnnotation, selectedAnnotation: $selectedAnnotation, data: data)
                    .sheet(item: $selectedAnnotation) { annotation in
                        PropertiesView(refreshAnnotations: $refreshAnnotations, zoomToAnnotation: $zoomToAnnotation, annotation: annotation, dismissMap: dismissMap)
                    }
                    .sheet(isPresented: $showRecordView) {
                        RecordView(model: recordModel, setUserTrackingMode: $setUserTrackingMode, onSave: {
                            dismissMap()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                model.handleCreateFile(locations: recordModel.previousLines, context: modelContext)
                            }
                        }, onDiscard: {
                            self.recordModel = .init()
                        })
                    }
            }
            .onAppear {
                CLLocationManager().requestWhenInUseAuthorization()
            }
            .onChange(of: alwaysOnDisplay) { _, alwaysOnDisplay in
                UIApplication.shared.isIdleTimerDisabled = alwaysOnDisplay
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = alwaysOnDisplay
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onChange(of: showRecordView) { _, showRecordView in
                if !showRecordView && !recordModel.isRecording && data == .empty {
                    dismissMap()
                }
            }
            .monospacedDigit()
    }
    
    func dismissMap() {
        showAnnotationsView = false
        model.path.removeLast()
    }
}

#Preview {
    let container = try! ModelContainer(for: File.self)
    return FoldersView().modelContainer(container)
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
