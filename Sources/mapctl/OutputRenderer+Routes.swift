import Foundation
import MapCore

extension OutputRenderer {
  static func printDirections(_ result: DirectionsResult, format: OutputFormat, system: MeasurementSystem) {
    switch format {
    case .standard:
      printDirectionsStandard(result, system: system)
    case .table:
      Swift.print("Index\tName\tMeters\tSeconds\tMode\tTolls\tHighways")
      for (index, route) in result.routes.enumerated() {
        Swift.print("\(index + 1)\t\(routeRow(route))")
      }
    case .plain:
      for route in result.routes {
        Swift.print(routeRow(route))
      }
    case .json:
      printJSON(result)
    case .quiet:
      Swift.print("\(Int(result.routes.first?.expectedTravelTime.rounded() ?? 0))")
    }
  }

  private static func printDirectionsStandard(_ result: DirectionsResult, system: MeasurementSystem) {
    Swift.print("From: \(result.source.displayName)")
    Swift.print("To:   \(result.destination.displayName)")
    for (index, route) in result.routes.enumerated() {
      Swift.print("")
      Swift.print("[\(index + 1)] \(route.name)\(summary(for: route, system: system))")
      for notice in route.advisoryNotices {
        Swift.print("    ! \(notice)")
      }
      for (stepIndex, step) in route.steps.enumerated() {
        let distance = DistanceFormatting.distance(meters: step.distanceMeters, system: system)
        Swift.print("    \(stepIndex + 1). \(step.instructions) (\(distance))")
        if let notice = step.notice {
          Swift.print("       ! \(notice)")
        }
      }
    }
  }

  private static func summary(for route: Route, system: MeasurementSystem) -> String {
    var parts = [
      DistanceFormatting.distance(meters: route.distanceMeters, system: system),
      DistanceFormatting.duration(seconds: route.expectedTravelTime),
    ]
    if route.hasTolls { parts.append("tolls") }
    return " — " + parts.joined(separator: ", ")
  }

  static func routeRow(_ route: Route) -> String {
    return [
      sanitize(route.name),
      String(Int(route.distanceMeters.rounded())),
      String(Int(route.expectedTravelTime.rounded())),
      route.transportType.rawValue,
      String(route.hasTolls),
      String(route.hasHighways),
    ].joined(separator: "\t")
  }

  static func printETA(_ result: ETAResult, format: OutputFormat, system: MeasurementSystem) {
    switch format {
    case .standard, .table:
      let distance = DistanceFormatting.distance(meters: result.distanceMeters, system: system)
      let duration = DistanceFormatting.duration(seconds: result.expectedTravelTime)
      Swift.print("From: \(result.source.displayName)")
      Swift.print("To:   \(result.destination.displayName)")
      Swift.print("\(duration) (\(distance)) by \(result.transportType.rawValue)")
      Swift.print("Depart \(time(result.expectedDepartureDate)) — arrive \(time(result.expectedArrivalDate))")
    case .plain:
      Swift.print(etaRow(result))
    case .json:
      printJSON(result)
    case .quiet:
      Swift.print("\(Int(result.expectedTravelTime.rounded()))")
    }
  }

  static func etaRow(_ result: ETAResult) -> String {
    let formatter = ISO8601DateFormatter()
    return [
      String(Int(result.distanceMeters.rounded())),
      String(Int(result.expectedTravelTime.rounded())),
      result.transportType.rawValue,
      formatter.string(from: result.expectedDepartureDate),
      formatter.string(from: result.expectedArrivalDate),
    ].joined(separator: "\t")
  }

  private static func time(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
