import Foundation

/// Builds `maps.apple.com` URLs. Unlike the private `ical://` scheme calctl
/// uses, this URL format is documented by Apple and safe to depend on.
public enum MapLinks {
  private static let base = URL(string: "https://maps.apple.com/")!

  public static func placeURL(query: String? = nil, coordinate: Coordinate? = nil) -> URL {
    var items: [URLQueryItem] = []
    if let query, !query.isEmpty {
      items.append(URLQueryItem(name: "q", value: query))
    }
    if let coordinate {
      items.append(URLQueryItem(name: "ll", value: CoordinateParsing.format(coordinate)))
    }
    return url(with: items)
  }

  public static func placeURL(for place: Place) -> URL {
    return placeURL(query: place.displayName, coordinate: place.coordinate)
  }

  public static func directionsURL(from source: String, to destination: String, mode: TransportMode) -> URL {
    return url(with: [
      URLQueryItem(name: "saddr", value: source),
      URLQueryItem(name: "daddr", value: destination),
      URLQueryItem(name: "dirflg", value: directionsFlag(for: mode)),
    ])
  }

  /// The `dirflg` parameter has no cycling value, so cycling falls back to
  /// driving. Callers warn when that substitution happens.
  public static func directionsFlag(for mode: TransportMode) -> String {
    switch mode {
    case .walking:
      return "w"
    case .transit:
      return "r"
    case .driving, .cycling, .any:
      return "d"
    }
  }

  private static func url(with items: [URLQueryItem]) -> URL {
    guard var components = URLComponents(url: base, resolvingAgainstBaseURL: false) else {
      return base
    }
    components.queryItems = items.isEmpty ? nil : items
    return components.url ?? base
  }
}
