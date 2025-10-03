//
//  AnnotationView.swift
//  Geojson
//
//  Created by Jack Finnis on 13/02/2025.
//

import SwiftUI

struct AnnotationView: View {
    @Binding var refreshAnnotations: Bool
    @Binding var zoomToAnnotation: Annotation?
    let annotation: Annotation
    
    @Environment(Model.self) var model
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    if model.path.last?.file != annotation.file {
                        model.load(file: annotation.file)
                    }
                } label: {
                    PropertyRow(key: "File", value: annotation.file.lastPathComponent)
                }
                .listRowBackground(Color.clear)
                PropertyRow(key: "Type", value: annotation.type.name)
                if let point = annotation as? Point {
                    PropertyRow(key: "Latitude", value: String(format: "%.5f", point.coordinate.latitude))
                    PropertyRow(key: "Longitude", value: String(format: "%.5f", point.coordinate.longitude))
                }
                if let polyline = annotation as? Polyline {
                    PropertyRow(key: "Length", value: Measurement(value: polyline.mkPolyline.coordinates.map(\.location).meters, unit: UnitLength.meters).formatted())
                }
                if let polygon = annotation as? Polygon {
                    PropertyRow(key: "Area", value: Measurement(value: polygon.mkPolygon.squareMeters, unit: UnitArea.squareMeters).formatted())
                    PropertyRow(key: "Perimeter", value: Measurement(value: polygon.mkPolygon.coordinates.map(\.location).meters, unit: UnitLength.meters).formatted())
                }
                ForEach(annotation.properties.dict.sorted(using: SortDescriptor(\.key)), id: \.key) { key, value in
                    let string = "\(value)"
                    let title = key == annotation.file.titleKey
                    Menu {
                        if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
                            Button {
                                openURL(url)
                            } label: {
                                Label("Open", systemImage: "safari")
                            }
                        }
                        Button {
                            UIPasteboard.general.string = string
                            Haptics.tap()
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        if title {
                            Button(role: .destructive) {
                                annotation.file.titleKey = nil
                                refreshAnnotations = true
                            } label: {
                                Label("Remove Label", systemImage: "star.slash")
                            }
                        } else {
                            Button {
                                annotation.file.titleKey = key
                                refreshAnnotations = true
                            } label: {
                                Label("Set Title", systemImage: "star")
                            }
                        }
                    } label: {
                        PropertyRow(key: key, value: string)
                    }
                    .tint(title ? .accent : .primary)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle(annotation.title ?? annotation.type.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let point = annotation as? Point {
                        Button {
                            Task {
                                try? await point.openInMaps()
                            }
                        } label: {
                            Label("Open in Maps", systemImage: "map")
                        }
                    } else {
                        Button {
                            zoomToAnnotation = annotation
                        } label: {
                            Label("Recenter", systemImage: "scope")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
            }
        }
        .presentationBackgroundInteraction(.enabled)
        .presentationDetents([.mediumDetent, .largeDetent])
    }
}

struct PropertyRow: View {
    let key: String
    let value: String
    
    var body: some View {
        HStack {
            Text(key)
                .layoutPriority(1)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
