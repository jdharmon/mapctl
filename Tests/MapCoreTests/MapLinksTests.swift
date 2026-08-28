import Foundation
import Testing

@testable import MapCore

@MainActor
struct MapLinksTests {
  @Test("A place link carries the query and percent-encodes spaces")
  func placeQuery() {
    let url = MapLinks.placeURL(query: "Golden Gate Bridge")
    #expect(url.absoluteString == "https://maps.apple.com/?q=Golden%20Gate%20Bridge")
  }

  @Test("A place link can carry a coordinate, a query, or both")
  func placeCombinations() {
    #expect(
      MapLinks.placeURL(coordinate: Fixture.appleParkCoordinate).absoluteString
        == "https://maps.apple.com/?ll=37.334859,-122.009040")
    #expect(
      MapLinks.placeURL(query: "Apple Park", coordinate: Fixture.appleParkCoordinate).absoluteString
        == "https://maps.apple.com/?q=Apple%20Park&ll=37.334859,-122.009040")
    #expect(MapLinks.placeURL().absoluteString == "https://maps.apple.com/")
    #expect(MapLinks.placeURL(query: "").absoluteString == "https://maps.apple.com/")
  }

  @Test("A place link built from a Place uses its display name and coordinate")
  func placeFromModel() {
    let url = MapLinks.placeURL(for: Fixture.place(name: "Apple Park"))
    #expect(url.absoluteString == "https://maps.apple.com/?q=Apple%20Park&ll=37.334859,-122.009040")
  }

  @Test(
    "Travel modes map onto the dirflg parameter, with cycling falling back to driving",
    arguments: [
      (TransportMode.driving, "d"),
      (TransportMode.walking, "w"),
      (TransportMode.transit, "r"),
      (TransportMode.cycling, "d"),
      (TransportMode.any, "d"),
    ])
  func directionsFlags(mode: TransportMode, expected: String) {
    #expect(MapLinks.directionsFlag(for: mode) == expected)
  }

  @Test("A directions link carries both endpoints and the mode")
  func directionsURL() {
    let url = MapLinks.directionsURL(from: "SFO", to: "Palo Alto", mode: .walking)
    #expect(url.absoluteString == "https://maps.apple.com/?saddr=SFO&daddr=Palo%20Alto&dirflg=w")
  }

  @Test("Ampersands in a query do not leak into the URL structure")
  func escaping() throws {
    let url = MapLinks.placeURL(query: "Dean & DeLuca")
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    #expect(components.queryItems?.count == 1)
    #expect(components.queryItems?.first?.value == "Dean & DeLuca")
  }
}
