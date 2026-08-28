import Foundation
import Testing

@testable import MapCore

@MainActor
struct ModelsTests {
  @Test("A place prefers its name for display")
  func displayNamePrefersName() {
    #expect(Fixture.place(name: "Apple Park").displayName == "Apple Park")
  }

  @Test("Display names fall back through the address forms to the coordinate")
  func displayNameFallbacks() {
    #expect(Fixture.place(name: nil).displayName == "1 Apple Park Way, Cupertino")
    #expect(Fixture.place(name: "").displayName == "1 Apple Park Way, Cupertino")
    #expect(
      Fixture.place(name: nil, shortAddress: nil).displayName
        == "1 Apple Park Way, Cupertino, CA 95014, United States")
    #expect(
      Fixture.place(name: nil, fullAddress: nil, shortAddress: nil).displayName == "37.334859,-122.009040")
  }

  @Test("A search region defaults to a 10 km radius")
  func regionDefaults() {
    #expect(SearchRegion.defaultRadiusMeters == 10_000)
    #expect(SearchRegion(center: Fixture.appleParkCoordinate).radiusMeters == 10_000)
    #expect(SearchRegion(center: Fixture.appleParkCoordinate, radiusMeters: 500).radiusMeters == 500)
  }

  @Test("Places round-trip through JSON unchanged")
  func placeCoding() throws {
    let place = Fixture.place()
    let data = try JSONEncoder().encode(place)
    #expect(try JSONDecoder().decode(Place.self, from: data) == place)
  }

  @Test("Directions results round-trip through JSON unchanged")
  func directionsCoding() throws {
    let result = DirectionsResult(
      source: Fixture.place(name: "Apple Park"),
      destination: Fixture.place(name: "SFO", coordinate: Fixture.sfoCoordinate),
      routes: [Fixture.route()])
    let data = try JSONEncoder().encode(result)
    #expect(try JSONDecoder().decode(DirectionsResult.self, from: data) == result)
  }

  @Test("ETA results round-trip through JSON unchanged")
  func etaCoding() throws {
    let result = ETAResult(
      source: Fixture.place(name: "Apple Park"),
      destination: Fixture.place(name: "SFO", coordinate: Fixture.sfoCoordinate),
      distanceMeters: 52_360,
      expectedTravelTime: 2_766,
      expectedDepartureDate: Fixture.date("2026-08-28T17:00:00Z"),
      expectedArrivalDate: Fixture.date("2026-08-28T17:46:06Z"),
      transportType: .transit)
    let data = try JSONEncoder().encode(result)
    #expect(try JSONDecoder().decode(ETAResult.self, from: data) == result)
  }

  @Test("Route steps carry an optional notice alongside the instruction")
  func routeStepCoding() throws {
    let step = RouteStep(instructions: "Turn left", notice: "Do not cross when lights flash", distanceMeters: 24)
    let data = try JSONEncoder().encode(step)
    #expect(try JSONDecoder().decode(RouteStep.self, from: data) == step)
    #expect(RouteStep(instructions: "Turn left", distanceMeters: 24).notice == nil)
  }

  @Test("Transport modes encode as their lowercase names")
  func transportModeCoding() throws {
    let data = try JSONEncoder().encode(["mode": TransportMode.cycling])
    #expect(String(data: data, encoding: .utf8) == #"{"mode":"cycling"}"#)
  }
}
