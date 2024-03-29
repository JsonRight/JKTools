//
//  Version.swift
//  JKTool
//
//  Created by 姜奎 on 2023/4/11.
//

import Foundation

extension JKTool.Git {
    struct GitVersion: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "version",
            _superCommandName: "git",
            abstract: "获取 当前git目录下的各种版本信息",subcommands: [JKTool.Git.GitVersion.CommitId.self, JKTool.Git.GitVersion.GitVersion.self], defaultSubcommand: JKTool.Git.GitVersion.GitVersion.self)
    }
}
 
extension JKTool.Git.GitVersion {
    struct CommitId: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "commit",
            _superCommandName: "version",
            abstract: "current branch commit id")
        
        @Option(name: .shortAndLong, help: "是否使用短码，default：false")
        var short: Bool?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            let short = short ?? false
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            if short == false {
                guard let commitId = try? shellOut(to: .gitCurrentCommitId(),at: project.directoryPath)else {
                    return po(tip: "\(project.directoryPath)获取commit id失败，请检查是否为git仓库", type: .error)
                    
                }
                
                po(tip: commitId, type: .none)
            } else {
                guard let commitId = try? shellOut(to: .gitShortCurrentCommitId(),at: project.directoryPath)else {
                    return po(tip: "\(project.directoryPath)获取commit id失败，请检查是否为git仓库", type: .error)
                }
                
                po(tip: commitId, type: .none)
            }
        }
    }
}
    
extension JKTool.Git.GitVersion {
    struct GitVersion: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "version",
            _superCommandName: "version",
            abstract: "自定义的当前代码版本tag，基于commitid、status合成")
        
        @Option(name: .shortAndLong, help: "代码环境，default：Release")
        var configuration: String?
        
        @Option(name: .shortAndLong, help: "设备类型，default：iOS")
        var sdk: String?
        
        @Option(name: .shortAndLong, help: "加入模拟器(x86_64)架构，default：false")
        var includedSimulators: Bool?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            let sdk = sdk ?? "iOS"
            let configuration = configuration ?? "Release"
            
            let status = try? shellOut(to: .gitDiffHEAD(),at: project.directoryPath)
            let commitId = try? shellOut(to: .gitCurrentCommitId(),at: project.directoryPath)
            
            let xcodeVersion = String.safe(GlobalConstants.xcodeVersion)
            
            let currentVersion  =  String.safe(commitId)
                .appendingBySeparator(String.safe(status?.MD5) )
                .appendingBySeparator(configuration)
                .appendingBySeparator(sdk)
                .appendingBySeparator(xcodeVersion)
                .appendingBySeparator(SdkType(includedSimulators).rawValue)
            po(tip: currentVersion, type: .echo)
        }
    }
}
    
