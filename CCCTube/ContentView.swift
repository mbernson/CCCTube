//
//  ContentView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI
import CCCApi

struct ContentView: View {
  let api = ApiService()
  @State private var talk: TalkToPlay?

  var body: some View {
    TabView {
      BrowseView(query: .recent)
        .tabItem { Text("Recent") }

      BrowseView(query: .popular)
        .tabItem { Text("Popular") }

      ConferencesView()
        .tabItem { Text("Conferences") }

      SearchView()
        .tabItem { Label("Search", systemImage: "magnifyingglass").labelStyle(.iconOnly) }
    }
    .environmentObject(api)
    .sheet(item: $talk) { talk in
      NavigationView {
        TalkView(talk: talk.talk, selectedRecording: talk.recordingToPlay)
          .environmentObject(api)
      }
    }
    .onOpenURL { url in
      let factory = URLParser()
      guard let route = factory.parseURL(url) else { return }
      Task {
        switch route {
        case .openTalk(let id):
          let talk = try await api.talk(id: id)
          self.talk = TalkToPlay(talk: talk, recordingToPlay: nil)
        case .playTalk(let id):
          let talk = try await api.talk(id: id)
          let recordings = try await api.recordings(for: talk)
          let recording = recordings.first(where: { $0.isHighQuality }) ?? recordings.first(where: { $0.isVideo })
          self.talk = TalkToPlay(talk: talk, recordingToPlay: recording)
        }
      }
    }
  }
}

private struct TalkToPlay: Identifiable {
  let id: Int = 1
  let talk: Talk
  let recordingToPlay: Recording?
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
