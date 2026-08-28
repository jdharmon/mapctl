// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "mapctl",
  platforms: [.macOS(.v26)],
  products: [
    .library(name: "MapCore", targets: ["MapCore"]),
    .executable(name: "mapctl", targets: ["mapctl"]),
  ],
  dependencies: [
    .package(url: "https://github.com/steipete/Commander.git", from: "0.2.0")
  ],
  targets: [
    .target(
      name: "MapCore",
      dependencies: [],
      linkerSettings: [
        .linkedFramework("MapKit"),
        .linkedFramework("CoreLocation"),
      ]
    ),
    .executableTarget(
      name: "mapctl",
      dependencies: [
        "MapCore",
        .product(name: "Commander", package: "Commander"),
      ],
      exclude: [
        "Resources/Info.plist"
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-sectcreate",
          "-Xlinker", "__TEXT",
          "-Xlinker", "__info_plist",
          "-Xlinker", "Sources/mapctl/Resources/Info.plist",
        ])
      ]
    ),
    .testTarget(
      name: "MapCoreTests",
      dependencies: [
        "MapCore"
      ]
    ),
    .testTarget(
      name: "mapctlTests",
      dependencies: [
        "mapctl",
        "MapCore",
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
