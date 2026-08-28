import Commander
import Foundation
import MapCore

enum CategoriesCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "categories",
      abstract: "List the point-of-interest categories accepted by --category",
      discussion: nil,
      signature: CommandSignatures.withRuntimeFlags(CommandSignature()),
      usageExamples: [
        "mapctl categories",
        "mapctl categories --json",
      ]
    ) { _, runtime in
      OutputRenderer.printNames(PointOfInterestCategories.names, format: runtime.outputFormat)
    }
  }
}
