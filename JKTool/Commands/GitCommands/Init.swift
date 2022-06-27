//
//  Init.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation

extension JKTool.Git {
    struct Init: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "init",
            _superCommandName: "git",
            abstract: "init",
            version: "1.0.0")
        
        @Argument(help: "init git仓库路径！")
        var path: String?
        
        mutating func run() {
            po(tip: "======开始准备init git仓库======")
            do {
                try shellOut(to: .gitInit(),at: path ?? FileManager.default.currentDirectoryPath)
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======init git仓库完成======")
        }
    }
}
