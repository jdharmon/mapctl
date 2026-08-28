import Foundation
import MapKit

public struct MapSearchOptions: Sendable, Equatable {
  public var region: SearchRegion?
  public var categories: [String]
  public var includeAddresses: Bool
  public var includePointsOfInterest: Bool

  public init(
    region: SearchRegion? = nil,
    categories: [String] = [],
    includeAddresses: Bool = true,
    includePointsOfInterest: Bool = true
  ) {
    self.region = region
    self.categories = categories
    self.includeAddresses = includeAddresses
    self.includePointsOfInterest = includePointsOfInterest
  }
}

/// Wraps MapKit's search, geocoding, and directions services.
///
/// A `struct` rather than an actor: every MapKit request is a one-shot object,
/// so unlike `EKEventStore` there is no shared handle to serialize access to.
public struct MapService: Sendable {
  public init() {}

  public func search(query: String, options: MapSearchOptions = MapSearchOptions()) async throws -> [Place] {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    if let region = options.region {
      request.region = MapKitConversions.region(from: region)
      request.regionPriority = .required
    }
    request.resultTypes = try resultTypes(for: options)
    if !options.categories.isEmpty {
      let categories = try PointOfInterestCategories.categories(named: options.categories)
      request.pointOfInterestFilter = MKPointOfInterestFilter(including: categories)
    }

    let response = try await perform { try await MKLocalSearch(request: request).start() }
    return response.mapItems.map(MapKitConversions.place(from:))
  }

  public func geocode(address: String, region: SearchRegion? = nil) async throws -> [Place] {
    guard let request = MKGeocodingRequest(addressString: address) else {
      throw MapCoreError.operationFailed("Could not build a geocoding request for \"\(address)\".")
    }
    if let region {
      request.region = MapKitConversions.region(from: region)
    }
    let items = try await perform { try await request.mapItems }
    return items.map(MapKitConversions.place(from:))
  }

  public func reverseGeocode(coordinate: Coordinate) async throws -> [Place] {
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    guard let request = MKReverseGeocodingRequest(location: location) else {
      throw MapCoreError.invalidCoordinate(CoordinateParsing.format(coordinate))
    }
    let items = try await perform { try await request.mapItems }
    return items.map(MapKitConversions.place(from:))
  }

  /// Turns a user-typed place into a single map item.
  ///
  /// A `lat,lon` pair resolves with no network call at all. Anything else is
  /// tried as an address first, then as a point-of-interest name, because
  /// geocoding rejects queries like "blue bottle coffee" that local search
  /// handles well.
  func resolveMapItem(_ input: String, near region: SearchRegion? = nil) async throws -> MKMapItem {
    if let coordinate = CoordinateParsing.parse(input) {
      return MapKitConversions.mapItem(from: coordinate)
    }

    if let request = MKGeocodingRequest(addressString: input) {
      if let region {
        request.region = MapKitConversions.region(from: region)
      }
      if let match = try? await perform({ try await request.mapItems }).first {
        return match
      }
    }

    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = input
    if let region {
      searchRequest.region = MapKitConversions.region(from: region)
    }
    let response = try await perform { try await MKLocalSearch(request: searchRequest).start() }
    guard let match = response.mapItems.first else {
      throw MapCoreError.noResults(input)
    }
    return match
  }

  public func resolvePlace(_ input: String, near region: SearchRegion? = nil) async throws -> Place {
    return MapKitConversions.place(from: try await resolveMapItem(input, near: region))
  }

  private func resultTypes(for options: MapSearchOptions) throws -> MKLocalSearch.ResultType {
    var types: MKLocalSearch.ResultType = []
    if options.includeAddresses { types.insert(.address) }
    if options.includePointsOfInterest { types.insert(.pointOfInterest) }
    guard !types.isEmpty else {
      throw MapCoreError.operationFailed("--types must include at least one of: address, poi.")
    }
    return types
  }

  /// Every MapKit call funnels through here so failures surface as
  /// `MapCoreError` with remediation text rather than as a raw `NSError`.
  func perform<T>(_ work: () async throws -> T) async throws -> T {
    do {
      return try await work()
    } catch {
      throw MapCoreError(mapKitError: error)
    }
  }
}
