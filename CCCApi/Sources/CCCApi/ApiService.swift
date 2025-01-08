//
//  ApiService.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import Foundation

public class ApiService {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.media.ccc.de/public")!
    private let decoder = JSONDecoder()
    private let iso8601Formatter = ISO8601DateFormatter()

    public static let shared = ApiService()

    public init() {
        session = URLSession(configuration: .default)

        // Format should be: yyyy-MM-dd'T'HH:mm:ss.mmm+hh:mm
        iso8601Formatter.formatOptions = [
            .withFullDate, .withFullTime, .withTimeZone,
            .withDashSeparatorInDate, .withColonSeparatorInTime, .withColonSeparatorInTimeZone,
            .withFractionalSeconds,
        ]
        iso8601Formatter.timeZone = .autoupdatingCurrent

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = self.iso8601Formatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to parse ISO 8601 date")
            }
        }
    }

    // MARK: Conferences

    public func conferences() async throws -> [Conference] {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("conferences"))
        let response = try decoder.decode(ConferencesResponse.self, from: data)
        return response.conferences
    }

    public func conference(acronym: String) async throws -> Conference {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("conferences").appendingPathComponent(acronym))
        return try decoder.decode(Conference.self, from: data)
    }

    // MARK: Talks

    public func talk(id: String) async throws -> Talk {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events").appendingPathComponent(id))
        let response = try decoder.decode(Talk.self, from: data)
        return response
    }

    public func talks() async throws -> [Talk] {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events"))
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func recentTalks() async throws -> [Talk] {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events").appendingPathComponent("recent"))
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public enum PopularTalksYear {
        case currentYear
        case year(Int)

        var yearValue: Int {
            switch self {
            case .currentYear:
                let calendar = Calendar.current
                // The 'popular' API call returns talks that were popular by year.
                // Right after the beginning of a new year, it doesn't return anything
                // presumably because there aren't enough views on talk for that year yet.
                // So here, we use the year that it was two weeks ago.
                let date = calendar.date(byAdding: .weekOfYear, value: -2, to: Date.now) ?? Date.now
                return calendar.component(.year, from: date)
            case let .year(value):
                return value
            }
        }
    }

    public func popularTalks(in year: PopularTalksYear) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("popular")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "year", value: String(year.yearValue))]
        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    public func searchTalks(query: String) async throws -> [Talk] {
        let url = baseURL.appendingPathComponent("events").appendingPathComponent("search")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(EventsResponse.self, from: data)
        return response.events
    }

    // MARK: Recordings

    public func recordings(for talk: Talk) async throws -> [Recording] {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("events").appendingPathComponent(talk.guid))
        let response = try decoder.decode(TalkExtended.self, from: data)
        guard let recordings = response.recordings else {
            return []
        }
        return recordings
            // Remove formats Apple doesn't support
            .filter { !$0.mimeType.contains("opus") }
            .filter { !$0.mimeType.contains("webm") }
            .filter { !$0.mimeType.starts(with: "application") }
            // Put the HD versions first
            .sorted(by: { lhs, rhs in
                lhs.isHighQuality && !rhs.isHighQuality
            })
            // Put the audio versions last
            .sorted(by: { lhs, rhs in
                !lhs.isAudio && rhs.isAudio
            })
    }
}
