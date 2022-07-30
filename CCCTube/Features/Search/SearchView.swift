//
//  SearchView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI
import CCCApi

class SearchViewModel: ObservableObject {
  //
}

struct SearchSuggestion: Identifiable {
  let title: String
  var id: String { title }
}

struct SearchView: View {
  @State var query: String = ""

  @EnvironmentObject var api: ApiService

  @State var results: [Talk] = []
  @State var suggestions: [SearchSuggestion] = [
    "Hacking", "Freedom", "Linux", "ethics", "IoT", "security", "lightning talks",
  ].map(SearchSuggestion.init)

  @State var error: NetworkError? = nil
  @State var isErrorPresented = false

  var body: some View {
    NavigationView {
      List {
        ForEach(results) { talk in
          NavigationLink {
            TalkView(talk: talk)
          } label: {
            TalkListItem(talk: talk)
          }
        }
      }
      .searchable(text: $query, prompt: "Search talks...", suggestions: {
        ForEach(suggestions) { suggest in
          Text(suggest.title).searchCompletion(suggest.title)
        }
      })
      .onChange(of: query, perform: { query in
        print(query)
        Task {
          do {
            results = try await api.searchTalks(query: query)
          } catch {
            self.error = NetworkError(errorDescription: NSLocalizedString("Failed to load data from the media.cc.de API", comment: ""), error: error)
            isErrorPresented = true
            debugPrint(error)
          }
        }
      })
      .alert(isPresented: $isErrorPresented, error: error) {
        Button("OK") {}
      }
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView()
      .environmentObject(ApiService())
  }
}
