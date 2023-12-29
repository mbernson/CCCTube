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

    @State var error: Error? = nil

    @EnvironmentObject var api: ApiService

    var body: some View {
        ScrollView {
            VStack {
                Text(conference.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.secondary)

                TalksGrid(talks: talks)
            }
        }
        .task {
            do {
                talks = try await api.conference(acronym: conference.acronym).events ?? []
            } catch {
                self.error = error
            }
        }
        .alert("Failed to load data from the media.cc.de API", error: $error)
    }
}

struct ConferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ConferenceView(conference: .example)
    }
}
