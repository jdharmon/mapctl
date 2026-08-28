import Commander
import Foundation
import MapCore

enum SearchCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "search",
      abstract: "Search for places by name or category",
      discussion: """
        Runs an Apple Maps local search. Without --near the search covers the
        whole world, which favours well-known places; pass --near to focus it.
        """,
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "query", help: "What to search for", isOptional: false)
          ],
          options: CommandSignatures.nearOptions() + [
            .make(
              label: "category",
              names: [.short("c"), .long("category")],
              help: "Restrict to categories, e.g. cafe,bakery (see `mapctl categories`)",
              parsing: .singleValue
            ),
            .make(
              label: "types",
              names: [.short("t"), .long("types")],
              help: "Result types: address, poi, or both (default: both)",
              parsing: .singleValue
            ),
            CommandSignatures.limitOption(help: "Maximum places to show"),
          ]
        )
      ),
      usageExamples: [
        "mapctl search \"blue bottle coffee\"",
        "mapctl search coffee --near 37.3349,-122.0090 --radius 2km",
        "mapctl search pharmacy --near Cupertino --category pharmacy --json",
      ]
    ) { values, runtime in
      let query = try CommandHelpers.requiredArgument(values, at: 0, name: "query")
      let service = MapService()
      let region = try await CommandHelpers.searchRegion(from: values, service: service)
      let types = try resultTypes(from: values.option("types"))

      let options = MapSearchOptions(
        region: region,
        categories: CommandHelpers.commaSeparated(values.option("category")),
        includeAddresses: types.contains("address"),
        includePointsOfInterest: types.contains("poi"))
      let places = try await service.search(query: query, options: options)
      let limited = try CommandHelpers.applyLimit(places, limit: values.option("limit"))
      OutputRenderer.printPlaces(limited, format: runtime.outputFormat)
    }
  }

  static func resultTypes(from value: String?) throws -> Set<String> {
    let tokens = CommandHelpers.commaSeparated(value).map { $0.lowercased() }
    guard !tokens.isEmpty else { return ["address", "poi"] }

    var types = Set<String>()
    for token in tokens {
      switch token {
      case "address", "addresses":
        types.insert("address")
      case "poi", "pois", "point-of-interest", "points-of-interest":
        types.insert("poi")
      case "both", "all":
        types.formUnion(["address", "poi"])
      default:
        throw MapCoreError.operationFailed("Invalid value for --types: \"\(token)\" (use address, poi, or both)")
      }
    }
    return types
  }
}
