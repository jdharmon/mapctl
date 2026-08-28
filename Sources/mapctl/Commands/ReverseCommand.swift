import Commander
import Foundation
import MapCore

enum ReverseCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "reverse",
      abstract: "Turn coordinates into an address",
      discussion: nil,
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "coordinate", help: "Coordinates as lat,lon", isOptional: false)
          ],
          options: [CommandSignatures.limitOption(help: "Maximum matches to show")]
        )
      ),
      usageExamples: [
        "mapctl reverse 37.3349,-122.0090",
        "mapctl reverse 51.5007,-0.1246 --json",
      ]
    ) { values, runtime in
      let input = try CommandHelpers.requiredArgument(values, at: 0, name: "coordinate")
      let coordinate = try CoordinateParsing.require(input)
      let places = try await MapService().reverseGeocode(coordinate: coordinate)
      guard !places.isEmpty else {
        throw MapCoreError.noResults(input)
      }
      let limited = try CommandHelpers.applyLimit(places, limit: values.option("limit"))
      OutputRenderer.printPlaces(limited, format: runtime.outputFormat)
    }
  }
}
