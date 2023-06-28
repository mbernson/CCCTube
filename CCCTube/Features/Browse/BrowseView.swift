//
//  BrowseView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI
import CCCApi

enum EventsQuery {
  case recent
  case popular
}

struct BrowseView: View {
  let query: EventsQuery
  @State var talks: [Talk] = []

  @State var error: NetworkError? = nil
  @State var isErrorPresented = false

  @EnvironmentObject var api: ApiService

  var body: some View {
    NavigationView {
      ScrollView {
        TalksGrid(talks: talks)
      }
      .task {
        do {
          switch query {
          case .recent:
            talks = try await api.recentTalks()
          case .popular:
            talks = try await api.popularTalks()
          }
        } catch {
          self.error = NetworkError(errorDescription: NSLocalizedString("Failed to load data from the media.cc.de API", comment: ""), error: error)
          isErrorPresented = true
          debugPrint(error)
        }
      }
      .alert(isPresented: $isErrorPresented, error: error) {
        Button("OK") {}
      }
    }
  }
}

struct BrowseView_Previews: PreviewProvider {
  static var previews: some View {
    BrowseView(query: .popular, talks: [.example])
      .environmentObject(ApiService())
  }
}
