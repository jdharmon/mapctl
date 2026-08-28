import Foundation

/// Parses distances written the way people type them on a command line.
/// A bare number is metres, matching every MapKit distance API.
public enum DistanceParsing {
  private static let unitsInMeters: [String: Double] = [
    "m": 1,
    "meter": 1,
    "meters": 1,
    "metre": 1,
    "metres": 1,
    "km": 1_000,
    "kilometer": 1_000,
    "kilometers": 1_000,
    "kilometre": 1_000,
    "kilometres": 1_000,
    "mi": 1_609.344,
    "mile": 1_609.344,
    "miles": 1_609.344,
    "ft": 0.3048,
    "foot": 0.3048,
    "feet": 0.3048,
    "yd": 0.9144,
    "yard": 0.9144,
    "yards": 0.9144,
  ]

  public static func parseMeters(_ input: String) -> Double? {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !trimmed.isEmpty else { return nil }

    let digits = trimmed.prefix { $0.isNumber || $0 == "." }
    guard let value = Double(digits), value > 0 else { return nil }

    let unit = trimmed.dropFirst(digits.count).trimmingCharacters(in: .whitespaces)
    if unit.isEmpty { return value }
    guard let multiplier = unitsInMeters[unit] else { return nil }
    return value * multiplier
  }

  public static func requireMeters(_ input: String) throws -> Double {
    guard let meters = parseMeters(input) else {
      throw MapCoreError.invalidDistance(input)
    }
    return meters
  }
}
