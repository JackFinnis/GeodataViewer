//
//  RecordView.swift
//  Geodata
//
//  Created by Jack Finnis on 04/09/2025.
//

import SwiftUI
import MapKit

struct RecordView: View {
    @Binding var recordModel: RecordModel
    @Binding var setUserTrackingMode: MKUserTrackingMode?
    
    @Environment(Model.self) var model
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var confirmDiscard = false
    @SceneStorage("requestedAuthorization") var requestedAuthorization = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            HStack {
                VStack {
                    TimelineView(PeriodicTimelineSchedule(from: .now, by: 1)) { context in
                        Text(recordModel.duration.formatted(Duration.TimeFormatStyle(pattern: recordModel.duration > .seconds(3600) ? .hourMinuteSecond : .minuteSecond(padMinuteToLength: 2))))
                            .font(.largeTitle.bold())
                    }
                    Text("Duration")
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text(String(format: "%.2f", recordModel.metres/1000))
                        .font(.largeTitle.bold())
                    Text("Distance (km)")
                }
                .frame(maxWidth: .infinity)
            }
            .font(.headline)
            Spacer()
            HStack(spacing: 10) {
                switch recordModel.state {
                case .notStarted:
                    if recordModel.authorizationStatus == .authorizedAlways {
                        Button {
                            recordModel.start()
                        } label: {
                            Label("Start", systemImage: "play.fill")
                                .padding(5)
                                .frame(maxWidth: .infinity)
                        }
                    } else if !requestedAuthorization && [CLAuthorizationStatus.authorizedWhenInUse, .notDetermined].contains(recordModel.authorizationStatus) {
                        Button {
                            requestedAuthorization = true
                            recordModel.requestAuthorization()
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
                        recordModel.pause()
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                case .paused:
                    Button {
                        recordModel.resume()
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .padding(5)
                            .frame(maxWidth: .infinity)
                    }
                    Button {
                        recordModel.stop()
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
                            recordModel = .init()
                        }
                    }
                    Button {
                        model.handleCreateFile(locations: recordModel.previousLines, context: modelContext)
                        recordModel = .init(showRecordView: true)
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
        .sensoryFeedback(.impact, trigger: recordModel.state)
        .sensoryFeedback(.impact, trigger: recordModel.authorizationStatus)
        .onChange(of: recordModel.state) { _, newState in
            switch newState {
            case .recording:
                setUserTrackingMode = .followWithHeading
            case .notStarted, .paused, .stopped:
                break
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
