//
//  BrowseView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI

struct BrowseView: View {
  @State var conferences: [Conference] = []
  @State var talks: [Talk] = []

  @State var error: NetworkError? = nil
  @State var isErrorPresented = false

  @EnvironmentObject var api: ApiService

  var body: some View {
    NavigationView {
      ScrollView(.vertical) {
        TalksGrid(talks: talks)
      }
      .task {
        do {
          // conferences = try await api.conferences()
          talks = try await api.recentTalks()
        } catch {
          self.error = NetworkError(error: error)
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

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    BrowseView()
      .environmentObject(ApiService())
  }
}

struct ConferenceThumbnail: View {
  let conference: Conference
  
  var body: some View {
    AsyncImage(url: conference.logo_url) { image in
      image.resizable()
    } placeholder: {
      ProgressView()
    }
    .aspectRatio(4/3, contentMode: .fill)
  }
}

struct TalkThumbnail: View {
  let talk: Talk
  
  var body: some View {
//    VStack(alignment: .center, spacing: 8) {
      AsyncImage(url: talk.thumb_url) { image in
        image.resizable()
      } placeholder: {
        ProgressView()
      }
      .aspectRatio(4/3, contentMode: .fit)
      .frame(idealWidth: 400, idealHeight: 300)

//      Text(talk.title)
//        .font(.caption)
//    }
  }
}

struct TalkListItem: View {
  let talk: Talk

  var body: some View {
    HStack(alignment: .top, spacing: 20) {
      AsyncImage(url: talk.thumb_url) { image in
        image.resizable()
      } placeholder: {
        ProgressView()
      }
      .aspectRatio(4/3, contentMode: .fit)
      .frame(idealWidth: 400, idealHeight: 300)

      VStack(alignment: .leading, spacing: 10) {
        Text(talk.title)
          .font(.headline)
        if let subtitle = talk.subtitle {
          Text(subtitle)
            .font(.subheadline)
        }
      }
    }
  }
}

struct TalksGrid: View {
  let talks: [Talk]
  let columns: [GridItem] = [GridItem(), GridItem(), GridItem(), GridItem()]

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(talks) { talk in
        NavigationLink {
          TalkView(talk: talk)
        } label: {
          TalkThumbnail(talk: talk)
        }
      }
    }
    .focusSection()
    .buttonStyle(.card)
  }
}

struct TalksShelf: View {
  let talks: [Talk]
  var body: some View {
    ScrollView(.horizontal) {
      LazyHStack {
        ForEach(talks) { talk in
          NavigationLink {
            TalkView(talk: talk)
          } label: {
            TalkThumbnail(talk: talk)
          }
        }
      }
      .focusSection()
      .buttonStyle(.card)
    }
  }
}

struct ConferencesGrid: View {
  let conferences: [Conference]
  let columns: [GridItem] = [GridItem(), GridItem(), GridItem(), GridItem()]

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(conferences) { conference in
        NavigationLink {
          ConferenceView(conference: conference)
        } label: {
          ConferenceThumbnail(conference: conference)
        }
      }
    }
    .focusSection()
    .buttonStyle(.card)
  }
}
