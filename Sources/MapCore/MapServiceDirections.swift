import Foundation
import MapKit

extension MapService {
  public func directions(
    from source: String,
    to destination: String,
    options: DirectionsOptions,
    includeSteps: Bool = true
  ) async throws -> DirectionsResult {
    try options.validateForRoutes()

    let (sourceItem, destinationItem) = try await endpoints(from: source, to: destination)
    let request = MapKitConversions.directionsRequest(
      source: sourceItem, destination: destinationItem, options: options)
    let response = try await perform { try await MKDirections(request: request).calculate() }

    guard !response.routes.isEmpty else {
      throw MapCoreError.unsupported("No route is available between those two places for that travel mode.")
    }
    return DirectionsResult(
      source: MapKitConversions.place(from: response.source),
      destination: MapKitConversions.place(from: response.destination),
      routes: response.routes.map { MapKitConversions.route(from: $0, includeSteps: includeSteps) })
  }

  public func eta(from source: String, to destination: String, options: DirectionsOptions) async throws -> ETAResult {
    try options.validate()

    let (sourceItem, destinationItem) = try await endpoints(from: source, to: destination)
    let request = MapKitConversions.directionsRequest(
      source: sourceItem, destination: destinationItem, options: options)
    let response = try await perform { try await MKDirections(request: request).calculateETA() }

    return ETAResult(
      source: MapKitConversions.place(from: response.source),
      destination: MapKitConversions.place(from: response.destination),
      distanceMeters: response.distance,
      expectedTravelTime: response.expectedTravelTime,
      expectedDepartureDate: response.expectedDepartureDate,
      expectedArrivalDate: response.expectedArrivalDate,
      transportType: MapKitConversions.mode(from: response.transportType))
  }

  private func endpoints(from source: String, to destination: String) async throws -> (MKMapItem, MKMapItem) {
    let sourceItem = try await resolveMapItem(source)
    let destinationItem = try await resolveMapItem(destination)
    return (sourceItem, destinationItem)
  }
}
