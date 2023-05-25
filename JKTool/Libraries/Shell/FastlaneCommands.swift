//
//  FastlaneCommands.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

/// Fastlane
extension ShellOutCommand {
    /// Run Fastlane using a given lane
    static func runFastlane(usingLane lane: String) -> ShellOutCommand {
        let command = "fastlane".appending(argument: lane)
        return ShellOutCommand(string: command)
    }
}
