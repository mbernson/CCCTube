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
  @State var talk: Talk?

  var body: some View {
    TabView {
      BrowseView(query: .recent)
        .tabItem { Text("Browse") }

      BrowseView(query: .popular)
        .tabItem { Text("Popular") }

      ConferencesView()
        .tabItem { Text("Conferences") }

      SearchView()
        .tabItem { Label("Search", systemImage: "magnifyingglass").labelStyle(.iconOnly) }
    }
    .environmentObject(api)
    .sheet(item: $talk, content: { talk in
      NavigationView {
        TalkView(talk: talk)
          .environmentObject(api)
      }
    })
    .onOpenURL { url in
      print(url.absoluteString)
      let factory = URLParser()
      guard let route = factory.parseURL(url) else { return }
      Task {
        switch route {
        case .openTalk(let id):
          let talk = try await api.talk(id: id)
          self.talk = talk
        case .playTalk(let id):
          let talk = try await api.talk(id: id)
          self.talk = talk
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
