import Foundation
import MapCore
import Testing

@testable import mapctl

@MainActor
struct LinkCommandTests {
  @Test("A bare query produces a place link without any network lookup")
  func placeLink() async throws {
    let result = try await LinkCommand.resolve(values: Values.make(positional: ["Golden Gate Bridge"]))
    #expect(result.kind == "place")
    #expect(result.url == "https://maps.apple.com/?q=Golden%20Gate%20Bridge")
  }

  @Test("A coordinate query produces a pinned place link")
  func coordinateLink() async throws {
    let result = try await LinkCommand.resolve(values: Values.make(positional: ["37.334859,-122.009040"]))
    #expect(result.url == "https://maps.apple.com/?ll=37.334859,-122.009040")
  }

  @Test("--from and --to produce a directions link carrying the mode")
  func directionsLink() async throws {
    let values = Values.make(options: ["from": ["SFO"], "to": ["Palo Alto"], "mode": ["walking"]])
    let result = try await LinkCommand.resolve(values: values)
    #expect(result.kind == "directions")
    #expect(result.url == "https://maps.apple.com/?saddr=SFO&daddr=Palo%20Alto&dirflg=w")
  }

  @Test("A trip link needs both endpoints")
  func incompleteTrip() async {
    await #expect(throws: MapCoreError.self) {
      try await LinkCommand.resolve(values: Values.make(options: Values.option("from", "SFO")))
    }
    await #expect(throws: MapCoreError.self) {
      try await LinkCommand.resolve(values: Values.make(options: Values.option("to", "SFO")))
    }
  }

  @Test("A place link with no query at all is rejected")
  func missingQuery() async {
    await #expect(throws: ParsedValuesError.self) {
      try await LinkCommand.resolve(values: Values.make())
    }
  }

  @Test("An invalid mode on a trip link is rejected")
  func invalidMode() async {
    let values = Values.make(options: ["from": ["A"], "to": ["B"], "mode": ["teleport"]])
    await #expect(throws: MapCoreError.invalidTransportMode("teleport")) {
      try await LinkCommand.resolve(values: values)
    }
  }
}
