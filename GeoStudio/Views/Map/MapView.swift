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
    @Environment(\.dismiss) var dismiss
    @State var mapStandard = true
    @State var showAnnotationsView = true
    @State var zoomToAnnotation: Annotation?
    @State var selectedAnnotation: Annotation?
    @State var setUserTrackingMode: MKUserTrackingMode?
    @State var refreshAnnotations = true
    @State var recordModel = RecordModel()
    @AppStorage("alwaysOnDisplay") var alwaysOnDisplay = false
    
    var body: some View {
        MapViewRepresentable(selectedAnnotation: $selectedAnnotation, zoomToAnnotation: $zoomToAnnotation, refreshAnnotations: $refreshAnnotations, setUserTrackingMode: $setUserTrackingMode, recordModel: recordModel, data: data, mapStandard: mapStandard, preview: false)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "chevron.backward")
                    }
                    .disabled(recordModel.isRecording)
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Toggle("Always On Display", isOn: $alwaysOnDisplay)
                        Picker("Map Type", selection: $mapStandard) {
                            Label("Standard", systemImage: "map")
                                .tag(true)
                            Label("Satellite", systemImage: "globe.europe.africa.fill")
                                .tag(false)
                        }
                    } label: {
                        Label("Map Settings", systemImage: "map")
                    }
                }
            }
            .sheet(isPresented: $showAnnotationsView) {
                AnnotationsView(title: $title, zoomToAnnotation: $zoomToAnnotation, selectedAnnotation: $selectedAnnotation, setUserTrackingMode: $setUserTrackingMode, refreshAnnotations: $refreshAnnotations, recordModel: $recordModel, data: data)
            }
            .onAppear {
                showAnnotationsView = true
                CLLocationManager().requestWhenInUseAuthorization()
                UIApplication.shared.isIdleTimerDisabled = alwaysOnDisplay
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onChange(of: recordModel.showRecordView) { _, showRecordView in
                if !showRecordView && !recordModel.isRecording && data == .empty {
                    dismiss()
                }
            }
            .onChange(of: model.path) { _, path in
                if data != path.last?.mapData {
                    showAnnotationsView = false
                    selectedAnnotation = nil
                }
            }
            .onChange(of: alwaysOnDisplay) { _, alwaysOnDisplay in
                UIApplication.shared.isIdleTimerDisabled = alwaysOnDisplay
            }
            .monospacedDigit()
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
