import Foundation
import MapKit
import Testing

@testable import MapCore

@MainActor
struct ErrorsTests {
  @Test("Every error case has a non-empty description")
  func descriptions() {
    let errors: [MapCoreError] = [
      .noResults("nowhere"),
      .invalidCoordinate("91,0"),
      .invalidDistance("5 parsecs"),
      .invalidCategory("teahouse"),
      .invalidTransportMode("teleport"),
      .invalidDate("tomorrow"),
      .networkUnavailable,
      .throttled,
      .unsupported("not supported"),
      .serviceFailed("boom"),
      .operationFailed("boom"),
    ]
    for error in errors {
      #expect(error.errorDescription?.isEmpty == false)
    }
  }

  @Test("Errors that a user can act on say what to do about it")
  func guidance() {
    #expect(MapCoreError.networkUnavailable.errorDescription?.contains("network connection") == true)
    #expect(MapCoreError.throttled.errorDescription?.contains("Wait a few seconds") == true)
    #expect(MapCoreError.invalidCategory("x").errorDescription?.contains("mapctl categories") == true)
    #expect(MapCoreError.invalidDistance("x").errorDescription?.contains("2km") == true)
  }

  @Test("Errors compare by value")
  func equality() {
    #expect(MapCoreError.noResults("A") == MapCoreError.noResults("A"))
    #expect(MapCoreError.noResults("A") != MapCoreError.noResults("B"))
    #expect(MapCoreError.throttled == MapCoreError.throttled)
    #expect(MapCoreError.throttled != MapCoreError.networkUnavailable)
  }

  @Test(
    "MapKit error codes map onto actionable cases",
    arguments: [
      (MKError.Code.loadingThrottled, MapCoreError.throttled),
      (MKError.Code.serverFailure, MapCoreError.networkUnavailable),
      (MKError.Code.directionsNotFound, MapCoreError.unsupported("")),
      (MKError.Code.placemarkNotFound, MapCoreError.noResults("")),
      (MKError.Code.unknown, MapCoreError.serviceFailed("")),
      (MKError.Code.decodingFailed, MapCoreError.serviceFailed("")),
    ])
  func mapKitCodes(code: MKError.Code, expected: MapCoreError) {
    let error = NSError(domain: MKErrorDomain, code: Int(code.rawValue))
    #expect(sameCase(MapCoreError(mapKitError: error), expected))
  }

  @Test("URL errors are reported as a missing network rather than a raw NSError")
  func urlErrors() {
    let offline = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
    #expect(MapCoreError(mapKitError: offline) == .networkUnavailable)
  }

  @Test("Unrecognized domains fall back to the service-failure case")
  func unknownDomain() {
    let error = NSError(domain: "com.example.other", code: 42, userInfo: [NSLocalizedDescriptionKey: "boom"])
    #expect(MapCoreError(mapKitError: error) == .serviceFailed("boom"))
  }

  /// The message inside a mapped error comes from `NSError`, so these
  /// comparisons only assert which case was selected.
  private func sameCase(_ lhs: MapCoreError, _ rhs: MapCoreError) -> Bool {
    switch (lhs, rhs) {
    case (.throttled, .throttled), (.networkUnavailable, .networkUnavailable):
      return true
    case (.unsupported, .unsupported), (.noResults, .noResults), (.serviceFailed, .serviceFailed):
      return true
    default:
      return false
    }
  }
}
