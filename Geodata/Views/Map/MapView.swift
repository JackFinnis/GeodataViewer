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
    let folder: Bool
    
    @Environment(Model.self) var model
    @State var mapStandard = true
    @State var showAnnotationsView = true
    @State var zoomToAnnotation: Annotation?
    @State var selectedAnnotation: Annotation?
    @State var refreshAnnotations = true
    
    var body: some View {
        Map(selectedAnnotation: $selectedAnnotation, zoomToAnnotation: $zoomToAnnotation, refreshAnnotations: $refreshAnnotations, data: data, mapStandard: mapStandard, preview: false)
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
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
                AnnotationsView(title: $title, zoomToAnnotation: $zoomToAnnotation, selectedAnnotation: $selectedAnnotation, data: data)
                    .sheet(item: $selectedAnnotation) { annotation in
                        PropertiesView(refreshAnnotations: $refreshAnnotations, annotation: annotation, folder: folder, dismissMap: dismiss)
                    }
            }
            .onAppear {
                CLLocationManager().requestWhenInUseAuthorization()
            }
    }
    
    func dismiss() {
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
