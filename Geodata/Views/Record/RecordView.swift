//
//  RecordView.swift
//  Geodata
//
//  Created by Jack Finnis on 31/08/2025.
//

import SwiftUI
import MapKit

struct RecordView: View {
    let folder: Folder?
    
    @Environment(\.modelContext) var modelContext
    @Environment(Model.self) var model
    @State var showSheet = true
    @State var recordModel = RecordModel()
    @State var selectedFeature: MapFeature?
    @State var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var mapStandard = true
    @State var confirmDiscard = false
    @Namespace var mapScope
    
    var body: some View {
        SelectableMap(position: $mapPosition, interactionModes: .all, selection: $selectedFeature, scope: mapScope) {
            UserAnnotation()
            ForEach(recordModel.polylines, id: \.self) { poyline in
                MapKit.MapPolyline(poyline)
                    .stroke(.accent, style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
        }
        .mapStyle(mapStandard ? .standard(elevation: .realistic) : .hybrid(elevation: .realistic))
        .contentMargins(.bottom, 200 + 5)
        .contentMargins(5)
        .mapControls {}
        .overlay(alignment: .topLeading) {
            VStack(spacing: 10) {
                Button {
                    switch recordModel.state {
                    case .notStarted:
                        dismiss()
                    case .recording, .paused, .stopped:
                        confirmDiscard = true
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.semibold)
                        .mapBox()
                }
                .mapButton()
                MapScaleView(anchorEdge: .leading, scope: mapScope)
            }
            .padding(10)
        }
        .overlay(alignment: .topTrailing) {
            VStack(spacing: 10) {
                Button {
                    mapStandard.toggle()
                } label: {
                    Image(systemName: mapStandard ? "map" : "globe.europe.africa.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .mapBox()
                }
                .mapButton()
                MapUserLocationButton(scope: mapScope)
                MapPitchToggle(scope: mapScope)
                    .mapControlVisibility(.visible)
                MapCompass(scope: mapScope)
            }
            .buttonBorderShape(.roundedRectangle)
            .padding(10)
        }
        .mapScope(mapScope)
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
        .sensoryFeedback(.impact, trigger: recordModel.state)
        .sensoryFeedback(.impact, trigger: recordModel.authorizationStatus)
        .onChange(of: recordModel.state) { _, newState in
            switch newState {
            case .recording:
                withAnimation {
                    mapPosition = .userLocation(followsHeading: true, fallback: .automatic)
                }
            case .notStarted, .paused, .stopped:
                break
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showSheet) {
            VStack(spacing: 16) {
                Spacer()
                HStack {
                    VStack {
                        TimelineView(PeriodicTimelineSchedule(from: .now, by: 1)) { context in
                            Text(recordModel.duration.formatted(Duration.TimeFormatStyle(pattern: .minuteSecond(padMinuteToLength: 2))))
                                .font(.title.bold())
                        }
                        Text("Duration")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Text(String(format: "%.2f", recordModel.metres/1000))
                            .font(.title.bold())
                        Text("Distance (km)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.headline)
                Spacer()
                switch recordModel.state {
                case .notStarted:
                    if recordModel.authorizationStatus == .authorizedAlways {
                        Button {
                            recordModel.start()
                        } label: {
                            Label("Start", systemImage: "play.fill")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    } else if !recordModel.requested && [CLAuthorizationStatus.authorizedWhenInUse, .notDetermined].contains(recordModel.authorizationStatus) {
                        Button {
                            recordModel.requestAuthorization()
                        } label: {
                            Text("Allow Location Access")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    } else if let url = URL(string: UIApplication.openSettingsURLString) {
                        Link(destination: url) {
                            Text("Allow Location Access")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    }
                case .recording:
                    HStack {
                        Button {
                            recordModel.pause()
                        } label: {
                            Label("Pause", systemImage: "pause.fill")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    }
                case .paused:
                    HStack {
                        Button {
                            recordModel.resume()
                        } label: {
                            Label("Resume", systemImage: "play.fill")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                        Button {
                            recordModel.stop()
                        } label: {
                            Label("Finish", systemImage: "flag.fill")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    }
                case .stopped:
                    HStack {
                        Button {
                            confirmDiscard = true
                        } label: {
                            Text("Discard")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        Button {
                            dismiss()
                            model.handleCreateFile(locations: recordModel.previousLines, folder: folder, context: modelContext)
                        } label: {
                            Text("Save")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 10))
            .presentationBackgroundInteraction(.enabled)
            .presentationDetents([.height(200)])
            .interactiveDismissDisabled()
            .confirmationDialog("Discard Route?", isPresented: $confirmDiscard) {
                Button("Cancel", role: .cancel) {}
                Button("Discard Route", role: .destructive) {
                    recordModel.stop()
                    dismiss()
                }
            }
        }
    }
    
    func dismiss() {
        model.path.removeLast()
        showSheet = false
    }
}

struct SelectableMap<Selection: Hashable, Content: MapContent>: View {
    @Binding var position: MapCameraPosition
    let interactionModes: MapInteractionModes
    @Binding var selection: Selection?
    let scope: Namespace.ID
    @MapContentBuilder let content: () -> Content
    
    var body: some View {
        if #available(iOS 18, *) {
            MapKit.Map(position: $position, interactionModes: interactionModes, selection: .init(get: {
                if let selection {
                    return MapSelection(selection)
                } else {
                    return nil
                }
            }, set: { mapSelection in
                if let value = mapSelection?.value {
                    selection = value
                } else {
                    selection = nil
                }
            }), scope: scope, content: content)
            .mapFeatureSelectionAccessory(.caption)
            .mapFeatureSelectionDisabled { mapFeature in
                mapFeature.kind != .pointOfInterest
            }
        } else {
            MapKit.Map(position: $position, interactionModes: interactionModes, selection: $selection, scope: scope, content: content)
        }
    }
}
