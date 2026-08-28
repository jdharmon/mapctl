import Foundation
import Testing

@testable import MapCore

@MainActor
struct DistanceFormattingTests {
  @Test(
    "Metric distances switch from metres to kilometres at 1 km",
    arguments: [
      (80.0, "80 m"),
      (999.0, "999 m"),
      (1_000.0, "1.0 km"),
      (2_414.0, "2.4 km"),
      (52_360.0, "52 km"),
    ])
  func metric(meters: Double, expected: String) {
    #expect(DistanceFormatting.distance(meters: meters, system: .metric) == expected)
  }

  @Test(
    "Imperial distances switch from feet to miles at 1000 ft",
    arguments: [
      (24.0, "79 ft"),
      (304.0, "997 ft"),
      (500.0, "0.3 mi"),
      (2_414.016, "1.5 mi"),
      (52_360.0, "33 mi"),
    ])
  func imperial(meters: Double, expected: String) {
    #expect(DistanceFormatting.distance(meters: meters, system: .imperial) == expected)
  }

  @Test(
    "Durations render in the largest sensible unit",
    arguments: [
      (0.0, "0 s"),
      (45.0, "45 s"),
      (59.0, "59 s"),
      (60.0, "1 min"),
      (2_766.0, "46 min"),
      (3_600.0, "1 hr"),
      (4_800.0, "1 hr 20 min"),
      (7_500.0, "2 hr 5 min"),
    ])
  func durations(seconds: TimeInterval, expected: String) {
    #expect(DistanceFormatting.duration(seconds: seconds) == expected)
  }

  @Test("The measurement system follows the locale")
  func systemFromLocale() {
    #expect(MeasurementSystem.current(locale: Locale(identifier: "en_US")) == .imperial)
    #expect(MeasurementSystem.current(locale: Locale(identifier: "de_DE")) == .metric)
    #expect(MeasurementSystem.current(locale: Locale(identifier: "fr_FR")) == .metric)
  }
}
