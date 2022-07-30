//
//  Conference.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

struct ConferencesResponse: Decodable {
  let conferences: [Conference]
}

/// e.g. the congress or lecture series like datengarten or openchaos
struct Conference: Decodable, Identifiable {
  let acronym: String // "rc3-2021",
  let slug: String // "conferences/rc3/2021",
  let title: String // "rC3 NOWHERE",
  let updatedAt: Date // "2022-07-29T20:45:05.144+02:00",
  let eventLastReleasedAt: Date? // "2022-06-06T00:00:00.000+02:00",
  let link: URL? // "https://streaming.media.ccc.de/rc3/relive",
  let description: String? // "bla:",
  let aspectRatio: AspectRatio? // "16:9",
  let webgenLocation: String // "conferences/rc3/2021",
  let url: URL // "https://api.media.ccc.de/public/conferences/rc3-2021"
  let logoURL: URL // "https://static.media.ccc.de/media/events/rc3/2021/rC3_21-logo.png",
  let imagesURL: URL? // "https://static.media.ccc.de/media/events/rc3/2021",
  let recordingsURL: URL? // "https://cdn.media.ccc.de/events/rc3/2021",

  var id: String { slug }

  init(acronym: String, slug: String, title: String, updatedAt: Date, eventLastReleasedAt: Date?, link: URL?, description: String?, aspectRatio: AspectRatio, webgenLocation: String, url: URL, logoURL: URL, imagesURL: URL?, recordingsURL: URL?) {
    self.acronym = acronym
    self.slug = slug
    self.title = title
    self.updatedAt = updatedAt
    self.eventLastReleasedAt = eventLastReleasedAt
    self.link = link
    self.description = description
    self.aspectRatio = aspectRatio
    self.webgenLocation = webgenLocation
    self.url = url
    self.logoURL = logoURL
    self.imagesURL = imagesURL
    self.recordingsURL = recordingsURL
  }

  enum CodingKeys: String, CodingKey {
    case acronym = "acronym"
    case slug = "slug"
    case title = "title"
    case updatedAt = "updated_at"
    case eventLastReleasedAt = "event_last_released_at"
    case link = "link"
    case description = "description"
    case aspectRatio = "aspect_ratio"
    case webgenLocation = "webgen_location"
    case url = "url"
    case logoURL = "logo_url"
    case imagesURL = "images_url"
    case recordingsURL = "recordings_url"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    acronym = try container.decode(String.self, forKey: .acronym)
    slug = try container.decode(String.self, forKey: .slug)
    title = try container.decode(String.self, forKey: .title)
    updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    eventLastReleasedAt = try container.decode(Date?.self, forKey: .eventLastReleasedAt)
    link = try? container.decode(URL?.self, forKey: .link)
    description = try container.decode(String?.self, forKey: .description)
    aspectRatio = try? container.decode(AspectRatio.self, forKey: .aspectRatio)
    webgenLocation = try container.decode(String.self, forKey: .webgenLocation)
    url = try container.decode(URL.self, forKey: .url)
    logoURL = try container.decode(URL.self, forKey: .logoURL)
    imagesURL = try? container.decode(URL?.self, forKey: .imagesURL)
    recordingsURL = try? container.decode(URL?.self, forKey: .recordingsURL)
  }
}

struct AspectRatio: Decodable {
  let width: Double
  let height: Double

  var ratio: Double { width / height }

  init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    let parts = string.components(separatedBy: ":")
      .compactMap(Double.init)
    if parts.count != 2 {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid aspect ratio")
    } else {
      self.width = parts[0]
      self.height = parts[1]
    }
  }
}
