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
        .contentMargins(.bottom, 255)
        .contentMargins(5)
        .mapControls {}
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .fontWeight(.semibold)
                    .mapBox()
            }
            .mapButton()
            .padding(10)
            .disabled(recordModel.state != .notStarted)
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
        .sensoryFeedback(.impact, trigger: recordModel.state)
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
            VStack {
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
                .padding(.top, 25)
                Spacer()
                switch recordModel.state {
                case .notStarted:
                    switch recordModel.authorizationStatus {
                    case .authorizedAlways:
                        Button {
                            recordModel.start()
                        } label: {
                            Text("Start")
                                .font(.headline)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    default:
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            Link(destination: url) {
                                Text("Allow Location Access Always")
                                    .font(.headline)
                                    .padding(5)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                case .recording:
                    Button {
                        recordModel.pause()
                    } label: {
                        Text("Pause")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    Button {
                        recordModel.stop()
                    } label: {
                        Text("Stop")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                case .paused:
                    Button {
                        recordModel.resume()
                    } label: {
                        Text("Resume")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    Button {
                        recordModel.stop()
                    } label: {
                        Text("Stop")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                case .stopped:
                    Button {
                        dismiss()
                        model.handleCreateFile(locations: recordModel.previousLines, folder: folder, context: modelContext)
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    Button {
                        dismiss()
                    } label: {
                        Text("Discard")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 10))
            .presentationBackgroundInteraction(.enabled)
            .presentationDetents([.height(250)])
            .interactiveDismissDisabled()
            .onAppear {
                CLLocationManager().requestWhenInUseAuthorization()
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
