import Commander
import Foundation
import MapCore

struct LinkResult: Codable, Sendable, Equatable {
  let kind: String
  let url: String
}

enum LinkCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "link",
      abstract: "Print an Apple Maps URL for a place or a trip",
      discussion: """
        With a query argument this prints a link to a place. With --from and
        --to it prints a directions link instead. The URL format is documented
        by Apple and opens in Maps on Apple platforms and on the web elsewhere.
        """,
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "query", help: "Place name, address, or lat,lon", isOptional: true)
          ],
          options: [
            .make(label: "from", names: [.long("from")], help: "Trip origin", parsing: .singleValue),
            .make(label: "to", names: [.long("to")], help: "Trip destination", parsing: .singleValue),
            .make(
              label: "mode",
              names: [.short("m"), .long("mode")],
              help: "Travel mode for a trip link: driving|walking|transit",
              parsing: .singleValue
            ),
          ],
          flags: [
            .make(label: "resolve", names: [.long("resolve")], help: "Look the place up first for an exact pin")
          ]
        )
      ),
      usageExamples: [
        "mapctl link \"Golden Gate Bridge\"",
        "mapctl link \"Blue Bottle Coffee\" --resolve",
        "mapctl link --from \"SFO\" --to \"Palo Alto\" --mode walking",
      ]
    ) { values, runtime in
      let result = try await resolve(values: values)
      print(result, format: runtime.outputFormat)
    }
  }

  static func resolve(values: ParsedValues) async throws -> LinkResult {
    let from = values.option("from")
    let to = values.option("to")

    if from != nil || to != nil {
      guard let from, let to else {
        throw MapCoreError.operationFailed("A trip link needs both --from and --to.")
      }
      let mode = try values.option("mode").map { try TransportMode.require($0) } ?? .driving
      if mode == .cycling {
        Console.printError("Note: Apple Maps URLs have no cycling mode; linking as driving.")
      }
      return LinkResult(kind: "directions", url: MapLinks.directionsURL(from: from, to: to, mode: mode).absoluteString)
    }

    let query = try CommandHelpers.requiredArgument(values, at: 0, name: "query")
    if let coordinate = CoordinateParsing.parse(query) {
      return LinkResult(kind: "place", url: MapLinks.placeURL(coordinate: coordinate).absoluteString)
    }
    if values.flag("resolve") {
      let place = try await MapService().resolvePlace(query)
      return LinkResult(kind: "place", url: MapLinks.placeURL(for: place).absoluteString)
    }
    return LinkResult(kind: "place", url: MapLinks.placeURL(query: query).absoluteString)
  }

  static func print(_ result: LinkResult, format: OutputFormat) {
    switch format {
    case .json:
      OutputRenderer.printJSON(result)
    case .standard, .table, .plain, .quiet:
      Swift.print(result.url)
    }
  }
}
