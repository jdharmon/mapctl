import Commander
import Foundation
import MapCore

enum CommandHelpers {
  static func parsePositiveInt(_ value: String, option: String) throws -> Int {
    guard let parsed = Int(value), parsed > 0 else {
      throw MapCoreError.operationFailed("Invalid value for --\(option): \"\(value)\" (expected a positive number)")
    }
    return parsed
  }

  static func applyLimit<T>(_ items: [T], limit: String?) throws -> [T] {
    guard let limit else { return items }
    let count = try parsePositiveInt(limit, option: "limit")
    return Array(items.prefix(count))
  }

  // MARK: - Regions

  /// Turns `--near`/`--radius` into a bias region. `--near` accepts a `lat,lon`
  /// pair directly; anything else costs one geocode before the real query runs.
  static func searchRegion(from values: ParsedValues, service: MapService) async throws -> SearchRegion? {
    let radius = try values.option("radius").map { try DistanceParsing.requireMeters($0) }
    guard let near = values.option("near"), !near.isEmpty else {
      if radius != nil {
        throw MapCoreError.operationFailed("--radius requires --near.")
      }
      return nil
    }
    let center = try await centerCoordinate(for: near, service: service)
    return SearchRegion(center: center, radiusMeters: radius ?? SearchRegion.defaultRadiusMeters)
  }

  private static func centerCoordinate(for input: String, service: MapService) async throws -> Coordinate {
    if let coordinate = CoordinateParsing.parse(input) {
      return coordinate
    }
    return try await service.resolvePlace(input).coordinate
  }

  // MARK: - Routing

  static func directionsOptions(from values: ParsedValues) throws -> DirectionsOptions {
    let mode = try values.option("mode").map { try TransportMode.require($0) } ?? .driving
    let avoided = avoidances(in: values)
    let options = DirectionsOptions(
      mode: mode,
      departureDate: try values.option("depart").map { try DateParsing.require($0) },
      arrivalDate: try values.option("arrive").map { try DateParsing.require($0) },
      includesAlternates: values.flag("alternates"),
      avoidTolls: avoided.contains("tolls"),
      avoidHighways: avoided.contains("highways"))
    try options.validate()
    return options
  }

  static func avoidances(in values: ParsedValues) -> Set<String> {
    let tokens = values.optionValues("avoid")
      .flatMap { $0.components(separatedBy: ",") }
      .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
      .filter { !$0.isEmpty }
    return Set(tokens)
  }

  static func commaSeparated(_ value: String?) -> [String] {
    guard let value else { return [] }
    return
      value
      .components(separatedBy: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
  }

  static func requiredArgument(_ values: ParsedValues, at index: Int, name: String) throws -> String {
    guard let value = values.argument(index)?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
      throw ParsedValuesError.missingArgument(name)
    }
    return value
  }
}
