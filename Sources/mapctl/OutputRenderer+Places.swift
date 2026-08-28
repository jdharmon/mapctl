import Foundation
import MapCore

extension OutputRenderer {
  static func printPlaces(_ places: [Place], format: OutputFormat) {
    switch format {
    case .standard:
      printPlacesStandard(places)
    case .table:
      Swift.print("Index\tName\tLatitude\tLongitude\tCategory\tAddress")
      for (index, place) in places.enumerated() {
        Swift.print("\(index + 1)\t\(placeRow(place))")
      }
    case .plain:
      for place in places {
        Swift.print(placeRow(place))
      }
    case .json:
      printJSON(places)
    case .quiet:
      Swift.print("\(places.count)")
    }
  }

  private static func printPlacesStandard(_ places: [Place]) {
    guard !places.isEmpty else {
      Swift.print("No places found")
      return
    }
    for (index, place) in places.enumerated() {
      Swift.print("[\(index + 1)] \(place.displayName)\(categorySuffix(place))")
      for line in detailLines(for: place) {
        Swift.print("    \(line)")
      }
    }
  }

  private static func categorySuffix(_ place: Place) -> String {
    guard let category = place.category else { return "" }
    return "  (\(category))"
  }

  private static func detailLines(for place: Place) -> [String] {
    var lines: [String] = []
    if let address = place.fullAddress, address != place.displayName {
      lines.append(address)
    }
    lines.append(CoordinateParsing.format(place.coordinate))
    if let phone = place.phoneNumber {
      lines.append(phone)
    }
    if let url = place.url {
      lines.append(url)
    }
    return lines
  }

  static func placeRow(_ place: Place) -> String {
    return [
      sanitize(place.displayName),
      String(place.coordinate.latitude),
      String(place.coordinate.longitude),
      sanitize(place.category),
      sanitize(place.fullAddress),
    ].joined(separator: "\t")
  }
}
