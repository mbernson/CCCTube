//
//  JSONDecoderExtensions.swift
//
//
//  Created by Mathijs Bernson on 14/06/2024.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static func iso8601(
        formatOptions: ISO8601DateFormatter.Options,
        timeZone: TimeZone
    ) -> Self {
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = formatOptions
        iso8601Formatter.timeZone = timeZone

        return .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to parse ISO 8601 date")
            }
        }
    }
}
