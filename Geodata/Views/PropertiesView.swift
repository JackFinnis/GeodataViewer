//
//  AnnotationView.swift
//  Geojson
//
//  Created by Jack Finnis on 13/02/2025.
//

import SwiftUI

struct PropertiesView: View {
    var file: File
    let annotation: Annotation
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            List(annotation.properties.dict.sorted(using: SortDescriptor(\.key)), id: \.key) { key, value in
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
                        } label: {
                            Label("Undo Title", systemImage: "star.slash")
                        }
                    } else {
                        Button {
                            file.titleKey = key
                        } label: {
                            Label("Set Title", systemImage: "star")
                        }
                    }
                } label: {
                    HStack {
                        Text(key)
                            .layoutPriority(1)
                        Spacer()
                        Text(string)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .tint(title ? Color.accentColor : .primary)
            }
            .listStyle(.plain)
            .navigationTitle(annotation.properties.getTitle(key: file.titleKey) ?? "")
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
        .presentationDetents([.medium, .large])
    }
}
