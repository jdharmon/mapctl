import Foundation

struct Console {
  static func printError(_ message: String) {
    var stderr = StandardErrorOutputStream()
    Swift.print(message, to: &stderr)
  }
}

struct StandardErrorOutputStream: TextOutputStream {
  mutating func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    FileHandle.standardError.write(data)
  }
}
