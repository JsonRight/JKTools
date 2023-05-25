//
//  MarathonCommands.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

/// Marathon commands
extension ShellOutCommand {
    /// Run a Marathon Swift script
    static func runMarathonScript(at path: String, arguments: [String] = []) -> ShellOutCommand {
        let command = "marathon run".appending(argument: path)
                                    .appending(arguments: arguments)

        return ShellOutCommand(string: command)
    }

    /// Update all Swift packages managed by Marathon
    static func updateMarathonPackages() -> ShellOutCommand {
        return ShellOutCommand(string: "marathon update")
    }
}
