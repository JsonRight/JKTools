//
//  Merge.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/28.
//

import Foundation
extension JKTool.Git {
    struct Merge: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "merge",
            _superCommandName: "git",
            abstract: "merge",
            version: "1.0.0")
        
        @Argument(help: "Merge branch name")
        var branch: String?
        
        @Argument(help: "squash，default：false")
        var squash: Bool?
        
        @Argument(help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Argument(help: "执行路径")
        var path: String?

        
        mutating func run() {
            
            func merge(project: Project){
                
                if branch == nil {
                    branch = try? shellOut(to: .gitCurrentBranch(), at: project.directoryPath)
                }
                
                guard let branch = branch else {
                    return po(tip: "【\(project.name)】 Merge失败\n" + "无法检索出当前分支名",type: .error)
                }
                
                do {
                    let result = try shellOut(to: .gitMerge(branch: branch, squash: squash), at: project.directoryPath)
                    po(tip: "【\(project.name)】Merge完成\n\(result)", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Merge失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                merge(project: project)
               return
            }
            
            if recursive != true {
                
                merge(project: project)
                
                return
            }
            
            po(tip: "======Merge工程开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                merge(project: pro)
            }
            
            merge(project: project)
            
            po(tip: "======Merge工程结束======")
        }
    }
}
