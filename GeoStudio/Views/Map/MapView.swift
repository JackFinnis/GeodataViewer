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
    @State var recordModel = RecordModel()
    @State var mapModel = MapModel()
    @AppStorage("alwaysOnDisplay") var alwaysOnDisplay = false
    
    var body: some View {
        MapLayout {
            NavigationStack {
                MapViewRepresentable(mapModel: mapModel, recordModel: recordModel, data: data, preview: false)
                    .ignoresSafeArea()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                if recordModel.isRecording {
                                    recordModel.showRecordView = true
                                } else {
                                    dismiss()
                                }
                            } label: {
                                Label("Dismiss", systemImage: "chevron.backward")
                            }
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Menu {
                                Toggle("Always On Display", isOn: $alwaysOnDisplay)
                                Picker("Map Type", selection: $mapModel.mapStandard) {
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
            }
        } sheet: {
            AnnotationsView(title: $title, mapModel: mapModel, recordModel: $recordModel, data: data)
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
            UIApplication.shared.isIdleTimerDisabled = alwaysOnDisplay
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: alwaysOnDisplay) { _, alwaysOnDisplay in
            UIApplication.shared.isIdleTimerDisabled = alwaysOnDisplay
        }
        .onChange(of: recordModel.showRecordView) { _, showRecordView in
            if !showRecordView && !recordModel.isRecording && data == .empty {
                dismiss()
            }
        }
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

struct MapLayout<MapContent: View, SheetContent: View>: View {
    let map: () -> MapContent
    let sheet: () -> SheetContent
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            map().sheet(isPresented: .constant(true), content: sheet)
        } else {
            NavigationSplitView(columnVisibility: .constant(.all)) {
                sheet()
            } detail: {
                map()
            }
        }
    }
}
