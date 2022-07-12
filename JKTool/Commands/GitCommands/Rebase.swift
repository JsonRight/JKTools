//
//  Rebase.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Rebase: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "rebase",
            _superCommandName: "git",
            abstract: "rebase",
            version: "1.0.0")
        
        @Argument(help: "Rebase by branch")
        var branch: String
        
        @Argument(help: "执行日志")
        var quiet: Bool?
        
        mutating func run() {
            
            guard let project = Project.project() else {
                return po(tip: "\(FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            if quiet != false {po(tip: "======【\(project.name)】Rebase开始======")}
            do {
                try shellOut(to: .gitRebase(branch: branch),at: project.directoryPath)
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            if quiet != false {po(tip: "======【\(project.name)】Rebase完成======")}
        }
    }
}
