//
//  TalkListItem.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 27/06/2023.
//

import CCCApi
import SwiftUI

private let minutesFormatter: DateComponentsFormatter = {
    let f = DateComponentsFormatter()
    f.allowedUnits = .minute
    return f
}()

struct TalkListItem: View {
    let talk: Talk

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            let width: CGFloat = 320
            if let imageURL = talk.posterURL ?? talk.thumbURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: width, height: width * (9 / 16))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(talk.title)
                    .font(.headline)
                    .lineLimit(1)

                if let subtitle = talk.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .lineLimit(1)
                }

                Text(talk.conferenceTitle)
                    .font(.body)

                HStack(alignment: .center, spacing: 20) {
                    Label("\(minutesFormatter.string(from: talk.duration) ?? "0") min", systemImage: "clock")

                    Label("Date \(talk.releaseDate, style: .date)", systemImage: "calendar")

                    Label(String(talk.viewCount), systemImage: "eye")

                    if !talk.persons.isEmpty {
                        Label(talk.persons.joined(separator: ", "), systemImage: "person")
                    }
                }
            }
        }
    }
}

struct TalkListItem_Previews: PreviewProvider {
    static var previews: some View {
        TalkListItem(talk: .example)
    }
}
