//
//  Talk.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

struct EventsResponse: Decodable {
  let events: [Event]
}

typealias Event = Talk

/// Every talk (alias event, in other systems also called lecture or session) is assigned to exactly one conference (e.g. the congress or lecture series like datengarten or openchaos) and consists of multiple files alias recordings.
/// These files can be video or audio recordings of the talk in different formats and languages (live-translation), subtitle tracks as srt or slides as pdf.
public struct Talk: Decodable, Identifiable {
  public var id: String { guid }

  public let guid: String
  public let title: String
  public let subtitle: String?
  public let slug: String
  public let link: URL?
  public let description: String?
  public let originalLanguage: String?
  public let persons: [String]
  public let tags: [String]
  public let viewCount: Int
  public let isPromoted: Bool
  public let date: Date?
  public let releaseDate: Date
  public let updatedAt: Date
  public let length: TimeInterval
  public let duration: TimeInterval
  public let conferenceTitle: String
  public let conferenceURL: URL
  public let thumbURL: URL?
  public let posterURL: URL?
  public let timelineURL: URL
  public let thumbnailsURL: URL
  public let frontendLink: URL
  public let url: URL
  public let related: [RelatedTalk]

  init(guid: String, title: String, subtitle: String?, slug: String, link: URL?, description: String?, originalLanguage: String?, persons: [String], tags: [String], viewCount: Int, isPromoted: Bool, date: Date?, releaseDate: Date, updatedAt: Date, length: TimeInterval, duration: TimeInterval, conferenceTitle: String, conferenceURL: URL, thumbURL: URL?, posterURL: URL, timelineURL: URL, thumbnailsURL: URL, frontendLink: URL, url: URL, related: [RelatedTalk]) {
    self.guid = guid
    self.title = title
    self.subtitle = subtitle
    self.slug = slug
    self.link = link
    self.description = description
    self.originalLanguage = originalLanguage
    self.persons = persons
    self.tags = tags
    self.viewCount = viewCount
    self.isPromoted = isPromoted
    self.date = date
    self.releaseDate = releaseDate
    self.updatedAt = updatedAt
    self.length = length
    self.duration = duration
    self.conferenceTitle = conferenceTitle
    self.conferenceURL = conferenceURL
    self.thumbURL = thumbURL
    self.posterURL = posterURL
    self.timelineURL = timelineURL
    self.thumbnailsURL = thumbnailsURL
    self.frontendLink = frontendLink
    self.url = url
    self.related = related
  }

  enum CodingKeys: String, CodingKey {
    case guid = "guid"
    case title = "title"
    case subtitle = "subtitle"
    case slug = "slug"
    case link = "link"
    case description = "description"
    case originalLanguage = "original_language"
    case persons = "persons"
    case tags = "tags"
    case viewCount = "view_count"
    case isPromoted = "promoted"
    case date = "date"
    case releaseDate = "release_date"
    case updatedAt = "updated_at"
    case length = "length"
    case duration = "duration"
    case conferenceTitle = "conference_title"
    case conferenceURL = "conference_url"
    case thumbURL = "thumb_url"
    case posterURL = "poster_url"
    case timelineURL = "timeline_url"
    case thumbnailsURL = "thumbnails_url"
    case frontendLink = "frontend_link"
    case url = "url"
    case related = "related"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    guid = try container.decode(String.self, forKey: .guid)
    title = try container.decode(String.self, forKey: .title)
    subtitle = try container.decode(String?.self, forKey: .subtitle)
    slug = try container.decode(String.self, forKey: .slug)
    link = try? container.decode(URL?.self, forKey: .link)
    description = try container.decode(String?.self, forKey: .description)
    originalLanguage = try container.decode(String?.self, forKey: .originalLanguage)
    persons = try container.decode([String].self, forKey: .persons)
    tags = try container.decode([String].self, forKey: .tags)
    viewCount = try container.decode(Int.self, forKey: .viewCount)
    isPromoted = try container.decode(Bool.self, forKey: .isPromoted)
    date = try container.decode(Date?.self, forKey: .date)
    releaseDate = try container.decode(Date.self, forKey: .releaseDate)
    updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    length = try container.decode(TimeInterval.self, forKey: .length)
    duration = try container.decode(TimeInterval.self, forKey: .duration)
    conferenceTitle = try container.decode(String.self, forKey: .conferenceTitle)
    conferenceURL = try container.decode(URL.self, forKey: .conferenceURL)
    thumbURL = try? container.decode(URL?.self, forKey: .thumbURL)
    posterURL = try? container.decode(URL.self, forKey: .posterURL)
    timelineURL = try container.decode(URL.self, forKey: .timelineURL)
    thumbnailsURL = try container.decode(URL.self, forKey: .thumbnailsURL)
    frontendLink = try container.decode(URL.self, forKey: .frontendLink)
    url = try container.decode(URL.self, forKey: .url)
    related = try container.decode([RelatedTalk].self, forKey: .related)
  }
}

struct TalkExtended: Decodable {
  let recordings: [Recording]?

  func compatibleRecordings() -> [Recording] {
    guard let recordings = recordings else {
      return []
    }

    return recordings
      .filter { $0.mimeType == "video/mp4" }
  }
}

public struct RelatedTalk: Decodable {
  let event_id: Int // 7361,
  let event_guid: String // "977957d7-ef42-4ea0-8380-b9a48bd583f0",
  let weight: Int // 88
}

