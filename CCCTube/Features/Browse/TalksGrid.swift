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
    LazyVGrid(columns: columns) {
      ForEach(talks) { talk in
        VStack {
          NavigationLink {
            TalkView(talk: talk)
          } label: {
            TalkThumbnail(talk: talk)
          }

          Text(talk.title)
            .font(.caption)
            .lineLimit(2)
        }
        .padding()
      }
    }
    .multilineTextAlignment(.center)
    .focusSection()
    .buttonStyle(.card)
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
