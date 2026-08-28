import Foundation
import Testing

@testable import MapCore

@MainActor
struct DateParsingTests {
  private static let now = Fixture.date("2026-08-28T12:00:00Z")

  @Test("ISO-8601 timestamps parse, with or without fractional seconds")
  func isoFormats() throws {
    let expected = Fixture.date("2026-08-28T17:00:00Z")
    #expect(try DateParsing.require("2026-08-28T17:00:00Z") == expected)
    #expect(try DateParsing.require("2026-08-28T17:00:00.000Z") == expected)
    #expect(try DateParsing.require("2026-08-28T19:00:00+02:00") == expected)
  }

  @Test(
    "Local formats parse against the supplied time zone",
    arguments: [
      "2026-08-28T17:00:00",
      "2026-08-28T17:00",
      "2026-08-28 17:00:00",
      "2026-08-28 17:00",
    ])
  func localFormats(input: String) throws {
    #expect(try DateParsing.require(input, timeZone: Fixture.utc) == Fixture.date("2026-08-28T17:00:00Z"))
  }

  @Test("A bare date resolves to midnight in the supplied time zone")
  func bareDate() throws {
    #expect(try DateParsing.require("2026-08-28", timeZone: Fixture.utc) == Fixture.date("2026-08-28T00:00:00Z"))
  }

  @Test("now resolves to the supplied clock rather than the real one")
  func nowKeyword() throws {
    #expect(try DateParsing.require("now", now: Self.now) == Self.now)
    #expect(try DateParsing.require("NOW", now: Self.now) == Self.now)
  }

  @Test("Unparseable dates are rejected", arguments: ["", "tomorrow", "next tuesday", "28/08/2026", "nope"])
  func rejected(input: String) {
    #expect(DateParsing.parse(input, now: Self.now) == nil)
  }

  @Test("require throws an invalidDate error for bad input")
  func requireThrows() {
    #expect(throws: MapCoreError.invalidDate("tomorrow")) {
      try DateParsing.require("tomorrow", now: Self.now)
    }
  }
}
