//
//  ApiService.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

class ApiService: ObservableObject {
  private let session: URLSession
  private let baseURL = URL(string: "https://api.media.ccc.de/public")!
  private let decoder = JSONDecoder()
  private let iso8601Formatter = ISO8601DateFormatter()

  init() {
    session = .shared

    // Format should be: yyyy-MM-dd'T'HH:mm:ss+hh:mm
    iso8601Formatter.formatOptions = [
      .withFullDate, .withFullTime, .withTimeZone,
      .withDashSeparatorInDate, .withColonSeparatorInTime, .withColonSeparatorInTimeZone,
      .withFractionalSeconds,
    ]
    iso8601Formatter.timeZone = .autoupdatingCurrent

    decoder.dateDecodingStrategy = .custom({ decoder in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)
      if let date = self.iso8601Formatter.date(from: dateString) {
        return date
      } else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to parse ISO 8601 date")
      }
    })
  }

  // MARK: Conferences

  func conferences() async throws -> [Conference] {
    let (data, _) = try await session.data(from: baseURL.appendingPathComponent("conferences"))
    let response = try decoder.decode(ConferencesResponse.self, from: data)
    return response.conferences
  }

  // MARK: Talks

  func talks() async throws -> [Talk] {
    let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events"))
    let response = try decoder.decode(EventsResponse.self, from: data)
    return response.events
  }

  func recentTalks() async throws -> [Talk] {
    let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events").appendingPathComponent("recent"))
    let response = try decoder.decode(EventsResponse.self, from: data)
    return response.events
  }

  func searchTalks(query: String) async throws -> [Talk] {
    let url = baseURL.appendingPathComponent("events").appendingPathComponent("search")
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    components.queryItems = [URLQueryItem(name: "q", value: query)]
    let (data, _) = try await session.data(from: components.url!)
    let response = try decoder.decode(EventsResponse.self, from: data)
    return response.events
  }

  // MARK: Recordings

  func recordings(for talk: Talk) async throws -> [Recording] {
    let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events").appendingPathComponent(talk.guid))
    let response = try decoder.decode(TalkExtended.self, from: data)
    return response.recordings
  }
}
