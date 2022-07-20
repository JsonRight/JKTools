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
        
        @Argument(help: "执行日志，default：true")
        var quiet: Bool?
        
        mutating func run() {
            
            guard let project = Project.project() else {
                return po(tip: "\(FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            if quiet != false {po(tip: "======【\(project.name)】Rebase开始======")}
            do {
                let result = try shellOut(to: .gitRebase(branch: branch),at: project.directoryPath)
                po(tip: "【\(project.name)】Rebase[\(branch)]完成\n\(result)", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip: "【\(project.name)】Rebase[\(branch)]失败\n" + error.message + error.output,type: .warning)
            }
            if quiet != false {po(tip: "======【\(project.name)】Rebase完成======")}
        }
    }
}
