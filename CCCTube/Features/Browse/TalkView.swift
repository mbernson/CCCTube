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

  @State var hdRecording: Recording?
  @State var sdRecording: Recording?
  @State var audioRecording: Recording?
  @State var selectedRecording: Recording?
  @State private var talkDescription: TalkDescription?
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
        if let thumbURL = talk.thumbURL {
          AsyncImage(url: thumbURL) { image in
            image.resizable().scaledToFit()
              .cornerRadius(8)
          } placeholder: {
            ProgressView()
          }
          .frame(maxWidth: 480)
        }

        if let description = talk.description {
          if let descriptionParts = talk.description?.components(separatedBy: "\n\n"),
             let shortDescription = descriptionParts.first, descriptionParts.count > 1 {
            Button {
              talkDescription = TalkDescription(text: description)
            } label: {
              Text("\(shortDescription)... **MORE**")
                .lineLimit(5)
                .padding(10)
            }
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.card)
            .font(.body)
            .sheet(item: $talkDescription) { talkDescription in
              Text(talkDescription.text)
                .font(.body)
            }
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
            Text("No copyright information encoded in video. Please refer to the conference organizer's schedule for more information:")
            Link("Organizer schedule", destination: link)
          } else {
            Text("No copyright information encoded in video. Please refer to the website of the organizer of \(talk.conferenceTitle)")
            Link("Organizer website", destination: talk.conferenceURL)
          }
        }
      }
      .animation(.default, value: copyright)
      .focusSection()
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      VStack(alignment: .leading, spacing: 20) {
        Group {
          if let hdRecording {
            Button {
              self.selectedRecording = hdRecording
            } label: {
              Label("Play HD", systemImage: "play")
                .frame(maxWidth: .infinity)
            }
          }

          if let sdRecording {
            Button {
              self.selectedRecording = sdRecording
            } label: {
              Label("Play SD", systemImage: "play")
                .frame(maxWidth: .infinity)
            }
          }

          if let audioRecording {
            Button {
              self.selectedRecording = audioRecording
            } label: {
              Label("Play audio", systemImage: "play")
                .frame(maxWidth: .infinity)
            }
          }
        }

        Label("\(Self.minutesFormatter.string(from: talk.duration) ?? "0") minutes", systemImage: "clock")

        Label("\(talk.releaseDate, style: .date)", systemImage: "calendar")

        Label(String(talk.viewCount), systemImage: "eye")

        if !talk.persons.isEmpty {
          Label(talk.persons.joined(separator: ", "), systemImage: "person")
        }
      }
      .focusSection()
      .frame(maxWidth: 480, maxHeight: .infinity)
    }
    .navigationTitle(Text(talk.title))
    .task {
      do {
        let recordings = try await api.recordings(for: talk)
        hdRecording = recordings.first(where: { $0.isHighQuality })
        sdRecording = recordings.first(where: { !$0.isHighQuality && $0.isVideo })
        audioRecording = recordings.first(where: { $0.isAudio })

        for recording in recordings {
          if copyright == .loading {
            let copyrightString = await mediaAnalyzer.copyrightMetadata(for: recording)
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

private struct TalkDescription: Identifiable {
  let id: Int = 1
  let text: String
}

struct TalkView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TalkView(talk: .example, hdRecording: .example)
        .environmentObject(ApiService())
    }
  }
}
