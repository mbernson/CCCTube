//
//  Recording.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

/// A recording is a file that belongs to a talk (event).
/// These can be video or audio recordings of the talk in different formats and languages (live-translation), subtitle tracks as srt or slides as pdf.
struct Recording: Decodable, Identifiable {
  let size: Int // 104,
  let length: Int // 1066,
  let mime_type: String // "video/webm",
  let language: String // "eng",
  let filename: String // "mch2022-110-eng-May_Contain_Hackers_2022_Closing_webm-sd.webm",
  let state: String // "new",
  let folder: String // "webm-sd",
  let high_quality: Bool // false,
  let width: Int // 720,
  let height: Int // 576,
  let updated_at: Date // "2022-07-27T16:32:06.835+02:00",
  let recording_url: URL // "https://cdn.media.ccc.de/events/MCH2022/webm-sd/mch2022-110-eng-May_Contain_Hackers_2022_Closing_webm-sd.webm",
  let url: URL // "https://api.media.ccc.de/public/recordings/60791",
  let event_url: URL // "https://api.media.ccc.de/public/events/cf4dc17c-aab4-5868-9b57-100a55a1c2fb",
  let conference_url: URL // "https://api.media.ccc.de/public/conferences/MCH2022"

  var id: String { filename }
}
