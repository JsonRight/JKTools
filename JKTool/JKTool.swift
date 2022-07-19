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
        subcommands: [Build.self,Git.self,Archive.self,Export.self,Upload.self,Shell.self,Config.self])
}
