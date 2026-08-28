import Foundation

extension TransportMode {
  private static let synonyms: [String: TransportMode] = [
    "driving": .driving, "drive": .driving, "car": .driving, "automobile": .driving, "d": .driving,
    "walking": .walking, "walk": .walking, "foot": .walking, "w": .walking,
    "cycling": .cycling, "cycle": .cycling, "bike": .cycling, "biking": .cycling, "bicycle": .cycling,
    "transit": .transit, "public": .transit, "bus": .transit, "train": .transit, "r": .transit,
    "any": .any,
  ]

  public static func parse(_ input: String) -> TransportMode? {
    return synonyms[input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()]
  }

  public static func require(_ input: String) throws -> TransportMode {
    guard let mode = parse(input) else {
      throw MapCoreError.invalidTransportMode(input)
    }
    return mode
  }

  /// MapKit returns turn-by-turn routes for everything except transit, which it
  /// only ever answers with an ETA. See `MKDirectionsTransportType` in the SDK.
  public var supportsRoutes: Bool {
    return self != .transit
  }
}
