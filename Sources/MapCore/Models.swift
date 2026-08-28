import Foundation

// MARK: - Geometry

public struct Coordinate: Codable, Sendable, Equatable, Hashable {
  public let latitude: Double
  public let longitude: Double

  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

/// A circular area used to bias a search or geocode toward one part of the world.
public struct SearchRegion: Codable, Sendable, Equatable {
  public static let defaultRadiusMeters: Double = 10_000

  public let center: Coordinate
  public let radiusMeters: Double

  public init(center: Coordinate, radiusMeters: Double = SearchRegion.defaultRadiusMeters) {
    self.center = center
    self.radiusMeters = radiusMeters
  }
}

// MARK: - Places

public struct Place: Codable, Sendable, Equatable {
  public let name: String?
  public let coordinate: Coordinate
  public let fullAddress: String?
  public let shortAddress: String?
  public let city: String?
  public let region: String?
  public let regionCode: String?
  public let phoneNumber: String?
  public let url: String?
  public let category: String?
  public let timeZone: String?

  public init(
    name: String? = nil,
    coordinate: Coordinate,
    fullAddress: String? = nil,
    shortAddress: String? = nil,
    city: String? = nil,
    region: String? = nil,
    regionCode: String? = nil,
    phoneNumber: String? = nil,
    url: String? = nil,
    category: String? = nil,
    timeZone: String? = nil
  ) {
    self.name = name
    self.coordinate = coordinate
    self.fullAddress = fullAddress
    self.shortAddress = shortAddress
    self.city = city
    self.region = region
    self.regionCode = regionCode
    self.phoneNumber = phoneNumber
    self.url = url
    self.category = category
    self.timeZone = timeZone
  }

  /// The best available human label, falling back through address forms to the
  /// raw coordinate so a place always renders as something.
  public var displayName: String {
    if let name, !name.isEmpty { return name }
    if let shortAddress, !shortAddress.isEmpty { return shortAddress }
    if let fullAddress, !fullAddress.isEmpty { return fullAddress }
    return CoordinateParsing.format(coordinate)
  }
}

// MARK: - Routing

public enum TransportMode: String, Codable, CaseIterable, Sendable {
  case driving
  case walking
  case cycling
  case transit
  case any
}

public struct RouteStep: Codable, Sendable, Equatable {
  public let instructions: String
  public let notice: String?
  public let distanceMeters: Double

  public init(instructions: String, notice: String? = nil, distanceMeters: Double) {
    self.instructions = instructions
    self.notice = notice
    self.distanceMeters = distanceMeters
  }
}

public struct Route: Codable, Sendable, Equatable {
  public let name: String
  public let distanceMeters: Double
  public let expectedTravelTime: TimeInterval
  public let transportType: TransportMode
  public let hasTolls: Bool
  public let hasHighways: Bool
  public let advisoryNotices: [String]
  public let steps: [RouteStep]

  public init(
    name: String,
    distanceMeters: Double,
    expectedTravelTime: TimeInterval,
    transportType: TransportMode,
    hasTolls: Bool = false,
    hasHighways: Bool = false,
    advisoryNotices: [String] = [],
    steps: [RouteStep] = []
  ) {
    self.name = name
    self.distanceMeters = distanceMeters
    self.expectedTravelTime = expectedTravelTime
    self.transportType = transportType
    self.hasTolls = hasTolls
    self.hasHighways = hasHighways
    self.advisoryNotices = advisoryNotices
    self.steps = steps
  }
}

public struct DirectionsResult: Codable, Sendable, Equatable {
  public let source: Place
  public let destination: Place
  public let routes: [Route]

  public init(source: Place, destination: Place, routes: [Route]) {
    self.source = source
    self.destination = destination
    self.routes = routes
  }
}

public struct ETAResult: Codable, Sendable, Equatable {
  public let source: Place
  public let destination: Place
  public let distanceMeters: Double
  public let expectedTravelTime: TimeInterval
  public let expectedDepartureDate: Date
  public let expectedArrivalDate: Date
  public let transportType: TransportMode

  public init(
    source: Place,
    destination: Place,
    distanceMeters: Double,
    expectedTravelTime: TimeInterval,
    expectedDepartureDate: Date,
    expectedArrivalDate: Date,
    transportType: TransportMode
  ) {
    self.source = source
    self.destination = destination
    self.distanceMeters = distanceMeters
    self.expectedTravelTime = expectedTravelTime
    self.expectedDepartureDate = expectedDepartureDate
    self.expectedArrivalDate = expectedArrivalDate
    self.transportType = transportType
  }
}
