import Commander
import Foundation
import MapCore

enum CompletionCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "completion",
      abstract: "Generate shell completion",
      discussion: "Prints a generated completion script.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "shell", help: "zsh|bash", isOptional: true)
          ]
        )
      ),
      usageExamples: [
        "mapctl completion zsh",
        "mapctl completion bash",
      ]
    ) { values, _ in
      switch values.argument(0) ?? "zsh" {
      case "zsh":
        Swift.print(zsh())
      case "bash":
        Swift.print(bash())
      case let shell:
        throw MapCoreError.operationFailed("Unsupported shell: \(shell) (use zsh|bash)")
      }
    }
  }

  static let commands = [
    "search", "geocode", "reverse", "directions", "eta", "link", "categories", "doctor", "completion",
  ]

  static func zsh() -> String {
    """
    #compdef mapctl
    _mapctl() {
      local -a commands
      commands=(\(commands.map { "'\($0):mapctl \($0)'" }.joined(separator: " ")))
      if (( CURRENT == 2 )); then
        _describe 'command' commands
      else
        _arguments '*:argument:_files'
      fi
    }
    _mapctl "$@"
    """
  }

  static func bash() -> String {
    """
    _mapctl_completion() {
      local cur="${COMP_WORDS[COMP_CWORD]}"
      if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "\(commands.joined(separator: " "))" -- "$cur") )
      fi
    }
    complete -F _mapctl_completion mapctl
    """
  }
}
