import Foundation
import MapCore

enum OutputFormat: Equatable {
  case standard
  case table
  case plain
  case json
  case quiet
}

enum OutputRenderer {
  static func printJSON<T: Encodable>(_ payload: T) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    encoder.dateEncodingStrategy = .iso8601
    do {
      let data = try encoder.encode(payload)
      if let json = String(data: data, encoding: .utf8) {
        Swift.print(json)
      }
    } catch {
      Swift.print("Failed to encode JSON: \(error)")
    }
  }

  static func printNames(_ names: [String], format: OutputFormat) {
    switch format {
    case .standard, .table, .plain:
      for name in names {
        Swift.print(name)
      }
    case .json:
      printJSON(names)
    case .quiet:
      Swift.print("\(names.count)")
    }
  }

  /// Tabs are the field separator in table and plain output, so any embedded
  /// whitespace has to collapse or the columns break.
  static func sanitize(_ value: String?) -> String {
    guard let value else { return "" }
    return value.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
  }
}
