import Foundation
import Testing

@testable import MapCore

@MainActor
struct TransportModeTests {
  @Test(
    "Common synonyms map to the canonical mode",
    arguments: [
      ("driving", TransportMode.driving),
      ("drive", TransportMode.driving),
      ("CAR", TransportMode.driving),
      ("walking", TransportMode.walking),
      ("foot", TransportMode.walking),
      ("bike", TransportMode.cycling),
      ("cycling", TransportMode.cycling),
      ("transit", TransportMode.transit),
      ("  Train  ", TransportMode.transit),
      ("any", TransportMode.any),
    ])
  func synonyms(input: String, expected: TransportMode) {
    #expect(TransportMode.parse(input) == expected)
  }

  @Test("Unknown modes are rejected", arguments: ["", "teleport", "helicopter"])
  func rejected(input: String) {
    #expect(TransportMode.parse(input) == nil)
  }

  @Test("require throws an invalidTransportMode error for bad input")
  func requireThrows() {
    #expect(throws: MapCoreError.invalidTransportMode("teleport")) {
      try TransportMode.require("teleport")
    }
  }

  @Test("Transit is the only mode without turn-by-turn routes")
  func routeSupport() {
    for mode in TransportMode.allCases {
      #expect(mode.supportsRoutes == (mode != .transit))
    }
  }
}
