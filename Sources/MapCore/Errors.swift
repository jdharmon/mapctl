import Foundation
import MapKit

public enum MapCoreError: LocalizedError, Sendable, Equatable {
  case noResults(String)
  case invalidCoordinate(String)
  case invalidDistance(String)
  case invalidCategory(String)
  case invalidTransportMode(String)
  case invalidDate(String)
  case networkUnavailable
  case throttled
  case unsupported(String)
  case serviceFailed(String)
  case operationFailed(String)

  public var errorDescription: String? {
    switch self {
    case .noResults(let query):
      return "No places found for \"\(query)\"."
    case .invalidCoordinate(let input):
      return [
        "Invalid coordinate: \"\(input)\"",
        "(use lat,lon with latitude in -90...90 and longitude in -180...180, e.g. 37.3349,-122.0090).",
      ].joined(separator: " ")
    case .invalidDistance(let input):
      return "Invalid distance: \"\(input)\" (use 500, 500m, 2km, 1.5mi, or 3000ft)."
    case .invalidCategory(let input):
      return "Unknown category: \"\(input)\". Run `mapctl categories` to list the supported values."
    case .invalidTransportMode(let input):
      return "Invalid travel mode: \"\(input)\" (use driving, walking, cycling, or transit)."
    case .invalidDate(let input):
      return "Invalid date: \"\(input)\" (use an ISO-8601 timestamp such as 2026-08-28T17:00:00Z)."
    case .networkUnavailable:
      return [
        "Could not reach Apple's map services.",
        "MapKit has no offline mode, so every mapctl lookup needs a working network connection.",
      ].joined(separator: " ")
    case .throttled:
      return [
        "Apple's map services are throttling this machine.",
        "Wait a few seconds and try again; batching many lookups back to back triggers this.",
      ].joined(separator: " ")
    case .unsupported(let message):
      return message
    case .serviceFailed(let message):
      return message
    case .operationFailed(let message):
      return message
    }
  }
}

extension MapCoreError {
  /// Translates the errors MapKit surfaces into `MapCoreError`, so callers see
  /// remediation text instead of a raw `NSError` description.
  public init(mapKitError error: Error) {
    let nsError = error as NSError
    switch nsError.domain {
    case MKErrorDomain:
      self = Self.fromMapKitCode(nsError.code, message: nsError.localizedDescription)
    case NSURLErrorDomain:
      self = .networkUnavailable
    default:
      self = .serviceFailed(nsError.localizedDescription)
    }
  }

  private static func fromMapKitCode(_ code: Int, message: String) -> MapCoreError {
    switch MKError.Code(rawValue: UInt(code)) {
    case .loadingThrottled:
      return .throttled
    case .serverFailure:
      return .networkUnavailable
    case .placemarkNotFound:
      return .noResults(message)
    case .directionsNotFound:
      return .unsupported("No route is available between those two places for that travel mode.")
    default:
      return .serviceFailed(message)
    }
  }
}
