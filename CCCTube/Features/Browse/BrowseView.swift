//
//  BrowseView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI
import CCCApi

enum EventsQuery {
  case recent
  case popular
}

struct BrowseView: View {
  let query: EventsQuery
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
          switch query {
          case .recent:
            talks = try await api.recentTalks()
          case .popular:
            talks = try await api.popularTalks()
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

//struct HomeView_Previews: PreviewProvider {
//  static var previews: some View {
//    BrowseView()
//      .environmentObject(ApiService())
//  }
//}

struct ConferenceThumbnail: View {
  let conference: Conference
  
  var body: some View {
    AsyncImage(url: conference.logoURL) { image in
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
    AsyncImage(url: talk.thumbURL) { image in
      image.resizable()
    } placeholder: {
      ProgressView()
    }
    .aspectRatio(4/3, contentMode: .fit)
    .frame(idealWidth: 400, idealHeight: 300)
  }
}

struct TalkListItem: View {
  let talk: Talk
  static let minutesFormatter: DateComponentsFormatter = {
    let f = DateComponentsFormatter()
    f.allowedUnits = .minute
    return f
  }()

  var body: some View {
    HStack(alignment: .top, spacing: 20) {
      AsyncImage(url: talk.thumbURL) { phase in
        switch phase {
        case .empty:
          ProgressView()
        case .success(let image):
          image.resizable()
        case .failure:
          Image(systemName: "photo")
        @unknown default:
          EmptyView()
        }
      }
      .aspectRatio(4/3, contentMode: .fit)
      .frame(idealWidth: 400, idealHeight: 300)

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
          Label("\(Self.minutesFormatter.string(from: talk.duration) ?? "0") min", systemImage: "clock")

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

struct TalksGrid: View {
  let talks: [Talk]
  let columns: [GridItem] = [GridItem(), GridItem(), GridItem(), GridItem()]

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(talks) { talk in
        VStack(alignment: .center, spacing: 4) {
          NavigationLink {
            TalkView(talk: talk)
          } label: {
            TalkThumbnail(talk: talk)
          }
          
          Text(talk.title)
            .font(.caption)
            .lineLimit(1)
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
