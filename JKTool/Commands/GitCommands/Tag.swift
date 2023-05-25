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
        
        @Option(name: .shortAndLong, help: "tag")
        var tag: String
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func addTag(project: Project){
                do {
                    try shellOut(to: .gitAddTag(tag: tag), at: project.directoryPath)
                    po(tip: "【\(project.workSpaceType.projectName())】Add Tag完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.workSpaceType.projectName())】 Add Tag失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive else {
                addTag(project: project)
               return
            }
            
            po(tip: "======Add Tag开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                addTag(project: pro)
            }
            
            addTag(project: project)
            
            po(tip: "======Add Tag结束======")
        }
    }
    
    struct Del: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "del",
            _superCommandName: "tag",
            abstract: "tag del",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "tag")
        var tag: String
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func delTag(project: Project){
                do {
                    try shellOut(to: .gitDelTag(tag: tag), at: project.directoryPath)
                    po(tip: "【\(project.workSpaceType.projectName())】Del Tag完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.workSpaceType.projectName())】 Del Tag失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive == true else {
                delTag(project: project)
               return
            }
            
            po(tip: "======Del Tag开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                delTag(project: pro)
            }
            
            delTag(project: project)
            
            po(tip: "======Del Tag结束======")
        }
    }
}




