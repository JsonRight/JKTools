//
//  git.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

extension JKTool {
    struct Git: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "git",
            _superCommandName: "JKTool",
            abstract: "git",
            version: "1.0.0",
            subcommands: [Init.self,Clone.self,Commit.self,Pull.self,Push.self,Prune.self,Rebase.self,Checkout.self,Status.self,Reset.self,Tag.self,subModule.self])
    }
}
