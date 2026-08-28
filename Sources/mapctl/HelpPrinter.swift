import Commander
import Foundation

struct HelpPrinter {
  static let rootAbstract = "Search Apple Maps, geocode places, and route trips from the terminal"

  static func printRoot(version: String, rootName: String, commands: [CommandSpec]) {
    for line in renderRoot(version: version, rootName: rootName, commands: commands) {
      Swift.print(line)
    }
  }

  static func printCommand(rootName: String, spec: CommandSpec) {
    for line in renderCommand(rootName: rootName, spec: spec) {
      Swift.print(line)
    }
  }

  static func renderRoot(version: String, rootName: String, commands: [CommandSpec]) -> [String] {
    var lines: [String] = []
    lines.append("\(rootName) \(version)")
    lines.append(rootAbstract)
    lines.append("")
    lines.append("Usage:")
    lines.append("  \(rootName) [command] [options]")
    lines.append("")
    lines.append("Commands:")
    for command in commands {
      lines.append("  \(command.name)\t\(command.abstract)")
    }
    lines.append("")
    lines.append("Run '\(rootName) <command> --help' for details.")
    return lines
  }

  static func renderCommand(rootName: String, spec: CommandSpec) -> [String] {
    var lines: [String] = []
    lines.append("\(rootName) \(spec.name)")
    lines.append(spec.abstract)
    if let discussion = spec.discussion, !discussion.isEmpty {
      lines.append("\n\(discussion)")
    }
    lines.append("")
    lines.append("Usage:")
    lines.append("  \(rootName) \(spec.name) \(usageFragment(for: spec.signature))")
    lines.append("")

    if !spec.signature.arguments.isEmpty {
      lines.append("Arguments:")
      for argument in spec.signature.arguments {
        let optionalMark = argument.isOptional ? "?" : ""
        lines.append("  \(argument.label)\(optionalMark)\t\(argument.help ?? "")")
      }
      lines.append("")
    }

    let options = spec.signature.options
    let flags = spec.signature.flags
    if !options.isEmpty || !flags.isEmpty {
      lines.append("Options:")
      for option in options {
        lines.append("  \(formatNames(option.names, expectsValue: true))\t\(option.help ?? "")")
      }
      for flag in flags {
        lines.append("  \(formatNames(flag.names, expectsValue: false))\t\(flag.help ?? "")")
      }
      lines.append("")
    }

    if !spec.usageExamples.isEmpty {
      lines.append("Examples:")
      for example in spec.usageExamples {
        lines.append("  \(example)")
      }
    }

    return lines
  }

  private static func usageFragment(for signature: CommandSignature) -> String {
    var parts: [String] = []
    for argument in signature.arguments {
      parts.append(argument.isOptional ? "[\(argument.label)]" : "<\(argument.label)>")
    }
    if !signature.options.isEmpty || !signature.flags.isEmpty {
      parts.append("[options]")
    }
    return parts.joined(separator: " ")
  }

  private static func formatNames(_ names: [CommanderName], expectsValue: Bool) -> String {
    let parts = names.map { name -> String in
      switch name {
      case .short(let char), .aliasShort(let char):
        return "-\(char)"
      case .long(let value), .aliasLong(let value):
        return "--\(value)"
      }
    }
    return parts.joined(separator: ", ") + (expectsValue ? " <value>" : "")
  }
}
