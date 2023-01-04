//
//  Update.swift
//  JKTool
//
//  Created by 姜奎 on 2023/1/4.
//

import Foundation

import Foundation
extension JKTool {
    struct Update: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "update",
            _superCommandName: "JKTool",
            abstract: "利用git clone构建/更新项目结构",
            version: "1.0.0",subcommands: [Init.self,InitSubmodule.self])
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
        @Option(name: .shortAndLong, help: "执行目录")
        var path: String?
        
        mutating func run() {
            var args = [String]()
            if let force = force {
                args.append(contentsOf: ["--force",String(force)])
            }
            if let path = path {
                args.append(contentsOf: ["--path",String(path)])
            }
            
            JKTool.Git.Clone.main(args)
        }
    }
}


extension JKTool.Update {
    
    struct Init: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "init",
            _superCommandName: "update",
            abstract: "clone项目，并利用git clone构建/更新项目结构",
            version: "1.0.0")

        
        @Option(name: .shortAndLong, help: "项目git地址")
        var url: String
        
        @Option(name: .shortAndLong, help: "保存目录【绝对路径】")
        var path: String
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
        @Option(name: .shortAndLong, help: "分支名")
        var branch: String?
        
        mutating func run() {
            
            var args = [String]()
            args.append(contentsOf: ["--url",String(url)])
            
            args.append(contentsOf: ["--path",String(path)])
            if let force = force {
                args.append(contentsOf: ["--force",String(force)])
            }
            if let branch = branch {
                args.append(contentsOf: ["--branch",String(branch)])
            }
            
            JKTool.Git.Clone.Init.main(args)
        }
    }
    
    struct InitSubmodule: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "initSubmodule",
            _superCommandName: "update",
            abstract: "clone项目，并利用git submodule构建/更新项目结构",
            version: "1.0.0")

        
        @Option(name: .shortAndLong, help: "项目git地址")
        var url: String
        
        @Option(name: .shortAndLong, help: "保存目录【绝对路径】")
        var path: String
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
        @Option(name: .long, help: "移除不在SubModule中的SubProject，default：false")
        var prune: Bool?
        
        @Option(name: .shortAndLong, help: "更新 submodule 为远程项目的最新版本，default：false")
        var remote: Bool?
        
        @Option(name: .shortAndLong, help: "分支名")
        var branch: String?
        
        mutating func run() {
            var args = [String]()
            args.append(contentsOf: ["--url",String(url)])
            
            args.append(contentsOf: ["--path",String(path)])
            if let force = force {
                args.append(contentsOf: ["--force",String(force)])
            }
            if let prune = prune {
                args.append(contentsOf: ["--prune",String(prune)])
            }
            if let remote = remote {
                args.append(contentsOf: ["--remote",String(remote)])
            }
            if let branch = branch {
                args.append(contentsOf: ["--branch",String(branch)])
            }
            
            JKTool.Git.SubModule.Init.main(args)
        }
    }
}



