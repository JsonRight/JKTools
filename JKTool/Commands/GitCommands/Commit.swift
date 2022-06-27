//
//  Commit.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Commit: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "commit",
            _superCommandName: "git",
            abstract: "commit",
            version: "1.0.0",
            subcommands: [Sub.self, All.self],
            defaultSubcommand: Sub.self)
    }
}

extension JKTool.Git.Commit {
    struct Sub: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "sub",
            _superCommandName: "commit",
            abstract: "commit sub",
            version: "1.0.0")
        @Argument(help: "commit的信息")
        var message: String
        
        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "子模块名称！")
        var module: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            var commitPath = project.directoryPath
            
            if project.rootProject == project, let module = module {
                commitPath = "\(project.checkoutsPath)/\(module)/"
            }
            
            guard let pro = Project.project(directoryPath: commitPath) else {
                return po(tip: "\(commitPath)目录没有检索到工程", type: .error)
            }
            po(tip: "======【\(pro.name)】Commit开始======", type: .tip)
            do {
                try shellOut(to: .gitCommit(message: message), at: commitPath)
                po(tip: "======【\(pro.name)】Commit完成======", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
        }
    }
    
    struct All: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "all",
            _superCommandName: "commit",
            abstract: "commit all",
            version: "1.0.0")
        
        @Argument(help: "commit的信息")
        var message: String

        @Argument(help: "工程存放路径！")
        var path: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Commit工程开始======", type: .tip)
            
            do {
                try shellOut(to: .gitCommit(message: message), at: project.directoryPath)
                po(tip: "【\(project.name)】Commit完成", type: .tip)
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
                    try shellOut(to: .gitCommit(message: message), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Commit完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip:  error.message + error.output,type: .error)
                }
            }
            
            po(tip: "======Commit工程完成======")
        }
    }
}




