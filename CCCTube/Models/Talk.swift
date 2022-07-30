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
struct Talk: Decodable, Identifiable {
  var id: String { guid }

  let guid: String
  let title: String
  let subtitle: String?
  let slug: String
//  let link: URL?
  let description: String?
  let original_language: String?
  let persons: [String]
  let tags: [String]
  let view_count: Int
  let promoted: Bool

  let date: Date?
  let release_date: Date
  let updated_at: Date
  let length: Int
  let duration: Int

  let conference_title: String
  let conference_url: URL

  let thumb_url: URL
  let poster_url: URL
  let timeline_url: URL
  let thumbnails_url: URL
  let frontend_link: URL
  let url: URL
  let related: [RelatedTalk]
}

struct TalkExtended: Decodable {
  let recordings: [Recording]

  func compatibleRecordings() -> [Recording] {
    recordings
      .filter { $0.mime_type == "video/mp4" }
  }
}

struct RelatedTalk: Decodable {
  let event_id: Int // 7361,
  let event_guid: String // "977957d7-ef42-4ea0-8380-b9a48bd583f0",
  let weight: Int // 88
}

