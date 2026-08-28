import Foundation
import MapCore
import Testing

@testable import mapctl

@MainActor
struct CommandHelpersTests {
  @Test("Limits trim the result list and default to leaving it alone")
  func limits() throws {
    let items = [1, 2, 3, 4, 5]
    #expect(try CommandHelpers.applyLimit(items, limit: nil) == items)
    #expect(try CommandHelpers.applyLimit(items, limit: "2") == [1, 2])
    #expect(try CommandHelpers.applyLimit(items, limit: "99") == items)
  }

  @Test("Non-positive limits are rejected", arguments: ["0", "-1", "two", ""])
  func invalidLimits(limit: String) {
    #expect(throws: MapCoreError.self) {
      try CommandHelpers.applyLimit([1, 2, 3], limit: limit)
    }
  }

  @Test("Comma-separated values are split and trimmed")
  func commaSeparated() {
    #expect(CommandHelpers.commaSeparated("cafe, bakery ,brewery") == ["cafe", "bakery", "brewery"])
    #expect(CommandHelpers.commaSeparated("cafe") == ["cafe"])
    #expect(CommandHelpers.commaSeparated(",, ,") == [])
    #expect(CommandHelpers.commaSeparated(nil) == [])
  }

  @Test("Avoidances accept a repeated option and a comma-separated list alike")
  func avoidances() {
    #expect(
      CommandHelpers.avoidances(in: Values.make(options: ["avoid": ["tolls,highways"]])) == ["tolls", "highways"])
    #expect(
      CommandHelpers.avoidances(in: Values.make(options: ["avoid": ["tolls", "HIGHWAYS"]])) == ["tolls", "highways"])
    #expect(CommandHelpers.avoidances(in: Values.make()).isEmpty)
  }

  @Test("Required arguments reject missing and blank values")
  func requiredArgument() throws {
    #expect(try CommandHelpers.requiredArgument(Values.make(positional: [" x "]), at: 0, name: "query") == "x")
    #expect(throws: ParsedValuesError.self) {
      try CommandHelpers.requiredArgument(Values.make(), at: 0, name: "query")
    }
    #expect(throws: ParsedValuesError.self) {
      try CommandHelpers.requiredArgument(Values.make(positional: ["  "]), at: 0, name: "query")
    }
  }

  @Test("Directions options are assembled from the parsed flags and options")
  func directionsOptions() throws {
    let values = Values.make(
      options: ["mode": ["walking"], "depart": ["2026-08-28T17:00:00Z"], "avoid": ["tolls"]],
      flags: ["alternates"])
    let options = try CommandHelpers.directionsOptions(from: values)

    #expect(options.mode == .walking)
    #expect(options.departureDate != nil)
    #expect(options.arrivalDate == nil)
    #expect(options.includesAlternates)
    #expect(options.avoidTolls)
    #expect(options.avoidHighways == false)
  }

  @Test("Directions options default to a plain driving route")
  func directionsDefaults() throws {
    let options = try CommandHelpers.directionsOptions(from: Values.make())
    #expect(options == DirectionsOptions())
  }

  @Test("Directions options reject a bad mode, a bad date, and conflicting times")
  func directionsValidation() {
    #expect(throws: MapCoreError.invalidTransportMode("teleport")) {
      try CommandHelpers.directionsOptions(from: Values.make(options: Values.option("mode", "teleport")))
    }
    #expect(throws: MapCoreError.invalidDate("tomorrow")) {
      try CommandHelpers.directionsOptions(from: Values.make(options: Values.option("depart", "tomorrow")))
    }
    #expect(throws: MapCoreError.self) {
      try CommandHelpers.directionsOptions(
        from: Values.make(options: ["depart": ["2026-08-28T17:00:00Z"], "arrive": ["2026-08-28T18:00:00Z"]]))
    }
  }
}
