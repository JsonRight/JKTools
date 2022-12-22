//
//  Commit.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Commit: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "commit",
            _superCommandName: "git",
            abstract: "commit",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "commit的信息")
        var message: String
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "执行目录")
        var path: String?
        
        mutating func run() {
            
            func commit(project: Project){
                let status = try? shellOut(to: .gitStatus(), at: project.directoryPath)
                
                guard  status?.count ?? 0 > 0 else {
                    po(tip: "【\(project.name)】 没有需要提交的内容\n",type: .tip)
                    return
                }
                
                do {
                    try shellOut(to: .gitCommit(message: message), at: project.directoryPath)
                    po(tip: "【\(project.name)】Commit完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Commit失败\n" + error.message + error.output,type: .warning)
                }
            }
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive  else {
                
                let status = try? shellOut(to: .gitStatus(), at: project.directoryPath)
                
                guard  status?.count ?? 0 > 0 else {
                    po(tip: "【\(project.name)】 没有需要提交的内容\n",type: .tip)
                    return
                }
                commit(project: project)
               return
            }
            
            po(tip: "======Commit工程开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                let status = try? shellOut(to: .gitStatus(), at: pro.directoryPath)
                
                guard  status?.count ?? 0 > 0 else {
                    po(tip: "【\(pro.name)】 没有需要提交的内容\n",type: .tip)
                    continue
                }
                commit(project: pro)
            }
            
            let status = try? shellOut(to: .gitStatus(), at: project.directoryPath)
            
            guard  status?.count ?? 0 > 0 else {
                po(tip: "【\(project.name)】 没有需要提交的内容\n",type: .tip)
                return
            }
            
            commit(project: project)
            
            po(tip: "======Commit工程完成======")
        }
    }
}
