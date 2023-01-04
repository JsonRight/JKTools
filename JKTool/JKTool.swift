//
//  JKTool.swift
//  JKTool
//
//  Created by 姜奎 on 2021/4/25.
//

import Darwin


struct JKTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "JKTool",
        abstract: "JKTool",
        version: "1.0.0",
        subcommands: [Git.self,Update.self,Build.self,Archive.self,Export.self,Upload.self,Config.self,Shell.self])
}
