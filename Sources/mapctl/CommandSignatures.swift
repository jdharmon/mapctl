import Commander

enum CommandSignatures {
  static func runtimeOptions() -> [OptionDefinition] {
    [
      .make(
        label: "format",
        names: [.long("format")],
        help: "Output format: standard|table|plain|json|quiet",
        parsing: .singleValue
      )
    ]
  }

  static func runtimeFlags() -> [FlagDefinition] {
    [
      .make(
        label: "jsonOutput",
        names: [.short("j"), .long("json"), .aliasLong("json-output"), .aliasLong("jsonOutput")],
        help: "Emit machine-readable JSON output"
      ),
      .make(
        label: "plainOutput",
        names: [.long("plain")],
        help: "Emit stable line-based output"
      ),
      .make(
        label: "quiet",
        names: [.short("q"), .long("quiet")],
        help: "Only emit minimal output"
      ),
    ]
  }

  /// Options shared by every command that can bias results toward an area.
  static func nearOptions() -> [OptionDefinition] {
    [
      .make(
        label: "near",
        names: [.short("n"), .long("near")],
        help: "Bias results toward a place or lat,lon",
        parsing: .singleValue
      ),
      .make(
        label: "radius",
        names: [.short("r"), .long("radius")],
        help: "Search radius around --near, e.g. 500m, 2km, 1.5mi (default: 10km)",
        parsing: .singleValue
      ),
    ]
  }

  /// Travel options shared by `directions`, `eta`, and `link`.
  static func routeOptions() -> [OptionDefinition] {
    [
      .make(
        label: "mode",
        names: [.short("m"), .long("mode")],
        help: "Travel mode: driving|walking|cycling|transit (default: driving)",
        parsing: .singleValue
      ),
      .make(label: "depart", names: [.long("depart")], help: "Departure time", parsing: .singleValue),
      .make(label: "arrive", names: [.long("arrive")], help: "Desired arrival time", parsing: .singleValue),
    ]
  }

  static func limitOption(help: String = "Maximum results to show") -> OptionDefinition {
    .make(label: "limit", names: [.long("limit")], help: help, parsing: .singleValue)
  }

  static func withRuntimeFlags(_ signature: CommandSignature) -> CommandSignature {
    CommandSignature(
      arguments: signature.arguments,
      options: signature.options + runtimeOptions(),
      flags: signature.flags + runtimeFlags(),
      optionGroups: signature.optionGroups
    )
  }
}
