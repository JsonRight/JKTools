//
//  PodsCommands.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

/// CocoaPods commands
extension ShellOutCommand {
    /// Update all CocoaPods dependencies
    static func updateCocoaPods() -> ShellOutCommand {
        return ShellOutCommand(string: "pod update")
    }

    /// Install all CocoaPods dependencies
    static func installCocoaPods() -> ShellOutCommand {
        return ShellOutCommand(string: "pod install")
    }
}
