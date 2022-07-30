//
//  TalkView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI

struct TalkView: View {
  let talk: Talk
  @State var recordings: [Recording] = []
  @State var selectedRecording: Recording?
  @EnvironmentObject var api: ApiService

  var body: some View {
    HStack(alignment: .top, spacing: 20) {
      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 10) {
          if let description = talk.description {
            Text(description)
              .font(.body)
          }
        }
      }
      .focusSection()
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      List {
        Section("Recordings") {
          ForEach(recordings) { recording in
            Button(recording.filename) {
              self.selectedRecording = recording
            }
          }
        }
      }
      .focusSection()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .navigationTitle(Text(talk.title))
    .task {
      do {
        recordings = try await api.recordings(for: talk)
//          .filter { $0.mime_type == "video/mp4" }
      } catch {
        print(error)
      }
    }
    .sheet(item: $selectedRecording) { recording in
      TalkPlayerView(talk: talk, recording: recording)
    }
  }
}

struct EventView_Previews: PreviewProvider {
  static var previews: some View {
    TalkView(talk: .example)
      .environmentObject(ApiService())
  }
}
