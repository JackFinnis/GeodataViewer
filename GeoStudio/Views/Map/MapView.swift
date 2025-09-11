//
//  DataView.swift
//  Geojson
//
//  Created by Jack Finnis on 24/05/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var title: String
    let data: MapData
    let folder: Folder?
    
    @Environment(Model.self) var model
    @Environment(\.modelContext) var modelContext
    @State var mapStandard = true
    @State var showAnnotationsView = true
    @State var zoomToAnnotation: Annotation?
    @State var selectedAnnotation: Annotation?
    @State var setUserTrackingMode: MKUserTrackingMode?
    @State var refreshAnnotations = true
    @State var recordModel: RecordModel?
    @AppStorage("alwaysOnDisplay") var alwaysOnDisplay = false
    
    var body: some View {
        Map(selectedAnnotation: $selectedAnnotation, zoomToAnnotation: $zoomToAnnotation, refreshAnnotations: $refreshAnnotations, setUserTrackingMode: $setUserTrackingMode, recordModel: recordModel, data: data, mapStandard: mapStandard, preview: false)
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                Button {
                    mapStandard.toggle()
                } label: {
                    Image(systemName: mapStandard ? "map" : "globe.europe.africa.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .mapBox()
                }
                .mapButton()
                .padding(10)
            }
            .overlay(alignment: .topLeading) {
                VStack(spacing: 10) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .contentTransition(.symbolEffect(.replace))
                            .fontWeight(.semibold)
                            .mapBox()
                    }
                    .mapButton()
                    .disabled(recordModel != nil)
                    
                    Button {
                        if let recordModel {
                            if recordModel.state == .notStarted {
                                self.recordModel = nil
                            } else {
                                recordModel.confirmDiscard = true
                            }
                        } else {
                            recordModel = .init()
                        }
                    } label: {
                        Image(systemName: recordModel == nil ? "record.circle" : "stop.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .mapBox()
                    }
                    .mapButton()
                    
                    Menu {
                        Toggle("Always On Display", isOn: $alwaysOnDisplay)
                    } label: {
                        Image(systemName: "eye")
                            .symbolVariant(alwaysOnDisplay ? .none : .slash)
                            .contentTransition(.symbolEffect(.replace))
                            .mapBox()
                    }
                    .mapButton()
                }
                .padding(10)
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showAnnotationsView) {
                AnnotationsView(title: $title, zoomToAnnotation: $zoomToAnnotation, selectedAnnotation: $selectedAnnotation, data: data, folder: folder)
                    .sheet(item: $selectedAnnotation) { annotation in
                        PropertiesView(refreshAnnotations: $refreshAnnotations, zoomToAnnotation: $zoomToAnnotation, annotation: annotation, folder: folder, dismissMap: dismiss)
                    }
                    .sheet(item: $recordModel, onDismiss: {
                        if data == .empty && showAnnotationsView {
                            dismiss()
                        }
                    }) { recordModel in
                        RecordView(model: recordModel, setUserTrackingMode: $setUserTrackingMode, onSave: {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                model.handleCreateFile(locations: recordModel.previousLines, folder: folder, context: modelContext)
                            }
                        }, onDiscard: {
                            self.recordModel = nil
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
    }
    
    func dismiss() {
        recordModel = nil
        selectedAnnotation = nil
        showAnnotationsView = false
        model.path.removeLast()
    }
}

extension View {
    func mapBox() -> some View {
        frame(width: 44, height: 44)
    }
    
    func mapButton() -> some View {
        self
            .foregroundStyle(Color.accentColor)
            .buttonStyle(.plain)
            .font(.system(size: 20))
            .background(.ultraThickMaterial)
            .clipShape(.rect(cornerRadius: 8))
    }
}
