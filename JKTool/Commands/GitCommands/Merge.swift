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
        
        @Option(name: .shortAndLong, help: "Merge branch name")
        var branch: String
        
        @Option(name: .shortAndLong, help: "squash，default：false")
        var squash: Bool = false
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "是否自动commit，默认为true")
        var commit: Bool = true
        
        @Option(name: .shortAndLong, help: "commit消息")
        var message: String?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?

        
        mutating func run() {
            
            func merge(project: Project){
                
                do {
                    let result = try shellOut(to: .gitMerge(branch: branch, squash: squash,commit: commit,message: message), at: project.directoryPath)
                    po(tip: "【\(project.workSpaceType.projectName())】Merge完成\n\(result)", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.workSpaceType.projectName())】 Merge失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive else {
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
