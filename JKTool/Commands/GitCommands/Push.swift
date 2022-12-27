//
//  Push.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Push: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "push",
            _superCommandName: "git",
            abstract: "push")
        
        @Option(name: .shortAndLong, help: "push branch name")
        var branch: String?
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func push(project: Project){
                
                if branch == nil {
                    branch = try? shellOut(to: .gitCurrentBranch(), at: project.directoryPath)
                }
                
                guard let branch = branch else {
                    return po(tip: "【\(project.destination)】 Push失败\n" + "无法检索出当前分支名",type: .error)
                }
                
                do {
                    try shellOut(to: .gitPush(branch: branch), at: project.directoryPath)
                    po(tip: "【\(project.destination)】Push[\(branch)]完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.destination)】 Push[\(branch)]失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive  else {
                push(project: project)
               return
            }
            
            po(tip: "======Push工程开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                push(project: pro)
            }
            
            push(project: project)
            
            po(tip: "======Push工程完成======")
        }
    }
}
