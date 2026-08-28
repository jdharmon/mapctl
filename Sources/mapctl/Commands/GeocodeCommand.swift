import Commander
import Foundation
import MapCore

enum GeocodeCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "geocode",
      abstract: "Turn a street address into coordinates",
      discussion: "Use `search` instead when looking for a business or landmark by name.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "address", help: "The address to look up", isOptional: false)
          ],
          options: CommandSignatures.nearOptions() + [
            CommandSignatures.limitOption(help: "Maximum matches to show")
          ]
        )
      ),
      usageExamples: [
        "mapctl geocode \"1 Apple Park Way, Cupertino CA\"",
        "mapctl geocode \"221B Baker Street\" --json",
      ]
    ) { values, runtime in
      let address = try CommandHelpers.requiredArgument(values, at: 0, name: "address")
      let service = MapService()
      let region = try await CommandHelpers.searchRegion(from: values, service: service)
      let places = try await service.geocode(address: address, region: region)
      guard !places.isEmpty else {
        throw MapCoreError.noResults(address)
      }
      let limited = try CommandHelpers.applyLimit(places, limit: values.option("limit"))
      OutputRenderer.printPlaces(limited, format: runtime.outputFormat)
    }
  }
}
