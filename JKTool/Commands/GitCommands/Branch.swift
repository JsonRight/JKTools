//
//  Branch.swift
//  JKTool
//
//  Created by 姜奎 on 2022/7/8.
//

import Foundation

extension JKTool.Git {
    struct Branch: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "branch",
            _superCommandName: "git",
            abstract: "branch",
            version: "1.0.0",
            subcommands: [Create.self, Del.self])
    }
}

extension JKTool.Git.Branch {
    struct Create: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "create",
            _superCommandName: "git",
            abstract: "create a branch",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "create branch name")
        var branch: String
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "执行日志，default：true")
        var quiet: Bool = true
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func create(project: Project){
                do {
                    try shellOut(to: .gitCreateBranch(branch: branch), at: project.directoryPath)
                    if quiet {po(tip: "【\(project.workSpaceType.projectName())】Create branch完成", type: .tip)}
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.workSpaceType.projectName())】 Create branch失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                create(project: project)
               return
            }
            
            if quiet {po(tip: "======Create branch工程开始======", type: .tip)}
            
            guard recursive else {
                create(project: project)
                
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                create(project: pro)
            }
            
            create(project: project)
            
            if quiet {po(tip: "======Create branch工程结束======")}
        }
        
    }
}

extension JKTool.Git.Branch {
    
    struct Del: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "del",
            _superCommandName: "git",
            abstract: "del",
            version: "1.0.0",
            subcommands: [Local.self, Origin.self],
            defaultSubcommand: Local.self)
    }
    
}

extension JKTool.Git.Branch.Del {
    struct Local: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "local",
            _superCommandName: "del",
            abstract: "del local",
            version: "1.0.0")

        
        @Option(name: .shortAndLong, help: "del by branch")
        var branch: String
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func del(project: Project){
                
                do {
                    try shellOut(to: .gitDelLocalBranch(branch: branch), at: project.directoryPath)
                    po(tip: "【\(project.workSpaceType.projectName())】Del local完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.workSpaceType.projectName())】 Del local失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive else {
                del(project: project)
               return
            }
            
            po(tip: "======Del local工程开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                del(project: pro)
            }
            
            po(tip: "======Del local工程结束======")
        }
        
    }
    
    struct Origin: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "origin",
            _superCommandName: "del",
            abstract: "del origin",
            version: "1.0.0")

        
        @Option(name: .shortAndLong, help: "del by branch")
        var branch: String
        
        @Option(name: .shortAndLong, help: "是否递归，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "工程存放路径！")
        var path: String?
        
        mutating func run() {
            
            func del(project: Project){
                do {
                    try shellOut(to: .gitDelOriginBranch(branch: branch), at: project.directoryPath)
                    po(tip: "【\(project.workSpaceType.projectName())】Del origin完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.workSpaceType.projectName())】 Del origin失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive else {
                del(project: project)
               return
            }
            
            po(tip: "======Del origin工程开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                del(project: pro)
            }
            
            po(tip: "======Del origin工程结束======")
        }
    }
}
