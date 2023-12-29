//
//  ConferenceThumbnail.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 14/07/2023.
//

import CCCApi
import SwiftUI

struct ConferenceThumbnail: View {
    let conference: Conference

    var body: some View {
        AsyncImage(url: conference.logoURL) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else if phase.error != nil {
                Text(conference.acronym)
                    .font(.title3.monospaced())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

#Preview("Conference thumbnail") {
    ConferenceThumbnail(conference: .example)
        .border(.blue)
}
