//
//  TalkThumbnail.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 14/07/2023.
//

import CCCApi
import SwiftUI

struct TalkThumbnail: View {
    let talk: Talk

    var body: some View {
        AsyncImage(url: talk.posterURL ?? talk.thumbURL) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else if phase.error != nil {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(16 / 9, contentMode: .fill)
    }
}

#Preview("Talk thumbnail") {
    TalkThumbnail(talk: .example)
        .border(.blue)
}
