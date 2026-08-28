import Commander
import Foundation
import MapCore

struct CommandRouter {
  let rootName = "mapctl"
  let version: String
  let specs: [CommandSpec]
  let program: Program

  init() {
    self.version = CommandRouter.resolveVersion()
    self.specs = [
      SearchCommand.spec,
      GeocodeCommand.spec,
      ReverseCommand.spec,
      DirectionsCommand.spec,
      ETACommand.spec,
      LinkCommand.spec,
      CategoriesCommand.spec,
      DoctorCommand.spec,
      CompletionCommand.spec,
    ]
    let descriptor = CommandDescriptor(
      name: rootName,
      abstract: HelpPrinter.rootAbstract,
      discussion: nil,
      signature: CommandSignature(),
      subcommands: specs.map { $0.descriptor },
      defaultSubcommandName: "search"
    )
    self.program = Program(descriptors: [descriptor])
  }

  /// Command aliases, mapped to their canonical command name.
  static let aliases: [String: String] = [
    "find": "search",
    "poi": "search",
    "geo": "geocode",
    "rev": "reverse",
    "route": "directions",
    "dir": "directions",
    "url": "link",
    "cats": "categories",
  ]

  func run() async -> Int32 {
    return await run(argv: CommandLine.arguments)
  }

  func run(argv: [String]) async -> Int32 {
    var argv = normalizeArguments(argv)
    argv = Self.applyAliases(argv)

    if argv.contains("--version") || argv.contains("-V") {
      Swift.print(version)
      return 0
    }

    if argv.contains("--help") || argv.contains("-h") {
      printHelp(for: argv)
      return 0
    }

    argv = rewriteImplicitSearch(argv)

    do {
      let invocation = try program.resolve(argv: argv)
      guard let commandName = invocation.path.last,
        let spec = specs.first(where: { $0.name == commandName })
      else {
        Console.printError("Unknown command")
        HelpPrinter.printRoot(version: version, rootName: rootName, commands: specs)
        return 1
      }
      let runtime = RuntimeOptions(parsedValues: invocation.parsedValues)
      do {
        try runtime.validate()
        try await spec.run(invocation.parsedValues, runtime)
        return 0
      } catch {
        Console.printError(error.localizedDescription)
        return 1
      }
    } catch let error as CommanderProgramError {
      Console.printError(error.description)
      if case .missingSubcommand = error {
        HelpPrinter.printRoot(version: version, rootName: rootName, commands: specs)
      }
      return 1
    } catch {
      Console.printError(error.localizedDescription)
      return 1
    }
  }

  /// The router matches `argv[0]` against the root descriptor, so a renamed or
  /// path-qualified executable still resolves.
  private func normalizeArguments(_ argv: [String]) -> [String] {
    guard !argv.isEmpty else { return [rootName] }
    var copy = argv
    copy[0] = rootName
    return copy
  }

  static func applyAliases(_ argv: [String]) -> [String] {
    guard argv.count >= 2, let canonical = aliases[argv[1]] else { return argv }
    var copy = argv
    copy[1] = canonical
    return copy
  }

  func rewriteImplicitSearch(_ argv: [String]) -> [String] {
    return Self.rewriteImplicitSearch(argv, commandNames: Set(specs.map { $0.name }))
  }

  /// Any bare word is a valid map query, so unlike calctl's date-filter guard
  /// there is nothing to validate here: a leading non-flag token that is not a
  /// command name becomes a search. A mistyped command therefore searches for
  /// the typo instead of reporting an unknown command.
  static func rewriteImplicitSearch(_ argv: [String], commandNames: Set<String>) -> [String] {
    guard argv.count >= 2 else { return argv }
    let token = argv[1]
    if token.hasPrefix("-") || commandNames.contains(token) {
      return argv
    }
    var copy = argv
    copy.insert("search", at: 1)
    return copy
  }

  private func printHelp(for argv: [String]) {
    let path = helpPath(from: argv)
    if path.count <= 1 {
      HelpPrinter.printRoot(version: version, rootName: rootName, commands: specs)
      return
    }
    if let spec = specs.first(where: { $0.name == path[1] }) {
      HelpPrinter.printCommand(rootName: rootName, spec: spec)
    } else {
      HelpPrinter.printRoot(version: version, rootName: rootName, commands: specs)
    }
  }

  private func helpPath(from argv: [String]) -> [String] {
    var path: [String] = []
    for token in argv {
      if token == "--help" || token == "-h" { continue }
      if token.hasPrefix("-") { break }
      path.append(token)
    }
    return path
  }

  private static func resolveVersion() -> String {
    if let envVersion = ProcessInfo.processInfo.environment["MAPCTL_VERSION"], !envVersion.isEmpty {
      return envVersion
    }
    return MapctlVersion.current
  }
}
