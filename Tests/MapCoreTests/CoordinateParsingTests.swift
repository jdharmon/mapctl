import Foundation
import Testing

@testable import MapCore

@MainActor
struct CoordinateParsingTests {
  @Test(
    "Coordinates parse from every accepted separator",
    arguments: [
      "37.334859,-122.009040",
      "37.334859, -122.009040",
      "37.334859/-122.009040",
      "37.334859 -122.009040",
      "  37.334859,-122.009040  ",
    ])
  func acceptedSeparators(input: String) throws {
    let coordinate = try #require(CoordinateParsing.parse(input))
    #expect(coordinate == Fixture.appleParkCoordinate)
  }

  @Test(
    "Malformed and out-of-range coordinates are rejected",
    arguments: [
      "",
      "37.334859",
      "37.334859,-122.009040,10",
      "north,west",
      "91,0",
      "-91,0",
      "0,181",
      "0,-181",
    ])
  func rejected(input: String) {
    #expect(CoordinateParsing.parse(input) == nil)
  }

  @Test("The poles and the antimeridian are inside the accepted range")
  func boundaries() {
    #expect(CoordinateParsing.parse("90,180") == Coordinate(latitude: 90, longitude: 180))
    #expect(CoordinateParsing.parse("-90,-180") == Coordinate(latitude: -90, longitude: -180))
  }

  @Test("require throws an invalidCoordinate error for bad input")
  func requireThrows() {
    #expect(throws: MapCoreError.invalidCoordinate("nope")) {
      try CoordinateParsing.require("nope")
    }
    #expect(throws: Never.self) {
      try CoordinateParsing.require("37.334859,-122.009040")
    }
  }

  @Test("Formatting pads to six decimal places")
  func formatting() {
    #expect(CoordinateParsing.format(Coordinate(latitude: 37.5, longitude: -122)) == "37.500000,-122.000000")
    #expect(CoordinateParsing.format(Fixture.appleParkCoordinate) == "37.334859,-122.009040")
  }

  @Test("Formatted output parses back to the same coordinate")
  func roundTrip() throws {
    let formatted = CoordinateParsing.format(Fixture.sfoCoordinate)
    #expect(try CoordinateParsing.require(formatted) == Fixture.sfoCoordinate)
  }
}
