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
  let updated_at: Date // "2022-07-29T20:45:05.144+02:00",
  let event_last_released_at: Date? // "2022-06-06T00:00:00.000+02:00",

//  let link: String? // "https://streaming.media.ccc.de/rc3/relive",
  let description: String? // "bla:",
  let aspect_ratio: AspectRatio // "16:9",
  let webgen_location: String // "conferences/rc3/2021",

  let url: URL // "https://api.media.ccc.de/public/conferences/rc3-2021"
  let logo_url: URL // "https://static.media.ccc.de/media/events/rc3/2021/rC3_21-logo.png",
//  let images_url: URL // "https://static.media.ccc.de/media/events/rc3/2021",
//  let recordings_url: URL // "https://cdn.media.ccc.de/events/rc3/2021",

  var id: String { slug }
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
//      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid aspect ratio")
      self.width = 4
      self.height = 3
    } else {
      self.width = parts[0]
      self.height = parts[1]
    }
  }
}
