//
//  AnnotationView.swift
//  Geojson
//
//  Created by Jack Finnis on 13/02/2025.
//

import SwiftUI

struct PropertiesView: View {
    @Binding var refreshAnnotations: Bool
    let annotation: Annotation
    let folder: Bool
    
    @Environment(Model.self) var model
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        let file = annotation.file
        
        NavigationStack {
            List {
                Button {
                    if folder {
                        dismiss()
                        model.load(file: file)
                    }
                } label: {
                    PropertyRow(key: "File", value: annotation.file.name)
                }
                if annotation is Point {
                    PropertyRow(key: "Latitude", value: String(format: "%.5f", annotation.coordinate.latitude))
                    PropertyRow(key: "Longitude", value: String(format: "%.5f", annotation.coordinate.longitude))
                }
                ForEach(annotation.properties.dict.sorted(using: SortDescriptor(\.key)), id: \.key) { key, value in
                    let string = "\(value)"
                    let title = key == file.titleKey
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
                                file.titleKey = nil
                                refreshAnnotations = true
                            } label: {
                                Label("Remove Label", systemImage: "star.slash")
                            }
                        } else {
                            Button {
                                file.titleKey = key
                                refreshAnnotations = true
                            } label: {
                                Label("Add Map Label", systemImage: "star")
                            }
                        }
                    } label: {
                        PropertyRow(key: key, value: string)
                    }
                    .tint(title ? Color.accentColor : .primary)
                }
            }
            .listStyle(.plain)
            .navigationTitle(annotation.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if let point = annotation as? Point {
                        Button {
                            Task {
                                try? await point.openInMaps()
                            }
                        } label: {
                            Image(systemName: "map")
                        }
                        .font(.headline)
                        .buttonBorderShape(.circle)
                        .buttonStyle(.bordered)
                        .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .font(.headline)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .presentationBackgroundInteraction(.enabled)
        .presentationDetents([.partial, .large])
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
