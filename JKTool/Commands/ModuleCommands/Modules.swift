//
//  Modules.swift
//  JKTool
//
//  Created by 姜奎 on 2023/4/12.
//

import Foundation

extension JKTool {
    struct Modules: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "module",
            _superCommandName: "JKTool",
            abstract: "项目更新子库对于固定工程格式封装",
            version: "1.0.0",subcommands: [Update.self,Init.self])
    }
}

extension JKTool.Modules {
    struct Update: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "update",
            _superCommandName: "module",
            abstract: "利用git clone构建/更新项目结构",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
        @Option(name: .shortAndLong, help: "利用git submodule构建/更新项目结构，default：false")
        var submodule: Bool?
        
        @Option(name: .long, help: "移除不在submodules中的submodule，default：false")
        var prune: Bool?
        
        @Option(name: .shortAndLong, help: "更新submodules为远程项目的最新版本,仅在`--submodule true`时有效，default：false")
        var remote: Bool?
        
        @Option(name: .long, help: "执行目录")
        var path: String?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            var args = [String]()
            if let force = force {
                args.append(contentsOf: ["--force",String(force)])
            }
            if let path = path {
                args.append(contentsOf: ["--path",String(path)])
            }
            
            if let prune = prune {
                args.append(contentsOf: ["--prune",String(prune)])
            }
            
            if submodule == true {
                
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


extension JKTool.Modules {
    
    struct Init: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "init",
            _superCommandName: "module",
            abstract: "clone项目，并利用git clone构建/更新项目结构",
            version: "1.0.0")

        
        @Option(name: .shortAndLong, help: "项目git地址")
        var url: String
        
        @Option(name: .long, help: "保存目录【绝对路径】")
        var path: String?
        
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
            
            po(tip: "======开始准备clone项目======")
            let date = Date.init().timeIntervalSince1970
            let path = path ?? FileManager.default.currentDirectoryPath
            let fileList = FileManager.default.getFileList(directoryPath: path)
            let isEmpty = fileList?.isEmpty ?? true
            
            if isEmpty == true || force == true {
                if let fileList = fileList {
                    for file in fileList {
                        do {
                            try FileManager.default.removeItem(atPath: file.path)
                        } catch {
                            po(tip: "【\(file.path)】无法清理，请检查！")
                        }
                    }
                }
                
                do {
                    po(tip: "【\(destinationForPath(path: path))】开始执行：git clone")
                    let date = Date.init().timeIntervalSince1970
                    try shellOut(to: .gitClone(url: url, to: path, branch: branch))
                    po(tip:"【\(destinationForPath(path: path))】clone成功[\(GlobalConstants.duration(to: date) + " s")]")
                } catch {
                    let error = error as! ShellOutError
                    po(tip:  error.message + error.output,type: .error)
                }
            }
            
            var args = [String]()
            
            if let force = force {
                args.append(contentsOf: ["--force",String(force)])
            }
            
            if let submodule = submodule {
                args.append(contentsOf: ["--submodule",String(submodule)])
            }
            
            if let prune = prune {
                args.append(contentsOf: ["--prune",String(prune)])
            }
            
            if let remote = remote {
                args.append(contentsOf: ["--remote",String(remote)])
            }
            
            args.append(contentsOf: ["--path",String(path)])
            
            JKTool.Modules.Update.main(args)
            
            po(tip: "======clone项目完成[\(GlobalConstants.duration(to: date) + " s")]======")
        }
    }
}
