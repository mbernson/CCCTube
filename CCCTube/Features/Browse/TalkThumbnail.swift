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
        AsyncImage(url: talk.thumbURL) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .aspectRatio(9 / 16, contentMode: .fill)
    }
}

struct TalkThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        TalkThumbnail(talk: .example)
    }
}
