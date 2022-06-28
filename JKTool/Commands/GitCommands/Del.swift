//
//  Del.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/28.
//

import Foundation
extension JKTool.Git {
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

extension JKTool.Git.Del {
    struct Local: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "local",
            _superCommandName: "del",
            abstract: "del local",
            version: "1.0.0")

        
        @Argument(help: "del by branch")
        var branch: String
        
        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "是否递归！")
        var recursive: Bool?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                do {
                    try shellOut(to: .gitDelLocalBranch(branch: branch), at: project.directoryPath)
                    po(tip: "【\(project.name)】Del local完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Del local失败\n" + error.message + error.output,type: .error)
                }
               return
            }
            
            po(tip: "======Del local工程开始======", type: .tip)
            
            do {
                try shellOut(to: .gitDelLocalBranch(branch: branch), at: project.directoryPath)
                po(tip: "【\(project.name)】Del local完成", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip: "【\(project.name)】 Del local失败\n" + error.message + error.output,type: .error)
            }
            
            if recursive != false {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                do {
                    try shellOut(to: .gitDelLocalBranch(branch: branch), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Del local完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Del local失败\n" + error.message + error.output,type: .error)
                }
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

        
        @Argument(help: "del by branch")
        var branch: String
        
        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "是否递归！")
        var recursive: Bool?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                do {
                    try shellOut(to: .gitDelOriginBranch(branch: branch), at: project.directoryPath)
                    po(tip: "【\(project.name)】Del origin完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Del origin失败\n" + error.message + error.output,type: .error)
                }
               return
            }
            
            po(tip: "======Del origin工程开始======", type: .tip)
            
            do {
                try shellOut(to: .gitDelOriginBranch(branch: branch), at: project.directoryPath)
                po(tip: "【\(project.name)】Del origin完成", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip: "【\(project.name)】 Del origin失败\n" + error.message + error.output,type: .error)
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                do {
                    try shellOut(to: .gitDelOriginBranch(branch: branch), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Del origin完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(pro.name)】 Del origin失败\n" + error.message + error.output,type: .error)
                }
            }
            
            po(tip: "======Del origin工程结束======")
        }
    }
}



