//
//  ConferenceView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import CCCApi
import SwiftUI

struct ConferenceView: View {
    let conference: Conference
    @State var talks: [Talk] = []
    @State var filterQuery = ""
    @State var isLoading = true
    @State var error: Error?

    @State var api: ApiService = .shared

    var body: some View {
        ScrollView {
            #if os(tvOS)
                VStack {
                    Text(conference.title)
                        .font(.largeTitle.bold())
                        .foregroundColor(.secondary)

                    TalksGrid(talks: talks)
                }
            #else
                let filterQuery = filterQuery.lowercased()
                TalksGrid(talks: filterQuery.isEmpty ? talks : talks.filter { talk in
                    talk.title.lowercased().contains(filterQuery)
                })
            #endif
        }
        .overlay {
            if isLoading {
                ProgressView()
            } else if talks.isEmpty {
                Text("No talks found")
            }
        }
        #if !os(tvOS)
        .searchable(text: $filterQuery)
        .navigationTitle(conference.title)
        #endif
        .task {
            await refresh()
        }
        .refreshable {
            await refresh()
        }
        .alert("Failed to load data from the media.ccc.de API", error: $error)
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            talks = try await api.conference(acronym: conference.acronym).events ?? []
        } catch is CancellationError {
        } catch {
            self.error = error
        }
    }
}

struct ConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ConferenceView(conference: .example)
    }
}
