//
//  DataView.swift
//  Geojson
//
//  Created by Jack Finnis on 24/05/2024.
//

import SwiftUI
import MapKit

struct FileView: View {
    @Bindable var file: File
    let data: GeoData
    let namespace: Namespace.ID
    
    @State var mapStandard = true
    @State var selectedAnnotation: Annotation?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                MapView(selectedAnnotation: $selectedAnnotation, file: file, data: data, mapStandard: mapStandard, preview: false)
                    .ignoresSafeArea()
                
                Button {
                    mapStandard.toggle()
                } label: {
                    Image(systemName: mapStandard ? "map" : "globe.europe.africa.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .mapBox()
                }
                .mapButton()
                .position(x: geo.size.width - 32, y: -22)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    mapStandard.toggle()
                } label: {
                    Image(systemName: "map")
                        .foregroundStyle(.clear)
                }
            }
        }
        .navigationTitle($file.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: .init {
            selectedAnnotation is Point || selectedAnnotation?.properties.dict.isNotEmpty ?? false
        } set: { isPresented in
            if !isPresented {
                selectedAnnotation = nil
            }
        }) {
            if let selectedAnnotation {
                PropertiesView(file: file, annotation: selectedAnnotation)
            }
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
        .zoomChild(id: file.id, in: namespace)
    }
}
