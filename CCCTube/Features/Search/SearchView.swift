//
//  SearchView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI
import CCCApi

struct SearchView: View {
  @StateObject var viewModel = SearchViewModel()
  @State var suggestions: [SearchSuggestion] = SearchSuggestion.defaultSuggestions

  var body: some View {
    NavigationView {
      List {
        ForEach(viewModel.results) { talk in
          NavigationLink {
            TalkView(talk: talk)
          } label: {
            TalkListItem(talk: talk)
          }
        }
      }
      .searchable(text: $viewModel.query, prompt: "Search talks...", suggestions: {
        ForEach(suggestions) { suggest in
          Text(suggest.title).searchCompletion(suggest.title)
        }
      })
      .alert(isPresented: $viewModel.isErrorPresented, error: viewModel.error) {
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
