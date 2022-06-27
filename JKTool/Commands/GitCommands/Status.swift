//
//  Status.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Status: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "status",
            _superCommandName: "git",
            abstract: "status",
            subcommands: [Sub.self, All.self],
            defaultSubcommand: Sub.self)
    }
}


extension JKTool.Git.Status {
    struct Sub: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "sub",
            _superCommandName: "status",
            abstract: "status sub",
            version: "1.0.0")
        
        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "子模块名称！")
        var module: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            var statusPath = project.directoryPath
            
            if project.rootProject == project, let module = module {
                statusPath = "\(project.checkoutsPath)/\(module)/"
            }
            
            guard let pro = Project.project(directoryPath: statusPath) else {
                return po(tip: "\(statusPath)目录没有检索到工程", type: .error)
            }
            po(tip: "======【\(pro.name)】Status开始======", type: .tip)
            do {
                try shellOut(to: .gitPull(), at: statusPath)
                po(tip: "======【\(pro.name)】Status完成======", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
        }
    }
    
    struct All: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "all",
            _superCommandName: "status",
            abstract: "status all",
            version: "1.0.0")
        
        @Argument(help: "工程存放路径！")
        var path: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Status工程开始======", type: .tip)
            
            do {
                try shellOut(to: .gitPull(), at: project.directoryPath)
                po(tip: "【\(project.name)】Status完成", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                do {
                    try shellOut(to: .gitPull(), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Status完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip:  error.message + error.output,type: .error)
                }
            }
            
            po(tip: "======Status工程结束======")
        }
    }
}




