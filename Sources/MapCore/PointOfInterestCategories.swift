import Foundation
import MapKit

/// Maps between MapKit's point-of-interest categories and the lowercase,
/// hyphenated names mapctl accepts on the command line.
///
/// `MKPointOfInterestCategory` is a string-typed constant rather than an enum,
/// so it has no `allCases`; the supported set has to be listed explicitly.
/// Friendly names are derived from each category's raw value so the two
/// directions can never drift apart.
public enum PointOfInterestCategories {
  static let supported: [MKPointOfInterestCategory] = [
    .airport, .amusementPark, .animalService, .aquarium,
    .atm, .automotiveRepair, .bakery, .bank,
    .baseball, .basketball, .beach, .beauty,
    .bowling, .brewery, .cafe, .campground,
    .carRental, .castle, .conventionCenter, .distillery,
    .evCharger, .fairground, .fireStation, .fishing,
    .fitnessCenter, .foodMarket, .fortress, .gasStation,
    .goKart, .golf, .hiking, .hospital,
    .hotel, .kayaking, .landmark, .laundry,
    .library, .mailbox, .marina, .miniGolf,
    .movieTheater, .museum, .musicVenue, .nationalMonument,
    .nationalPark, .nightlife, .park, .parking,
    .pharmacy, .planetarium, .police, .postOffice,
    .publicTransport, .restaurant, .restroom, .rockClimbing,
    .rvPark, .school, .skatePark, .skating,
    .skiing, .soccer, .spa, .stadium,
    .store, .surfing, .swimming, .tennis,
    .theater, .university, .volleyball, .winery,
    .zoo,
  ]

  private static let rawValuePrefix = "MKPOICategory"

  public static let names: [String] = supported.map(name(for:)).sorted()

  /// Turns `MKPOICategoryEVCharger` into `ev-charger`.
  public static func name(for category: MKPointOfInterestCategory) -> String {
    let stripped =
      category.rawValue.hasPrefix(rawValuePrefix)
      ? String(category.rawValue.dropFirst(rawValuePrefix.count))
      : category.rawValue
    return hyphenated(stripped)
  }

  static func category(named name: String) -> MKPointOfInterestCategory? {
    let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return supported.first { Self.name(for: $0) == normalized }
  }

  static func categories(named names: [String]) throws -> [MKPointOfInterestCategory] {
    return try names.map { name in
      guard let category = category(named: name) else {
        throw MapCoreError.invalidCategory(name)
      }
      return category
    }
  }

  /// Splits on case boundaries while keeping acronym runs together, so
  /// `RVPark` becomes `rv-park` rather than `r-v-park`.
  private static func hyphenated(_ value: String) -> String {
    let characters = Array(value)
    var result = ""
    for (index, character) in characters.enumerated() {
      let previousIsLower = index > 0 && characters[index - 1].isLowercase
      let nextIsLower = index + 1 < characters.count && characters[index + 1].isLowercase
      if index > 0, character.isUppercase, previousIsLower || nextIsLower {
        result.append("-")
      }
      result.append(character.lowercased())
    }
    return result
  }
}
