//
//  ConferencesView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import CCCApi
import SwiftUI

struct ConferencesView: View {
    @State var conferences: [Conference] = []

    @State var error: Error?

    @EnvironmentObject var api: ApiService

    var body: some View {
        NavigationStack {
            ScrollView {
                ConferencesGrid(conferences: conferences)
            }
            #if !os(tvOS)
            .navigationTitle("Conferences")
            #endif
            .task {
                await refresh()
            }
            .alert("Failed to load data from the media.cc.de API", error: $error)
        }
    }

    func refresh() async {
        do {
            conferences = try await api.conferences()
                .filter { conference in
                    conference.eventLastReleasedAt != nil
                }
                .sorted { lhs, rhs in
                    let lhsVal = lhs.eventLastReleasedAt ?? lhs.updatedAt
                    let rhsVal = rhs.eventLastReleasedAt ?? rhs.updatedAt
                    return lhsVal > rhsVal
                }
        } catch {
            self.error = error
        }
    }
}

struct ConferencesGrid: View {
    let conferences: [Conference]

    #if os(tvOS)
        let columns: [GridItem] = [GridItem(), GridItem(), GridItem(), GridItem()]
    #else
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 200))]
    #endif

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(conferences) { conference in
                VStack {
                    NavigationLink {
                        ConferenceView(conference: conference)
                    } label: {
                        ConferenceThumbnail(conference: conference)
                    }

                    if #available(tvOS 16, iOS 16, *) {
                        Text(conference.title)
                            .font(.caption)
                            .lineLimit(2, reservesSpace: true)
                    } else {
                        Text(conference.title)
                            .font(.caption)
                            .lineLimit(2)
                    }
                }
            }
        }
        #if os(tvOS)
        .focusSection()
        .buttonStyle(.card)
        #endif
    }
}

struct ConferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ConferencesView()
    }
}
