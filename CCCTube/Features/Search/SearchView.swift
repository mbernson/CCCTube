//
//  SearchView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    @State var suggestions: [SearchSuggestion] = SearchSuggestion.defaultSuggestions.shuffled()

    var body: some View {
        NavigationStack {
            Group {
                #if os(tvOS)
                    List {
                        ForEach(viewModel.results) { talk in
                            NavigationLink {
                                TalkView(talk: talk)
                            } label: {
                                TalkListItem(talk: talk)
                            }
                        }
                    }
                #else
                    if viewModel.results.isEmpty {
                        List {
                            ForEach(suggestions) { suggestion in
                                Button(suggestion.title) {
                                    viewModel.query = suggestion.title
                                    runSearch()
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        ScrollView {
                            TalksGrid(talks: viewModel.results)
                        }
                    }
                #endif
            }
            #if !os(tvOS)
            .navigationTitle("Search")
            #endif
            .searchable(text: $viewModel.query, prompt: "Search talks...")
            #if os(tvOS)
                .searchSuggestions {
                    ForEach(suggestions) { suggest in
                        Text(suggest.title).searchCompletion(suggest.title)
                    }
                }
            #endif
                .onAppear(perform: runSearch)
                .onSubmit(of: .search, runSearch)
                .alert("Failed to load data from the media.ccc.de API", error: $viewModel.error)
        }
    }

    func runSearch() {
        viewModel.search()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(ApiService())
    }
}
