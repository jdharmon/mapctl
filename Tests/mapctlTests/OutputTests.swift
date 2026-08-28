import Foundation
import MapCore
import Testing

@testable import mapctl

@MainActor
struct OutputTests {
  @Test(
    "Explicit format flags outrank --format",
    arguments: [
      (Set(["jsonOutput"]), OutputFormat.json),
      (Set(["plainOutput"]), OutputFormat.plain),
      (Set(["quiet"]), OutputFormat.quiet),
    ])
  func flagPrecedence(flags: Set<String>, expected: OutputFormat) {
    let runtime = RuntimeOptions(parsedValues: Values.make(options: Values.option("format", "table"), flags: flags))
    #expect(runtime.outputFormat == expected)
  }

  @Test(
    "--format selects the named renderer",
    arguments: [
      ("standard", OutputFormat.standard),
      ("text", OutputFormat.standard),
      ("table", OutputFormat.table),
      ("plain", OutputFormat.plain),
      ("json", OutputFormat.json),
      ("quiet", OutputFormat.quiet),
    ])
  func namedFormats(name: String, expected: OutputFormat) throws {
    #expect(try RuntimeOptions.outputFormat(named: name) == expected)
  }

  @Test("No format at all is the standard renderer")
  func defaultFormat() throws {
    #expect(try RuntimeOptions.outputFormat(named: nil) == .standard)
    #expect(RuntimeOptions(parsedValues: Values.make()).outputFormat == .standard)
  }

  @Test("An unknown format fails validation before the command runs")
  func invalidFormat() {
    let runtime = RuntimeOptions(parsedValues: Values.make(options: Values.option("format", "yaml")))
    #expect(throws: MapCoreError.self) { try runtime.validate() }
  }

  @Test("Tabs and newlines are collapsed so table columns cannot break")
  func sanitizing() {
    #expect(OutputRenderer.sanitize("a\tb") == "a b")
    #expect(OutputRenderer.sanitize("a\nb  c") == "a b c")
    #expect(OutputRenderer.sanitize(nil).isEmpty)
    #expect(OutputRenderer.sanitize("  padded  ") == "padded")
  }

  @Test("A place row has one field per table column")
  func placeRowShape() {
    let place = Place(
      name: "Philz\tCoffee",
      coordinate: Coordinate(latitude: 37.5, longitude: -122.0),
      fullAddress: "19439 Stevens Creek Blvd",
      category: "cafe")
    let fields = OutputRenderer.placeRow(place).components(separatedBy: "\t")
    #expect(fields.count == 5)
    #expect(fields[0] == "Philz Coffee")
    #expect(fields[3] == "cafe")
  }

  @Test("A route row has one field per table column")
  func routeRowShape() {
    let route = Route(
      name: "US-101 N",
      distanceMeters: 52_360.4,
      expectedTravelTime: 2_766.2,
      transportType: .driving,
      hasTolls: true,
      hasHighways: true)
    let fields = OutputRenderer.routeRow(route).components(separatedBy: "\t")
    #expect(fields == ["US-101 N", "52360", "2766", "driving", "true", "true"])
  }
}
