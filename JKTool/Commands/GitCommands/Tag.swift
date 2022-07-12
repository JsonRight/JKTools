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
        
        @Argument(help: "tag")
        var tag: String
        
        @Argument(help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Argument(help: "执行日志，default：true")
        var quiet: Bool?
        
        @Argument(help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func addTag(project: Project){
                do {
                    try shellOut(to: .gitAddTag(tag: tag), at: project.directoryPath)
                    if quiet != false {po(tip: "【\(project.name)】Add Tag完成", type: .tip)}
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Add Tag失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                addTag(project: project)
               return
            }
            
            if quiet != false {po(tip: "======Add Tag开始======", type: .tip)}
            
            addTag(project: project)
            
            if recursive != true {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                addTag(project: pro)
            }
            
            if quiet != false {po(tip: "======Add Tag结束======")}
        }
    }
    
    struct Del: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "del",
            _superCommandName: "tag",
            abstract: "tag del",
            version: "1.0.0")
        
        @Argument(help: "tag")
        var tag: String
        
        @Argument(help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Argument(help: "执行日志，default：true")
        var quiet: Bool?
        
        @Argument(help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func delTag(project: Project){
                do {
                    try shellOut(to: .gitDelTag(tag: tag), at: project.directoryPath)
                    if quiet != false {po(tip: "【\(project.name)】Del Tag完成", type: .tip)}
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Del Tag失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                delTag(project: project)
               return
            }
            
            if quiet != false {po(tip: "======Del Tag开始======", type: .tip)}
            
            delTag(project: project)
            
            if recursive != true {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                delTag(project: pro)
            }
            
            if quiet != false {po(tip: "======Del Tag结束======")}
        }
    }
}




