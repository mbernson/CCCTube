//
//  ContentView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI

struct ContentView: View {
  let api = ApiService()

  var body: some View {
    TabView {
      BrowseView()
        .tabItem {
          Text("Browse")
        }

      SearchView()
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
            .labelStyle(.iconOnly)
        }

    }
    .environmentObject(api)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
