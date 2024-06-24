//
//  TalksGrid.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 27/06/2023.
//

import CCCApi
import SwiftUI

struct TalksGrid: View {
    let columns: [GridItem] = Array(repeating: GridItem(), count: 4)

    let talks: [Talk]
    var body: some View {
        #if os(tvOS)
        TalksGridTV(talks: talks, columns: columns)
        #else
        TalksGridRegular(talks: talks, columns: columns)
        #endif
    }
}

private struct TalksGridRegular: View {
    let talks: [Talk]
    let columns: [GridItem]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(talks) { talk in
                NavigationLink {
                    TalkView(talk: talk)
                } label: {
                    TalkCell(talk: talk)
                        #if os(visionOS)
                        .padding()
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                        .hoverEffect(.lift)
                        #endif
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .multilineTextAlignment(.center)
        .accessibilityIdentifier("TalksGrid")
        .accessibilityElement(children: .contain)
    }
}

#if os(tvOS)
private struct TalksGridTV: View {
    let talks: [Talk]
    let columns: [GridItem]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 64) {
            ForEach(talks) { talk in
                VStack(alignment: .leading) {
                    NavigationLink {
                        TalkView(talk: talk)
                    } label: {
                        TalkThumbnail(talk: talk)
                    }

                    Text(talk.title)
                        .font(.headline)
                        .lineLimit(2, reservesSpace: true)
                }
            }
        }
        .padding()
        .multilineTextAlignment(.center)
        .focusSection()
        .buttonStyle(.card)
        .accessibilityIdentifier("TalksGrid")
        .accessibilityElement(children: .contain)
    }
}
#endif

struct TalksGrid_Previews: PreviewProvider {
    static var previews: some View {
        TalksGrid(talks: [.example])
    }
}
