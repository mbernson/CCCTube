//
//  TalkView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI
import CCCApi

enum CopyrightState: Equatable {
  case loading
  case copyright(String)
  case unknown
}

struct TalkView: View {
  let talk: Talk
  let mediaAnalyzer = MediaAnalyzer()

  @State var recordings: [Recording] = []
  @State var selectedRecording: Recording?

  @State var copyright: CopyrightState = .loading

  @State var error: NetworkError? = nil
  @State var isErrorPresented = false

  @EnvironmentObject var api: ApiService

  static let minutesFormatter: DateComponentsFormatter = {
    let f = DateComponentsFormatter()
    f.allowedUnits = .minute
    return f
  }()

  var body: some View {
    HStack(alignment: .top, spacing: 20) {
      VStack(alignment: .leading, spacing: 10) {
        if let description = talk.description {
          if let descriptionParts = talk.description?.components(separatedBy: "\n\n"),
             let shortDescription = descriptionParts.first, descriptionParts.count > 1 {
            NavigationLink(shortDescription, destination: Text(description))
              .buttonStyle(.plain)
              .font(.body)
          } else {
            Text(description)
              .font(.body)
          }
        }

        Text("Copyright")
          .font(.headline)

        switch copyright {
        case .loading:
          ProgressView()
        case .copyright(let string):
          Text(string)
            .font(.caption)
        case .unknown:
          if let link = talk.link {
            Text("No copyright information encoded in video. Please refer to the conference organizer at: \(link.absoluteString)")
          } else {
            Text("No copyright information encoded in video. Please refer to the conference organizer of \(talk.conferenceTitle) at: \(talk.conferenceURL.absoluteString)")
          }
        }
      }
      .animation(.default, value: copyright)
      .focusSection()
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      VStack(alignment: .leading, spacing: 20) {
        HStack(alignment: .top, spacing: 20) {
          ForEach(recordings) { recording in
            if recording.isAudio {
              Button("Play audio") {
                self.selectedRecording = recording
              }
            } else if recording.isHighQuality {
              Button("Play HD") {
                self.selectedRecording = recording
              }
            } else {
              Button("Play SD") {
                self.selectedRecording = recording
              }
            }
          }
        }
        .padding(.bottom, 20)

        Label("\(Self.minutesFormatter.string(from: talk.duration) ?? "0") min", systemImage: "clock")

        Label("\(talk.releaseDate, style: .date)", systemImage: "calendar")

        Label(String(talk.viewCount), systemImage: "eye")

        if !talk.persons.isEmpty {
          Label(talk.persons.joined(separator: ", "), systemImage: "person")
        }
      }
      .focusSection()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .navigationTitle(Text(talk.title))
    .task {
      guard recordings.isEmpty else { return }
      do {
        recordings = try await api.recordings(for: talk)

        for recording in recordings {
          if copyright == .loading {
            let copyrightString = await mediaAnalyzer.copyrightMetadata(for: recording)?.stringValue
            if let copyrightString = copyrightString {
              copyright = .copyright(copyrightString)
            }
          }
        }
        if copyright == .loading {
          copyright = .unknown
        }
      } catch {
        self.error = NetworkError(errorDescription: NSLocalizedString("Failed to load data from the media.cc.de API", comment: ""), error: error)
        isErrorPresented = true
        debugPrint(error)
      }
    }
    .sheet(item: $selectedRecording) { recording in
      TalkPlayerView(talk: talk, recording: recording)
    }
    .alert(isPresented: $isErrorPresented, error: error) {
      Button("OK") {}
    }
  }
}

struct EventView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TalkView(talk: .example, recordings: .example)
        .environmentObject(ApiService())
    }
  }
}
