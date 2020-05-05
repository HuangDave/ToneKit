// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "ToneKit",
  platforms: [
    .iOS(.v12),
  ],
  products: [
    .library(
      name: "ToneKit",
      type: .dynamic,
      targets: ["ToneKit"]),
  ],
  targets: [
    .target(
      name: "ToneKit",
      path: "ToneKit")
  ]
)
