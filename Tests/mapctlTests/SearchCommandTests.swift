import Foundation
import MapCore
import Testing

@testable import mapctl

@MainActor
struct SearchCommandTests {
  @Test("Omitting --types searches addresses and points of interest")
  func defaultTypes() throws {
    #expect(try SearchCommand.resultTypes(from: nil) == ["address", "poi"])
    #expect(try SearchCommand.resultTypes(from: "") == ["address", "poi"])
  }

  @Test(
    "Type names and their plurals resolve to the same set",
    arguments: [
      ("address", Set(["address"])),
      ("addresses", Set(["address"])),
      ("poi", Set(["poi"])),
      ("points-of-interest", Set(["poi"])),
      ("both", Set(["address", "poi"])),
      ("all", Set(["address", "poi"])),
      ("address,poi", Set(["address", "poi"])),
      ("POI, Address", Set(["address", "poi"])),
    ])
  func typeParsing(input: String, expected: Set<String>) throws {
    #expect(try SearchCommand.resultTypes(from: input) == expected)
  }

  @Test("Unknown result types are rejected")
  func invalidType() {
    #expect(throws: MapCoreError.self) {
      try SearchCommand.resultTypes(from: "landmarks")
    }
  }
}
