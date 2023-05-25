//
//  SPMCommands.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

/// Swift Package Manager commands
extension ShellOutCommand {
    /// Enum defining available package types when using the Swift Package Manager
    enum SwiftPackageType: String {
        case library
        case executable
    }

    /// Enum defining available build configurations when using the Swift Package Manager
    enum SwiftBuildConfiguration: String {
        case debug
        case release
    }

    /// Create a Swift package with a given type (see SwiftPackageType for options)
    static func createSwiftPackage(withType type: SwiftPackageType = .library) -> ShellOutCommand {
        let command = "swift package init --type \(type.rawValue)"
        return ShellOutCommand(string: command)
    }

    /// Update all Swift package dependencies
    static func updateSwiftPackages() -> ShellOutCommand {
        return ShellOutCommand(string: "swift package update")
    }

    /// Generate an Xcode project for a Swift package
    static func generateSwiftPackageXcodeProject() -> ShellOutCommand {
        return ShellOutCommand(string: "swift package generate-xcodeproj")
    }

    /// Build a Swift package using a given configuration (see SwiftBuildConfiguration for options)
    static func buildSwiftPackage(withConfiguration configuration: SwiftBuildConfiguration = .debug) -> ShellOutCommand {
        return ShellOutCommand(string: "swift build -c \(configuration.rawValue)")
    }

    /// Test a Swift package using a given configuration (see SwiftBuildConfiguration for options)
    static func testSwiftPackage(withConfiguration configuration: SwiftBuildConfiguration = .debug) -> ShellOutCommand {
        return ShellOutCommand(string: "swift test -c \(configuration.rawValue)")
    }
}
