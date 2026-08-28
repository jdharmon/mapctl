import Foundation
import Testing

@testable import MapCore

@MainActor
struct DirectionsOptionsTests {
  @Test("Defaults are a plain driving route")
  func defaults() {
    let options = DirectionsOptions()
    #expect(options.mode == .driving)
    #expect(options.departureDate == nil)
    #expect(options.arrivalDate == nil)
    #expect(options.includesAlternates == false)
    #expect(options.avoidTolls == false)
    #expect(options.avoidHighways == false)
  }

  @Test("A departure or an arrival is fine, but not both")
  func departureAndArrival() {
    let departure = DirectionsOptions(departureDate: Fixture.date("2026-08-28T17:00:00Z"))
    let arrival = DirectionsOptions(arrivalDate: Fixture.date("2026-08-28T17:00:00Z"))
    #expect(throws: Never.self) { try departure.validate() }
    #expect(throws: Never.self) { try arrival.validate() }

    let both = DirectionsOptions(
      departureDate: Fixture.date("2026-08-28T17:00:00Z"),
      arrivalDate: Fixture.date("2026-08-28T18:00:00Z"))
    #expect(throws: MapCoreError.self) { try both.validate() }
  }

  @Test("Route requests reject transit but ETA requests accept it")
  func transitGuard() {
    let transit = DirectionsOptions(mode: .transit)
    #expect(throws: Never.self) { try transit.validate() }

    let error = #expect(throws: MapCoreError.self) { try transit.validateForRoutes() }
    #expect(error?.errorDescription?.contains("mapctl eta") == true)
    #expect(error?.errorDescription?.contains("mapctl link") == true)
  }

  @Test(
    "Every non-transit mode passes the route guard",
    arguments: [TransportMode.driving, .walking, .cycling, .any])
  func routableModes(mode: TransportMode) {
    #expect(throws: Never.self) { try DirectionsOptions(mode: mode).validateForRoutes() }
  }
}
