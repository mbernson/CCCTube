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
        .padding(10)
        #if os(tvOS)
            .frame(width: width, height: width * (9 / 16))
        #else
            .aspectRatio(16 / 9, contentMode: .fit)
        #endif
            .background(.regularMaterial)
            .cornerRadius(16)
    }
}

struct ConferenceThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        ConferenceThumbnail(conference: .example)
    }
}
