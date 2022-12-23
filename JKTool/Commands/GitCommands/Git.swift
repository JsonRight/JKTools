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
            abstract: "git部分命令对于固定工程格式封装",
            version: "1.0.0",
            subcommands: [Init.self,
                          Clone.self,
                          Commit.self,
                          Pull.self,
                          Push.self,
                          Prune.self,
                          Merge.self,
                          Squash.self,
                          Branch.self,
                          Checkout.self,
                          Status.self,
                          Tag.self,
                          SubModule.self,
                          Zipper.self])
    }
}
