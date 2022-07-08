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
        
        @Argument(help: "Rebase by branch")
        var branch: String
        
        @Argument(help: "squash")
        var squash: Bool?
        
        @Argument(help: "递归子模块")
        var recursive: Bool?
        
        @Argument(help: "执行日志")
        var quiet: Bool?
        
        @Argument(help: "执行路径")
        var path: String?

        
        mutating func run() {
            
            func merge(project: Project){
                do {
                    try shellOut(to: .gitMerge(branch: branch, squash: squash), at: project.directoryPath)
                    if quiet != false {po(tip: "【\(project.name)】Merge完成", type: .tip)}
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Merge失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                merge(project: project)
               return
            }
            
            if quiet != false {po(tip: "======Merge工程开始======", type: .tip)}
            
            merge(project: project)
            
            if recursive != true {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                merge(project: pro)
            }
            
            if quiet != false {po(tip: "======Merge工程结束======")}
        }
    }
}
