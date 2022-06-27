//
//  Tag.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

extension JKTool.Git {
    struct Tag: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "tag",
            _superCommandName: "git",
            abstract: "tag",
            subcommands: [Add.self, Del.self],
            defaultSubcommand: Add.self)
    }
}


extension JKTool.Git.Tag {
    struct Add: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "add",
            _superCommandName: "tag",
            abstract: "tag add",
            version: "1.0.0")
        
        @Argument(help: "工程存放路径！")
        var tag: String
        
        @Argument(help: "工程存放路径！")
        var path: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Add Tag开始======", type: .tip)
            
            do {
                try shellOut(to: .gitAddTag(tag: tag), at: project.directoryPath)
                po(tip: "【\(project.name)】Add Tag完成", type: .tip)
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
                    try shellOut(to: .gitAddTag(tag: tag), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Add Tag完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip:  error.message + error.output,type: .error)
                }
            }
            
            po(tip: "======Add Tag结束======")
        }
    }
    
    struct Del: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "del",
            _superCommandName: "tag",
            abstract: "tag del",
            version: "1.0.0")
        
        @Argument(help: "工程存放路径！")
        var tag: String
        
        @Argument(help: "工程存放路径！")
        var path: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Del Tag开始======", type: .tip)
            
            do {
                try shellOut(to: .gitDelTag(tag: tag), at: project.directoryPath)
                po(tip: "【\(project.name)】Del Tag完成", type: .tip)
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
                    try shellOut(to: .gitDelTag(tag: tag), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Del Tag完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip:  error.message + error.output,type: .error)
                }
            }
            
            po(tip: "======Del Tag结束======")
        }
    }
}




