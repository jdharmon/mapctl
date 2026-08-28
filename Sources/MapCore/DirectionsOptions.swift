import Foundation

public struct DirectionsOptions: Sendable, Equatable {
  public var mode: TransportMode
  public var departureDate: Date?
  public var arrivalDate: Date?
  public var includesAlternates: Bool
  public var avoidTolls: Bool
  public var avoidHighways: Bool

  public init(
    mode: TransportMode = .driving,
    departureDate: Date? = nil,
    arrivalDate: Date? = nil,
    includesAlternates: Bool = false,
    avoidTolls: Bool = false,
    avoidHighways: Bool = false
  ) {
    self.mode = mode
    self.departureDate = departureDate
    self.arrivalDate = arrivalDate
    self.includesAlternates = includesAlternates
    self.avoidTolls = avoidTolls
    self.avoidHighways = avoidHighways
  }

  public func validate() throws {
    if departureDate != nil, arrivalDate != nil {
      throw MapCoreError.operationFailed("Specify only one of --depart and --arrive.")
    }
  }

  /// MapKit answers transit requests with an ETA only, never with turn-by-turn
  /// steps, so `directions --mode transit` has to be refused up front.
  public func validateForRoutes() throws {
    try validate()
    guard mode.supportsRoutes else {
      throw MapCoreError.unsupported(
        "MapKit does not return transit routes. Use `mapctl eta` for a transit travel time, "
          + "or `mapctl link` to open the trip in Maps.")
    }
  }
}
