//
//  ConferencesView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI
import CCCApi

struct ConferencesView: View {
  @State var conferences: [Conference] = []

  @State var error: NetworkError? = nil
  @State var isErrorPresented = false

  @EnvironmentObject var api: ApiService

  var body: some View {
    NavigationView {
      ScrollView {
        ConferencesGrid(conferences: conferences)
      }
      .task {
        do {
          conferences = try await api.conferences()
            .filter { conference in
              conference.eventLastReleasedAt != nil
            }
            .sorted { lhs, rhs in
              let lhsVal = lhs.eventLastReleasedAt ?? lhs.updatedAt
              let rhsVal = rhs.eventLastReleasedAt ?? rhs.updatedAt
              return lhsVal > rhsVal
            }
        } catch {
          self.error = NetworkError(errorDescription: NSLocalizedString("Failed to load data from the media.cc.de API", comment: ""), error: error)
          isErrorPresented = true
          debugPrint(error)
        }
      }
      .alert(isPresented: $isErrorPresented, error: error) {
        Button("OK") {}
      }
    }
  }
}

struct ConferencesGrid: View {
  let conferences: [Conference]
  let columns: [GridItem] = [GridItem(), GridItem(), GridItem(), GridItem()]

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(conferences) { conference in
        VStack {
          NavigationLink {
            ConferenceView(conference: conference)
          } label: {
            ConferenceThumbnail(conference: conference)
          }

          if #available(tvOS 16, *) {
            Text(conference.title)
              .font(.caption)
              .lineLimit(2, reservesSpace: true)
          } else {
            Text(conference.title)
              .font(.caption)
              .lineLimit(2)
          }
        }
      }
    }
    .focusSection()
    .buttonStyle(.card)
  }
}

struct ConferenceThumbnail: View {
  let conference: Conference

  var body: some View {
    let width: CGFloat = 400
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
    .frame(width: width, height: width * (9 / 16))
  }
}

struct ConferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ConferencesView()
    }
}
