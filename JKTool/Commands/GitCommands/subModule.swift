//
//  SubModule.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

extension JKTool.Git {
    
    struct subModule: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "submodule",
            _superCommandName: "git",
            abstract: "submodule",
            version: "1.0.0",
            subcommands: [Update.self],
            defaultSubcommand: Update.self)
    }
    
}


extension JKTool.Git.subModule {
    struct Update: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "updata",
            _superCommandName: "submodule",
            abstract: "submodule updata",
            version: "1.0.0")

        @Argument(help: "是否先init")
        var i: Bool?
        
        @Argument(help: "递归子模块")
        var recursive: Bool?
        
        @Argument(help: "执行日志")
        var quiet: Bool?
        
        @Argument(help: "执行路径")
        var path: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            if quiet != false {po(tip: "======Updata工程开始======", type: .tip)}
            
            do {
                try shellOut(to: .gitSubmoduleUpdate(initializeIfNeeded: i ?? false, recursive: recursive ?? false), at: project.directoryPath)
                if quiet != false {po(tip: "【\(project.name)】Updata完成", type: .tip)}
            } catch {
                let error = error as! ShellOutError
                po(tip:  "【\(project.name)】Update失败\n" + error.message + error.output,type: .error)
            }
            if quiet != false {po(tip: "======Updata工程完成======", type: .tip)}
        }
    }
    
}







