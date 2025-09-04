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
    
    var body: some View {
        Map(selectedAnnotation: $selectedAnnotation, zoomToAnnotation: $zoomToAnnotation, refreshAnnotations: $refreshAnnotations, setUserTrackingMode: $setUserTrackingMode, recordModel: recordModel, data: data, mapStandard: mapStandard, preview: false)
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                HStack {
                    Button {
                        if let recordModel {
                            if recordModel.state == .notStarted {
                                self.recordModel = nil
                            } else {
                                recordModel.confirmDiscard = true
                            }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: recordModel == nil ? "chevron.backward" : "stop.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .fontWeight(.semibold)
                            .mapBox()
                    }
                    .mapButton()
                    Spacer()
                    Button {
                        mapStandard.toggle()
                    } label: {
                        Image(systemName: mapStandard ? "map" : "globe.europe.africa.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .mapBox()
                    }
                    .mapButton()
                }
                .padding(10)
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showAnnotationsView) {
                AnnotationsView(title: $title, zoomToAnnotation: $zoomToAnnotation, selectedAnnotation: $selectedAnnotation, recordModel: $recordModel, data: data, folder: folder)
                    .sheet(item: $selectedAnnotation) { annotation in
                        PropertiesView(refreshAnnotations: $refreshAnnotations, zoomToAnnotation: $zoomToAnnotation, annotation: annotation, folder: folder, dismissMap: dismiss)
                    }
                    .sheet(item: $recordModel) { recordModel in
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
