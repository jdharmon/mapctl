import Foundation

/// Parses and renders `lat,lon` pairs. Accepts a comma, a slash, or whitespace
/// between the two components so shell quoting stays forgiving.
public enum CoordinateParsing {
  private static let separators = CharacterSet(charactersIn: ",/ \t")

  public static func parse(_ input: String) -> Coordinate? {
    let parts =
      input
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: separators)
      .filter { !$0.isEmpty }
    guard parts.count == 2,
      let latitude = Double(parts[0]),
      let longitude = Double(parts[1]),
      isValid(latitude: latitude, longitude: longitude)
    else {
      return nil
    }
    return Coordinate(latitude: latitude, longitude: longitude)
  }

  public static func require(_ input: String) throws -> Coordinate {
    guard let coordinate = parse(input) else {
      throw MapCoreError.invalidCoordinate(input)
    }
    return coordinate
  }

  public static func isValid(latitude: Double, longitude: Double) -> Bool {
    return (-90...90).contains(latitude) && (-180...180).contains(longitude)
  }

  /// Renders with six decimals, which resolves to roughly 0.1 m and matches the
  /// precision MapKit itself returns.
  public static func format(_ coordinate: Coordinate) -> String {
    return "\(format(coordinate.latitude)),\(format(coordinate.longitude))"
  }

  private static func format(_ value: Double) -> String {
    return String(format: "%.6f", value)
  }
}
