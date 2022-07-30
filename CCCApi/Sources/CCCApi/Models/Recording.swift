//
//  Recording.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

/// A recording is a file that belongs to a talk (event).
/// These can be video or audio recordings of the talk in different formats and languages (live-translation), subtitle tracks as srt or slides as pdf.
public struct Recording: Decodable, Identifiable {
  public let size: Int // 104,
  public let length: Int // 1066,
  public let mimeType: String // "video/webm",
  public let language: String // "eng",
  public let filename: String // "mch2022-110-eng-May_Contain_Hackers_2022_Closing_webm-sd.webm",
  public let state: String // "new",
  public let folder: String // "webm-sd",
  public let isHighQuality: Bool // false,
  public let width: Int // 720,
  public let height: Int // 576,
  public let updatedAt: Date // "2022-07-27T16:32:06.835+02:00",
  public let url: URL // "https://cdn.media.ccc.de/events/MCH2022/webm-sd/mch2022-110-eng-May_Contain_Hackers_2022_Closing_webm-sd.webm",
  public let recordingURL: URL // "https://api.media.ccc.de/public/recordings/60791",
  public let eventURL: URL // "https://api.media.ccc.de/public/events/cf4dc17c-aab4-5868-9b57-100a55a1c2fb",
  public let conferenceURL: URL // "https://api.media.ccc.de/public/conferences/MCH2022"

  public var id: String { filename }

  init(size: Int, length: Int, mimeType: String, language: String, filename: String, state: String, folder: String, isHighQuality: Bool, width: Int, height: Int, updatedAt: Date, url: URL, recordingURL: URL, eventURL: URL, conferenceURL: URL) {
    self.size = size
    self.length = length
    self.mimeType = mimeType
    self.language = language
    self.filename = filename
    self.state = state
    self.folder = folder
    self.isHighQuality = isHighQuality
    self.width = width
    self.height = height
    self.updatedAt = updatedAt
    self.url = url
    self.recordingURL = recordingURL
    self.eventURL = eventURL
    self.conferenceURL = conferenceURL
  }

  enum CodingKeys: String, CodingKey {
    case size = "size"
    case length = "length"
    case mimeType = "mime_type"
    case language = "language"
    case filename = "filename"
    case state = "state"
    case folder = "folder"
    case isHighQuality = "high_quality"
    case width = "width"
    case height = "height"
    case updatedAt = "updated_at"
    case url = "url"
    case recordingURL = "recording_url"
    case eventURL = "event_url"
    case conferenceURL = "conference_url"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    size = try container.decode(Int.self, forKey: .size)
    length = try container.decode(Int.self, forKey: .length)
    mimeType = try container.decode(String.self, forKey: .mimeType)
    language = try container.decode(String.self, forKey: .language)
    filename = try container.decode(String.self, forKey: .filename)
    state = try container.decode(String.self, forKey: .state)
    folder = try container.decode(String.self, forKey: .folder)
    isHighQuality = try container.decode(Bool.self, forKey: .isHighQuality)
    width = try container.decode(Int.self, forKey: .width)
    height = try container.decode(Int.self, forKey: .height)
    updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    url = try container.decode(URL.self, forKey: .url)
    recordingURL = try container.decode(URL.self, forKey: .recordingURL)
    eventURL = try container.decode(URL.self, forKey: .eventURL)
    conferenceURL = try container.decode(URL.self, forKey: .conferenceURL)
  }
}
