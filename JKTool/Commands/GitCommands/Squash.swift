//
//  MergeSquash.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/28.
//

import Foundation
extension JKTool.Git {
    struct Squash: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "squash",
            _superCommandName: "git",
            abstract: "merge squash",
            version: "1.0.0")
        
        @Argument(help: "merge from branch")
        var from: String
        
        @Argument(help: "merge to branch")
        var to: String
        
        @Argument(help: "commit的信息")
        var message: String
        
        @Argument(help: "删除 from 分支")
        var del: Bool?
        
        @Argument(help: "递归子模块")
        var recursive: Bool?
        
        @Argument(help: "执行日志")
        var quiet: Bool?
        
        @Argument(help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func squash(project: Project) {
                JKTool.Git.Checkout.main([from,"\(false)","\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Pull.main(["\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Checkout.main([to,"\(false)","\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Pull.main(["\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Merge.main([from,"\(true)","\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Commit.main([message,"\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Push.main(["\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Branch.Del.Local.main([from,"\(false)","\(false)",project.directoryPath])
                
                JKTool.Git.Branch.Del.Origin.main([from,"\(false)","\(false)",project.directoryPath])
                
                if quiet != false {po(tip: "【\(project.name)】Merge squash完成", type: .tip)}
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                
                squash(project: project)
               return
            }
            
            if quiet != false {po(tip: "======Merge squash工程开始======", type: .tip)}
            
            squash(project: project)
            if recursive != true {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                
                squash(project: pro)
            }
            
            if quiet != false {po(tip: "======Merge squash工程结束======")}
        }
    }
}
