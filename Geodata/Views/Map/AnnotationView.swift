//
//  AnnotationView.swift
//  Geojson
//
//  Created by Jack Finnis on 13/02/2025.
//

import SwiftUI

struct AnnotationView: View {
    @Bindable var mapModel: MapModel
    let annotation: Annotation
    
    @Environment(Model.self) var model
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            Button {
                if case .folder = model.map {
                    model.load(file: annotation.file)
                }
            } label: {
                PropertyRow(key: "File", value: annotation.file.lastPathComponent)
            }
            if let point = annotation as? Point {
                PropertyRow(key: "Latitude", value: String(format: "%.5f", point.coordinate.latitude))
                PropertyRow(key: "Longitude", value: String(format: "%.5f", point.coordinate.longitude))
                PropertyRow(key: "Distance", value: Measurement(value: point.coordinate.distance(to: mapModel.mapView.userLocation.coordinate), unit: UnitLength.meters).formatted())
            }
            if let polyline = annotation as? Polyline {
                PropertyRow(key: "Length", value: Measurement(value: polyline.mkPolyline.coordinates.map(\.location).meters, unit: UnitLength.meters).formatted())
            }
            if let polygon = annotation as? Polygon {
                PropertyRow(key: "Area", value: Measurement(value: polygon.mkPolygon.squareMeters, unit: UnitArea.squareMeters).formatted())
                PropertyRow(key: "Perimeter", value: Measurement(value: polygon.mkPolygon.coordinates.map(\.location).meters, unit: UnitLength.meters).formatted())
            }
            ForEach(annotation.properties.sorted(using: SortDescriptor(\.key)), id: \.key) { key, value in
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
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    if title {
                        Button(role: .destructive) {
                            annotation.file.titleKey = nil
                            mapModel.refreshAnnotations()
                        } label: {
                            Label("Remove Label", systemImage: "star.slash")
                        }
                    } else {
                        Button {
                            annotation.file.titleKey = key
                            mapModel.refreshAnnotations()
                        } label: {
                            Label("Set Title", systemImage: "star")
                        }
                    }
                } label: {
                    PropertyRow(key: key, value: string)
                }
                .tint(title ? .accent : .primary)
            }
        }
        .listStyle(.plain)
        .navigationTitle(annotation.title ?? "Untitled")
        .navigationSubtitle(annotation.type.singular)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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
                        mapModel.zoomToAnnotation(annotation)
                    } label: {
                        Label("Zoom", systemImage: "scope")
                    }
                }
            }
        }
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
    }
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
