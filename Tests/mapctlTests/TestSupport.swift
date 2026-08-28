import Commander
import Foundation

@testable import mapctl

/// Builds `ParsedValues` directly, which is how command-layer logic is tested
/// without going anywhere near MapKit.
enum Values {
  static func make(
    positional: [String] = [],
    options: [String: [String]] = [:],
    flags: Set<String> = []
  ) -> ParsedValues {
    ParsedValues(positional: positional, options: options, flags: flags)
  }

  static func option(_ name: String, _ value: String) -> [String: [String]] {
    [name: [value]]
  }
}
