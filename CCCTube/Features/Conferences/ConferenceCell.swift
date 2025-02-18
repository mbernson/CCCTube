//
//  ConferenceCell.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 26/01/2025.
//

import CCCApi
import SwiftUI

struct ConferenceCell: View {
    let conference: Conference

    var body: some View {
        VStack {
            ConferenceThumbnail(conference: conference)

            Text(conference.title)
                .font(.headline)
                .lineLimit(2, reservesSpace: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    Button {
    } label: {
        ConferenceCell(conference: .example)
    }
    .border(.blue)
    .padding()
}
