import Foundation
import Testing

@testable import mapctl

@MainActor
struct HelpPrinterTests {
  @Test("Root help lists the version and every registered command")
  func rootHelp() {
    let router = CommandRouter()
    let lines = HelpPrinter.renderRoot(version: "1.2.3", rootName: "mapctl", commands: router.specs)
    let text = lines.joined(separator: "\n")

    #expect(lines.first == "mapctl 1.2.3")
    for spec in router.specs {
      #expect(text.contains(spec.name))
      #expect(text.contains(spec.abstract))
    }
  }

  @Test("Command help renders the usage line, arguments, options, and examples")
  func commandHelp() {
    let lines = HelpPrinter.renderCommand(rootName: "mapctl", spec: DirectionsCommand.spec)
    let text = lines.joined(separator: "\n")

    #expect(text.contains("mapctl directions <from> <to> [options]"))
    #expect(text.contains("--mode"))
    #expect(text.contains("--json"))
    #expect(text.contains("Examples:"))
  }

  @Test("Optional arguments render in brackets rather than angle brackets")
  func optionalArguments() {
    let text = HelpPrinter.renderCommand(rootName: "mapctl", spec: LinkCommand.spec).joined(separator: "\n")
    #expect(text.contains("mapctl link [query] [options]"))
  }

  @Test("A command with no arguments still renders a usage line")
  func noArguments() {
    let text = HelpPrinter.renderCommand(rootName: "mapctl", spec: CategoriesCommand.spec).joined(separator: "\n")
    #expect(text.contains("mapctl categories [options]"))
  }

  @Test("Every command carries an abstract and at least one example")
  func specMetadata() {
    for spec in CommandRouter().specs {
      #expect(!spec.abstract.isEmpty)
      #expect(!spec.usageExamples.isEmpty)
      #expect(spec.usageExamples.allSatisfy { $0.hasPrefix("mapctl ") })
    }
  }
}
