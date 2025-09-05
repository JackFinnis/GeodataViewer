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
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            HStack {
                VStack {
                    TimelineView(PeriodicTimelineSchedule(from: .now, by: 1)) { context in
                        Text(model.duration.formatted(Duration.TimeFormatStyle(pattern: .minuteSecond(padMinuteToLength: 2))))
                            .font(.title.bold())
                    }
                    Text("Duration")
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text(String(format: "%.2f", model.metres/1000))
                        .font(.title.bold())
                    Text("Distance (km)")
                }
                .frame(maxWidth: .infinity)
            }
            .font(.headline)
            Spacer()
            switch model.state {
            case .notStarted:
                if model.authorizationStatus == .authorizedAlways {
                    Button {
                        model.start()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                } else if !model.requested && [CLAuthorizationStatus.authorizedWhenInUse, .notDetermined].contains(model.authorizationStatus) {
                    Button {
                        model.requestAuthorization()
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
                        model.pause()
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
                        model.resume()
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    Button {
                        model.stop()
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
                        model.confirmDiscard = true
                    } label: {
                        Text("Discard")
                            .font(.headline)
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    Button {
                        onSave()
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
        .interactiveDismissDisabled(model.state != .notStarted)
        .confirmationDialog("Discard Route?", isPresented: $model.confirmDiscard) {
            Button("Cancel", role: .cancel) {}
            Button("Discard Route", role: .destructive) {
                onDiscard()
            }
        }
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
