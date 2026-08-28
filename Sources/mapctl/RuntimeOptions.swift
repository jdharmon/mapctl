import Commander
import MapCore

struct RuntimeOptions: Sendable {
  let jsonOutput: Bool
  let plainOutput: Bool
  let quiet: Bool
  let format: String?

  init(parsedValues: ParsedValues) {
    self.jsonOutput = parsedValues.flags.contains("jsonOutput")
    self.plainOutput = parsedValues.flags.contains("plainOutput")
    self.quiet = parsedValues.flags.contains("quiet")
    self.format = parsedValues.options["format"]?.last?.lowercased()
  }

  var outputFormat: OutputFormat {
    if jsonOutput { return .json }
    if plainOutput { return .plain }
    if quiet { return .quiet }
    return (try? Self.outputFormat(named: format)) ?? .standard
  }

  func validate() throws {
    _ = try Self.outputFormat(named: format)
  }

  static func outputFormat(named format: String?) throws -> OutputFormat {
    switch format {
    case "json":
      return .json
    case "plain":
      return .plain
    case "quiet":
      return .quiet
    case "table":
      return .table
    case "standard", "text", nil:
      return .standard
    default:
      throw MapCoreError.operationFailed(
        "Invalid output format: \"\(format ?? "")\" (use standard|table|plain|json|quiet)")
    }
  }
}
