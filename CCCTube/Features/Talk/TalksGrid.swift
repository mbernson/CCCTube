//
//  TalksGrid.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 27/06/2023.
//

import CCCApi
import SwiftUI

struct TalksGrid: View {
    let talks: [Talk]

    #if os(tvOS)
        let columns: [GridItem] = Array(repeating: GridItem(), count: 4)
    #else
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 200, maximum: 400))]
    #endif

    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(talks) { talk in
                VStack {
                    NavigationLink {
                        TalkView(talk: talk)
                    } label: {
                        TalkThumbnail(talk: talk)
                        #if os(tvOS)
                            .frame(width: 400, height: 225)
                        #endif
                    }

                    Text(talk.title)
                        .font(.subheadline)
                        .lineLimit(2, reservesSpace: true)
                }
            }
        }
        .padding()
        .multilineTextAlignment(.center)
        #if os(tvOS)
            .focusSection()
            .buttonStyle(.card)
        #endif
            .accessibilityIdentifier("TalksGrid")
            .accessibilityElement(children: .contain)
    }
}

struct TalksGrid_Previews: PreviewProvider {
    static var previews: some View {
        TalksGrid(talks: [.example])
    }
}
