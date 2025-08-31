//
//  DataView.swift
//  Geojson
//
//  Created by Jack Finnis on 24/05/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    let data: FileData
    let folder: Bool
    
    @State var mapStandard = true
    @State var refreshAnnotations = true
    @State var selectedAnnotation: Annotation?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Map(selectedAnnotation: $selectedAnnotation, data: data, mapStandard: mapStandard, refreshAnnotations: refreshAnnotations, preview: false)
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
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: .init {
            selectedAnnotation != nil
        } set: { isPresented in
            if !isPresented {
                selectedAnnotation = nil
            }
        }) {
            if let selectedAnnotation {
                PropertiesView(refreshAnnotations: $refreshAnnotations, annotation: selectedAnnotation, folder: folder)
            }
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
}
