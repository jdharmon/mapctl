import Commander
import Foundation
import MapCore

enum ETACommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "eta",
      abstract: "Estimate travel time between two places",
      discussion: "Unlike `directions`, this supports --mode transit.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "from", help: "Starting place", isOptional: false),
            .make(label: "to", help: "Destination place", isOptional: false),
          ],
          options: CommandSignatures.routeOptions()
        )
      ),
      usageExamples: [
        "mapctl eta \"San Francisco\" \"Palo Alto\"",
        "mapctl eta home work --mode transit",
        "mapctl eta home work --arrive 2026-09-01T09:00 --quiet",
      ]
    ) { values, runtime in
      let from = try CommandHelpers.requiredArgument(values, at: 0, name: "from")
      let to = try CommandHelpers.requiredArgument(values, at: 1, name: "to")
      let options = try CommandHelpers.directionsOptions(from: values)

      let result = try await MapService().eta(from: from, to: to, options: options)
      OutputRenderer.printETA(result, format: runtime.outputFormat, system: MeasurementSystem.current())
    }
  }
}
