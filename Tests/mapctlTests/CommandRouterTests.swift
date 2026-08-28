import Foundation
import Testing

@testable import mapctl

@MainActor
struct CommandRouterTests {
  private let commandNames: Set<String> = [
    "search", "geocode", "reverse", "directions", "eta", "link", "categories", "doctor", "completion",
  ]

  @Test("The router registers every command exactly once")
  func specRegistration() {
    let router = CommandRouter()
    #expect(Set(router.specs.map(\.name)) == commandNames)
    #expect(router.specs.count == commandNames.count)
  }

  @Test("Every alias points at a real command and shadows none")
  func aliasTargetsExist() {
    #expect(Set(CommandRouter.aliases.values).isSubset(of: commandNames))
    #expect(Set(CommandRouter.aliases.keys).isDisjoint(with: commandNames))
  }

  @Test("Completion scripts list the registered commands")
  func completionCoverage() {
    #expect(Set(CompletionCommand.commands) == commandNames)
  }

  @Test(
    "Aliases rewrite the subcommand token",
    arguments: [
      ("find", "search"),
      ("poi", "search"),
      ("geo", "geocode"),
      ("rev", "reverse"),
      ("route", "directions"),
      ("dir", "directions"),
      ("url", "link"),
      ("cats", "categories"),
    ])
  func aliasRewriting(alias: String, canonical: String) {
    #expect(CommandRouter.applyAliases(["mapctl", alias, "x"]) == ["mapctl", canonical, "x"])
  }

  @Test("Non-aliases and bare invocations are left alone")
  func aliasPassthrough() {
    #expect(CommandRouter.applyAliases(["mapctl", "search", "x"]) == ["mapctl", "search", "x"])
    #expect(CommandRouter.applyAliases(["mapctl"]) == ["mapctl"])
    #expect(CommandRouter.applyAliases([]) == [])
  }

  @Test("A leading query token becomes an implicit search")
  func implicitSearch() {
    #expect(
      CommandRouter.rewriteImplicitSearch(["mapctl", "blue bottle"], commandNames: commandNames)
        == ["mapctl", "search", "blue bottle"])
  }

  @Test("Command names and flags are never rewritten into a search")
  func implicitSearchSkips() {
    for name in commandNames {
      #expect(
        CommandRouter.rewriteImplicitSearch(["mapctl", name], commandNames: commandNames) == ["mapctl", name])
    }
    #expect(
      CommandRouter.rewriteImplicitSearch(["mapctl", "--help"], commandNames: commandNames) == ["mapctl", "--help"])
    #expect(CommandRouter.rewriteImplicitSearch(["mapctl"], commandNames: commandNames) == ["mapctl"])
  }
}
