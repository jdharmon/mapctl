import Foundation

public enum MeasurementSystem: String, Codable, CaseIterable, Sendable {
  case metric
  case imperial

  /// Resolves from a locale so output matches the rest of the system, while
  /// staying injectable for deterministic tests.
  public static func current(locale: Locale = .current) -> MeasurementSystem {
    return locale.measurementSystem == .metric ? .metric : .imperial
  }
}

public enum DistanceFormatting {
  /// Renders a distance the way a maps app would: coarse units once the number
  /// gets large, fine units when it is small enough to walk.
  public static func distance(meters: Double, system: MeasurementSystem) -> String {
    switch system {
    case .metric:
      if meters < 1_000 { return "\(Int(meters.rounded())) m" }
      return "\(decimal(meters / 1_000)) km"
    case .imperial:
      let feet = meters / 0.3048
      if feet < 1_000 { return "\(Int(feet.rounded())) ft" }
      return "\(decimal(meters / 1_609.344)) mi"
    }
  }

  /// Renders a travel time as `45 s`, `12 min`, or `2 hr 5 min`.
  public static func duration(seconds: TimeInterval) -> String {
    let total = Int(seconds.rounded())
    if total < 60 { return "\(total) s" }

    let minutes = (total + 30) / 60
    if minutes < 60 { return "\(minutes) min" }

    let hours = minutes / 60
    let remainder = minutes % 60
    return remainder == 0 ? "\(hours) hr" : "\(hours) hr \(remainder) min"
  }

  private static func decimal(_ value: Double) -> String {
    return String(format: value < 10 ? "%.1f" : "%.0f", value)
  }
}
