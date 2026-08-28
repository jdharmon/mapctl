import Foundation
import Testing

@testable import MapCore

@MainActor
struct DistanceParsingTests {
  @Test(
    "Distances parse into metres",
    arguments: [
      ("500", 500.0),
      ("500m", 500.0),
      ("500 m", 500.0),
      ("2km", 2_000.0),
      ("1.5mi", 2_414.016),
      ("3000ft", 914.4),
      ("100yd", 91.44),
      ("2 KILOMETERS", 2_000.0),
    ])
  func parsing(input: String, expected: Double) throws {
    let meters = try #require(DistanceParsing.parseMeters(input))
    #expect(abs(meters - expected) < 0.001)
  }

  @Test(
    "Unparseable and non-positive distances are rejected",
    arguments: ["", "   ", "km", "-5", "0", "0km", "5 parsecs", "abc"])
  func rejected(input: String) {
    #expect(DistanceParsing.parseMeters(input) == nil)
  }

  @Test("requireMeters throws an invalidDistance error for bad input")
  func requireThrows() {
    #expect(throws: MapCoreError.invalidDistance("5 parsecs")) {
      try DistanceParsing.requireMeters("5 parsecs")
    }
  }
}
