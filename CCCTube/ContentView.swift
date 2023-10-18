//
//  ContentView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import CCCApi
import SwiftUI

struct ContentView: View {
    let api = ApiService()
    @State private var talk: TalkToPlay?

    var body: some View {
        TabView {
            BrowseView(query: .recent)
                .tabItem {
                    #if os(tvOS)
                        Text("Recent")
                    #else
                        Label("Recent", systemImage: "clock")
                    #endif
                }

            BrowseView(query: .popular)
                .tabItem {
                    #if os(tvOS)
                        Text("Popular")
                    #else
                        Label("Popular", systemImage: "popcorn")
                    #endif
                }

            ConferencesView()
                .tabItem {
                    #if os(tvOS)
                        Text("Conferences")
                    #else
                        Label("Conferences", systemImage: "star")
                    #endif
                }

            SearchView()
                .tabItem {
                    #if os(tvOS)
                        Label("Search", systemImage: "magnifyingglass").labelStyle(.iconOnly)
                    #else
                        Label("Search", systemImage: "magnifyingglass")
                    #endif
                }
        }
        .environmentObject(api)
        .fullScreenCover(item: $talk) { talk in
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
                case let .openTalk(id):
                    let talk = try await api.talk(id: id)
                    self.talk = TalkToPlay(talk: talk, recordingToPlay: nil)
                case let .playTalk(id):
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
