import Foundation
import MapKit
import Testing

@testable import MapCore

@MainActor
struct PointOfInterestCategoriesTests {
  @Test("Names are hyphenated, unique, and sorted")
  func nameList() {
    let names = PointOfInterestCategories.names
    #expect(names.count == PointOfInterestCategories.supported.count)
    #expect(Set(names).count == names.count)
    #expect(names == names.sorted())
    #expect(names.allSatisfy { $0 == $0.lowercased() })
    #expect(names.allSatisfy { !$0.isEmpty })
  }

  @Test(
    "Acronym runs stay together when hyphenating",
    arguments: [
      (MKPointOfInterestCategory.cafe, "cafe"),
      (MKPointOfInterestCategory.amusementPark, "amusement-park"),
      (MKPointOfInterestCategory.atm, "atm"),
      (MKPointOfInterestCategory.evCharger, "ev-charger"),
      (MKPointOfInterestCategory.rvPark, "rv-park"),
      (MKPointOfInterestCategory.goKart, "go-kart"),
    ])
  func hyphenation(category: MKPointOfInterestCategory, expected: String) {
    #expect(PointOfInterestCategories.name(for: category) == expected)
  }

  @Test("Lookup by name is case-insensitive and round-trips")
  func lookup() throws {
    for category in PointOfInterestCategories.supported {
      let name = PointOfInterestCategories.name(for: category)
      #expect(PointOfInterestCategories.category(named: name) == category)
      #expect(PointOfInterestCategories.category(named: name.uppercased()) == category)
    }
    #expect(PointOfInterestCategories.category(named: "  Cafe  ") == .cafe)
  }

  @Test("Unknown names are rejected")
  func unknownName() {
    #expect(PointOfInterestCategories.category(named: "teahouse") == nil)
    #expect(throws: MapCoreError.invalidCategory("teahouse")) {
      try PointOfInterestCategories.categories(named: ["cafe", "teahouse"])
    }
  }

  @Test("A list of valid names converts to categories in order")
  func categoryList() throws {
    let categories = try PointOfInterestCategories.categories(named: ["cafe", "bakery"])
    #expect(categories == [.cafe, .bakery])
    #expect(try PointOfInterestCategories.categories(named: []).isEmpty)
  }
}
