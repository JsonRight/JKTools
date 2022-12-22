//
//  Status.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Status: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "status",
            _superCommandName: "git",
            abstract: "status")
        
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func status(project: Project){
                do {
                    let status = try shellOut(to: .gitStatus(), at: project.directoryPath)
                    po(tip: "【\(project.name)】Status完成\n\(status)", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Status失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive == true else {
                status(project: project)
               return
            }
            
            
            po(tip: "======Status工程开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                
                status(project: pro)
            }
            
            status(project: project)
            
            po(tip: "======Status工程结束======")
        }
    }
}
