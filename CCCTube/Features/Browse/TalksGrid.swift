//
//  TalksGrid.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 27/06/2023.
//

import SwiftUI
import CCCApi

struct TalksGrid: View {
  let talks: [Talk]
  let columns: [GridItem] = [GridItem(), GridItem(), GridItem(), GridItem()]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 24) {
      ForEach(talks) { talk in
        VStack {
          NavigationLink {
            TalkView(talk: talk)
          } label: {
            TalkThumbnail(talk: talk)
          }

          if #available(tvOS 16, iOS 16, *) {
            Text(talk.title)
              .font(.caption)
              .lineLimit(2, reservesSpace: true)
          } else {
            Text(talk.title)
              .font(.caption)
              .lineLimit(2)
          }
        }
      }
    }
    .padding()
    .multilineTextAlignment(.center)
#if os(tvOS)
    .focusSection()
    .buttonStyle(.card)
#endif
  }
}

struct TalkThumbnail: View {
  let talk: Talk

  var body: some View {
    let width: CGFloat = 400
    AsyncImage(url: talk.thumbURL) { image in
      image.resizable().scaledToFit()
    } placeholder: {
      ProgressView()
    }
    .frame(width: width, height: width * (9 / 16))
  }
}

struct TalksGrid_Previews: PreviewProvider {
    static var previews: some View {
      TalksGrid(talks: [.example])
    }
}
