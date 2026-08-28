import Commander
import Foundation
import MapCore

struct DoctorReport: Codable, Sendable, Equatable {
  let version: String
  let executable: String
  let shell: String?
  let locale: String
  let measurementSystem: String
  let mapServicesReachable: Bool
  let mapServicesError: String?
  let agentNotes: [String]
}

enum DoctorCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "doctor",
      abstract: "Diagnose setup and connectivity",
      discussion: """
        mapctl needs no permissions, only a network connection, so this checks
        that Apple's map services actually answer from this machine.
        """,
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          flags: [
            .make(label: "forAgent", names: [.long("for-agent")], help: "Include agent-focused usage notes")
          ]
        )
      ),
      usageExamples: [
        "mapctl doctor",
        "mapctl doctor --for-agent --json",
      ]
    ) { values, runtime in
      let report = await buildReport(version: version(), includeNotes: values.flag("forAgent"))

      switch runtime.outputFormat {
      case .json:
        OutputRenderer.printJSON(report)
      case .plain, .quiet:
        Swift.print(report.mapServicesReachable ? "ok" : "unreachable")
      case .standard, .table:
        printStandard(report)
      }
    }
  }

  /// A known-good address doubles as the reachability probe: if MapKit answers
  /// this, every other lookup is reaching Apple's servers too.
  static let probeAddress = "1 Apple Park Way, Cupertino CA"

  static let agentNotes = [
    "No permission prompt is involved; every failure is a network or throttling failure.",
    "Prefer --json when another step consumes the output.",
    "MapKit returns transit travel times via `eta`, but never transit routes via `directions`.",
    "Back-to-back lookups can trip Apple's rate limiting; space them out if you see throttling errors.",
  ]

  private static func buildReport(version: String, includeNotes: Bool) async -> DoctorReport {
    var reachable = false
    var failure: String?
    do {
      reachable = try await !MapService().geocode(address: probeAddress).isEmpty
    } catch {
      failure = error.localizedDescription
    }

    return DoctorReport(
      version: version,
      executable: ProcessInfo.processInfo.arguments.first ?? "mapctl",
      shell: ProcessInfo.processInfo.environment["SHELL"],
      locale: Locale.current.identifier,
      measurementSystem: MeasurementSystem.current().rawValue,
      mapServicesReachable: reachable,
      mapServicesError: failure,
      agentNotes: includeNotes ? agentNotes : [])
  }

  private static func printStandard(_ report: DoctorReport) {
    Swift.print("mapctl \(report.version)")
    Swift.print("Executable: \(report.executable)")
    Swift.print("Shell: \(report.shell ?? "unknown")")
    Swift.print("Locale: \(report.locale) (\(report.measurementSystem))")
    Swift.print("Map services: \(report.mapServicesReachable ? "reachable" : "unreachable")")
    if let failure = report.mapServicesError {
      Swift.print("  \(failure)")
    }
    for note in report.agentNotes {
      Swift.print("- \(note)")
    }
  }

  private static func version() -> String {
    if let envVersion = ProcessInfo.processInfo.environment["MAPCTL_VERSION"], !envVersion.isEmpty {
      return envVersion
    }
    return MapctlVersion.current
  }
}
