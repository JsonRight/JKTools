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
            version: "1.0.0",subcommands: [Init.self])
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
        @Option(name: .shortAndLong, help: "利用git submodule构建/更新项目结构，default：false")
        var submodule: Bool?
        
        @Option(name: .long, help: "移除不在submodules中的submodule,仅在`--submodule true`时有效，default：false")
        var prune: Bool?
        
        @Option(name: .shortAndLong, help: "更新submodules为远程项目的最新版本,仅在`--submodule true`时有效，default：false")
        var remote: Bool?
        
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
            if submodule == true {
                
                if let prune = prune {
                    args.append(contentsOf: ["--prune",String(prune)])
                }
                if let remote = remote {
                    args.append(contentsOf: ["--remote",String(remote)])
                }
                
                JKTool.Git.SubModule.main(args)
            } else {
                JKTool.Git.Clone.main(args)
            }
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
        
        @Option(name: .shortAndLong, help: "利用git submodule构建/更新项目结构，default：false")
        var submodule: Bool?
        
        @Option(name: .long, help: "移除不在submodules中的module,仅在`--submodule true`时有效，default：false")
        var prune: Bool?
        
        @Option(name: .shortAndLong, help: "更新submodules为远程项目的最新版本,仅在`--submodule true`时有效，default：false")
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
            if let branch = branch {
                args.append(contentsOf: ["--branch",String(branch)])
            }
            if submodule == true {
                
                if let prune = prune {
                    args.append(contentsOf: ["--prune",String(prune)])
                }
                if let remote = remote {
                    args.append(contentsOf: ["--remote",String(remote)])
                }
                
                JKTool.Git.SubModule.Init.main(args)
            } else {
                JKTool.Git.Clone.Init.main(args)
            }
        }
    }
}



