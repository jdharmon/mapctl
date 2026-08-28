import Foundation

@testable import MapCore

/// Fixed values so tests never depend on the host locale or clock.
enum Fixture {
  static let appleParkCoordinate = Coordinate(latitude: 37.334859, longitude: -122.009040)
  static let sfoCoordinate = Coordinate(latitude: 37.6213, longitude: -122.3790)

  static var utc: TimeZone {
    TimeZone(identifier: "UTC")!
  }

  static func date(_ iso: String) -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    guard let parsed = formatter.date(from: iso) else {
      fatalError("Invalid fixture date: \(iso)")
    }
    return parsed
  }

  static func place(
    name: String? = "Apple Park",
    coordinate: Coordinate = appleParkCoordinate,
    fullAddress: String? = "1 Apple Park Way, Cupertino, CA 95014, United States",
    shortAddress: String? = "1 Apple Park Way, Cupertino",
    category: String? = "landmark"
  ) -> Place {
    Place(
      name: name,
      coordinate: coordinate,
      fullAddress: fullAddress,
      shortAddress: shortAddress,
      city: "Cupertino",
      region: "United States",
      regionCode: "US",
      phoneNumber: "+1 (408) 996-1010",
      url: "https://www.apple.com",
      category: category,
      timeZone: "America/Los_Angeles")
  }

  static func route(
    name: String = "US-101 N",
    distanceMeters: Double = 52_360,
    expectedTravelTime: TimeInterval = 2_766,
    steps: [RouteStep] = [RouteStep(instructions: "Turn right onto Pruneridge Ave", distanceMeters: 24)]
  ) -> Route {
    Route(
      name: name,
      distanceMeters: distanceMeters,
      expectedTravelTime: expectedTravelTime,
      transportType: .driving,
      hasTolls: false,
      hasHighways: true,
      advisoryNotices: [],
      steps: steps)
  }
}
