//
//  SubModule.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

extension JKTool.Git {
    
    struct SubModule: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "submodule",
            _superCommandName: "git",
            abstract: "submodule",
            version: "1.0.0",
            subcommands: [Update.self],
            defaultSubcommand: Update.self)
    }
    
}

