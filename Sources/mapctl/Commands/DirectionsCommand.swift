import Commander
import Foundation
import MapCore

enum DirectionsCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "directions",
      abstract: "Calculate a route between two places",
      discussion: """
        Each endpoint may be an address, a place name, or a lat,lon pair.
        MapKit does not return transit routes; use `mapctl eta --mode transit`
        for a transit travel time.
        """,
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "from", help: "Starting place", isOptional: false),
            .make(label: "to", help: "Destination place", isOptional: false),
          ],
          options: CommandSignatures.routeOptions() + [
            .make(
              label: "avoid",
              names: [.long("avoid")],
              help: "Avoid tolls and/or highways, e.g. --avoid tolls,highways",
              parsing: .singleValue
            )
          ],
          flags: [
            .make(label: "alternates", names: [.long("alternates")], help: "Request alternate routes"),
            .make(label: "noSteps", names: [.long("no-steps")], help: "Omit turn-by-turn steps"),
          ]
        )
      ),
      usageExamples: [
        "mapctl directions \"San Francisco\" \"Palo Alto\"",
        "mapctl directions 37.3349,-122.0090 \"SFO\" --mode driving --alternates",
        "mapctl directions home work --avoid tolls --json",
      ]
    ) { values, runtime in
      let from = try CommandHelpers.requiredArgument(values, at: 0, name: "from")
      let to = try CommandHelpers.requiredArgument(values, at: 1, name: "to")
      let options = try CommandHelpers.directionsOptions(from: values)

      let result = try await MapService().directions(
        from: from, to: to, options: options, includeSteps: !values.flag("noSteps"))
      OutputRenderer.printDirections(
        result, format: runtime.outputFormat, system: MeasurementSystem.current())
    }
  }
}
