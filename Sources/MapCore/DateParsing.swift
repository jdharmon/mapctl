import Foundation

/// Parses the departure/arrival timestamps accepted by `directions` and `eta`.
/// Deliberately narrow: absolute times only, plus `now`.
public enum DateParsing {
  private static let localFormats = [
    "yyyy-MM-dd'T'HH:mm:ss",
    "yyyy-MM-dd'T'HH:mm",
    "yyyy-MM-dd HH:mm:ss",
    "yyyy-MM-dd HH:mm",
    "yyyy-MM-dd",
  ]

  public static func parse(_ input: String, now: Date = Date(), timeZone: TimeZone = .current) -> Date? {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    if trimmed.lowercased() == "now" { return now }

    let isoParser = ISO8601DateFormatter()
    isoParser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = isoParser.date(from: trimmed) { return date }
    isoParser.formatOptions = [.withInternetDateTime]
    if let date = isoParser.date(from: trimmed) { return date }

    for format in localFormats {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = timeZone
      formatter.dateFormat = format
      if let date = formatter.date(from: trimmed) { return date }
    }
    return nil
  }

  public static func require(_ input: String, now: Date = Date(), timeZone: TimeZone = .current) throws -> Date {
    guard let date = parse(input, now: now, timeZone: timeZone) else {
      throw MapCoreError.invalidDate(input)
    }
    return date
  }
}
