//
//  RecordView.swift
//  Geodata
//
//  Created by Jack Finnis on 04/09/2025.
//

import SwiftUI
import MapKit

struct RecordView: View {
    @Bindable var model: RecordModel
    @Binding var setUserTrackingMode: MKUserTrackingMode?
    let onSave: () -> Void
    let onDiscard: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State var confirmDiscard = false
    @SceneStorage("requestedAuthorization") var requestedAuthorization = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            HStack {
                VStack {
                    TimelineView(PeriodicTimelineSchedule(from: .now, by: 1)) { context in
                        Text(model.duration.formatted(Duration.TimeFormatStyle(pattern: model.duration > .seconds(3600) ? .hourMinuteSecond : .minuteSecond(padMinuteToLength: 2))))
                            .font(.largeTitle.bold())
                    }
                    Text("Duration")
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text(String(format: "%.2f", model.metres/1000))
                        .font(.largeTitle.bold())
                    Text("Distance (km)")
                }
                .frame(maxWidth: .infinity)
            }
            .font(.headline)
            Spacer()
            HStack(spacing: 10) {
                switch model.state {
                case .notStarted:
                    if model.authorizationStatus == .authorizedAlways {
                        Button {
                            model.start()
                        } label: {
                            Label("Start", systemImage: "play.fill")
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    } else if !requestedAuthorization && [CLAuthorizationStatus.authorizedWhenInUse, .notDetermined].contains(model.authorizationStatus) {
                        Button {
                            requestedAuthorization = true
                            model.requestAuthorization()
                        } label: {
                            Text("Allow Location Access")
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    } else if let url = URL(string: UIApplication.openSettingsURLString) {
                        Link(destination: url) {
                            Text("Allow Location Access")
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    }
                case .recording:
                    Button {
                        model.pause()
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                case .paused:
                    Button {
                        model.resume()
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    Button {
                        model.stop()
                    } label: {
                        Label("Finish", systemImage: "flag.fill")
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                case .stopped:
                    Button {
                        confirmDiscard = true
                    } label: {
                        Text("Discard")
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .tint(.red)
                    .confirmationDialog("Discard Route?", isPresented: $confirmDiscard) {
                        Button("Cancel", role: .cancel) {}
                        Button("Discard Route", role: .destructive) {
                            onDiscard()
                        }
                    }
                    Button {
                        onSave()
                    } label: {
                        Text("Save")
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .font(.title3.bold())
        }
        .padding(.horizontal, 20)
        .buttonStyle(.glassProminent)
        .presentationBackgroundInteraction(.enabled)
        .presentationDetents([.height(200)])
        .sensoryFeedback(.impact, trigger: model.state)
        .sensoryFeedback(.impact, trigger: model.authorizationStatus)
        .onChange(of: model.state) { _, newState in
            switch newState {
            case .recording:
                setUserTrackingMode = .followWithHeading
            case .notStarted, .paused, .stopped:
                break
            }
        }
        .onDisappear {
            model.stopUpdatingLocation()
        }
    }
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example, folder: nil)
    }
    .environment(Model())
}
