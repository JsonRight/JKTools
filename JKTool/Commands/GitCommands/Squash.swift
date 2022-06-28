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
        
        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "工程存放路径！")
        var del: Bool?
        
        @Argument(help: "是否递归！")
        var recursive: Bool?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                
                JKTool.Git.Checkout.main([from,"\(false)",project.directoryPath,"\(false)"])
                
                JKTool.Git.Pull.main([project.directoryPath,"\(false)"])
                
                JKTool.Git.Checkout.main([to,"\(false)",project.directoryPath,"\(false)"])
                
                JKTool.Git.Pull.main([project.directoryPath,"\(false)"])
                
                JKTool.Git.Merge.main([from,project.directoryPath,"\(true)","\(false)"])
                
                JKTool.Git.Commit.main([message,project.directoryPath,"\(false)"])
                
                JKTool.Git.Push.main([project.directoryPath,"\(false)"])
                
                JKTool.Git.Del.Local.main([from,project.directoryPath,"\(false)"])
                
                JKTool.Git.Del.Origin.main([from,project.directoryPath,"\(false)"])
                
                po(tip: "【\(project.name)】Merge squash完成", type: .tip)
               return
            }
            
            po(tip: "======Merge squash工程开始======", type: .tip)
            
            JKTool.Git.Checkout.main([from,"\(false)",project.directoryPath,"\(false)"])
            
            JKTool.Git.Pull.main([project.directoryPath,"\(false)"])
            
            JKTool.Git.Checkout.main([to,"\(false)",project.directoryPath,"\(false)"])
            
            JKTool.Git.Pull.main([project.directoryPath,"\(false)"])
            
            JKTool.Git.Merge.main([from,project.directoryPath,"\(true)","\(false)"])
            
            JKTool.Git.Commit.main([message,project.directoryPath,"\(false)"])
            
            JKTool.Git.Push.main([project.directoryPath,"\(false)"])
            
            JKTool.Git.Del.Local.main([from,project.directoryPath,"\(false)"])
            
            JKTool.Git.Del.Origin.main([from,project.directoryPath,"\(false)"])
            
            po(tip: "【\(project.name)】Merge squash完成", type: .tip)
            
            if recursive != false {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                
                JKTool.Git.Checkout.main([from,"\(false)",pro.directoryPath,"\(false)"])
                
                JKTool.Git.Pull.main([pro.directoryPath,"\(false)"])
                
                JKTool.Git.Checkout.main([to,"\(false)",pro.directoryPath,"\(false)"])
                
                JKTool.Git.Pull.main([pro.directoryPath,"\(false)"])
                
                JKTool.Git.Merge.main([from,pro.directoryPath,"\(true)","\(false)"])
                
                JKTool.Git.Commit.main([message,pro.directoryPath,"\(false)"])
                
                JKTool.Git.Push.main([pro.directoryPath,"\(false)"])
                
                JKTool.Git.Del.Local.main([from,pro.directoryPath,"\(false)"])
                
                JKTool.Git.Del.Origin.main([from,pro.directoryPath,"\(false)"])
                
                po(tip: "【\(pro.name)】Merge squash完成", type: .tip)
            }
            
            po(tip: "======Merge squash工程结束======")
        }
    }
}
