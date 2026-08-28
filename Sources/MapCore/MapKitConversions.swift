import Foundation
import MapKit

/// The single translation boundary between MapKit's classes and MapCore's
/// value types. Internal on purpose: no `MK*` type reaches a consumer.
enum MapKitConversions {
  static func coordinate(from coordinate: CLLocationCoordinate2D) -> Coordinate {
    return Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  static func clCoordinate(from coordinate: Coordinate) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  static func region(from region: SearchRegion) -> MKCoordinateRegion {
    return MKCoordinateRegion(
      center: clCoordinate(from: region.center),
      latitudinalMeters: region.radiusMeters * 2,
      longitudinalMeters: region.radiusMeters * 2)
  }

  static func place(from item: MKMapItem) -> Place {
    return Place(
      name: item.name,
      coordinate: coordinate(from: item.location.coordinate),
      fullAddress: item.address?.fullAddress,
      shortAddress: item.address?.shortAddress,
      city: item.addressRepresentations?.cityName,
      region: item.addressRepresentations?.regionName,
      regionCode: item.addressRepresentations?.region?.identifier,
      phoneNumber: item.phoneNumber,
      url: item.url?.absoluteString,
      category: item.pointOfInterestCategory.map(PointOfInterestCategories.name(for:)),
      timeZone: item.timeZone?.identifier)
  }

  /// MapKit names a coordinate-only item "Unknown Location", which reads badly
  /// in output; the coordinate itself is the honest label.
  static func mapItem(from coordinate: Coordinate) -> MKMapItem {
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    let item = MKMapItem(location: location, address: nil)
    item.name = CoordinateParsing.format(coordinate)
    return item
  }

  static func transportType(from mode: TransportMode) -> MKDirectionsTransportType {
    switch mode {
    case .driving:
      return .automobile
    case .walking:
      return .walking
    case .cycling:
      return .cycling
    case .transit:
      return .transit
    case .any:
      return .any
    }
  }

  /// `MKDirectionsTransportType` is an option set, so a route can in principle
  /// report several bits; the first match wins and `any` is the fallback.
  static func mode(from type: MKDirectionsTransportType) -> TransportMode {
    if type.contains(.automobile) { return .driving }
    if type.contains(.walking) { return .walking }
    if type.contains(.cycling) { return .cycling }
    if type.contains(.transit) { return .transit }
    return .any
  }

  static func route(from route: MKRoute, includeSteps: Bool) -> Route {
    return Route(
      name: route.name,
      distanceMeters: route.distance,
      expectedTravelTime: route.expectedTravelTime,
      transportType: mode(from: route.transportType),
      hasTolls: route.hasTolls,
      hasHighways: route.hasHighways,
      advisoryNotices: route.advisoryNotices,
      steps: includeSteps ? route.steps.compactMap(step(from:)) : [])
  }

  /// MapKit emits a final zero-length step with empty instructions to mark the
  /// arrival; it carries no information worth printing.
  private static func step(from step: MKRoute.Step) -> RouteStep? {
    guard !step.instructions.isEmpty else { return nil }
    return RouteStep(instructions: step.instructions, notice: step.notice, distanceMeters: step.distance)
  }

  static func directionsRequest(
    source: MKMapItem,
    destination: MKMapItem,
    options: DirectionsOptions
  ) -> MKDirections.Request {
    let request = MKDirections.Request()
    request.source = source
    request.destination = destination
    request.transportType = transportType(from: options.mode)
    request.requestsAlternateRoutes = options.includesAlternates
    request.departureDate = options.departureDate
    request.arrivalDate = options.arrivalDate
    request.tollPreference = options.avoidTolls ? .avoid : .any
    request.highwayPreference = options.avoidHighways ? .avoid : .any
    return request
  }
}
