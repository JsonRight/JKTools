//
//  Pull.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

extension JKTool.Git {
    struct Pull: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "pull",
            _superCommandName: "git",
            abstract: "pull",
            version: "1.0.0")
        
        @Argument(help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Argument(help: "执行日志，default：true")
        var quiet: Bool?
        
        @Argument(help: "执行目录")
        var path: String?
        
        mutating func run() {
            
            func pull(project: Project){
                do {
                    let result = try shellOut(to: .gitPull(), at: project.directoryPath)
                    if quiet != false {po(tip: "【\(project.name)】Pull完成\n\(result)", type: .tip)}
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Pull失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                pull(project: project)
               return
            }
            if quiet != false {po(tip: "======Pull工程开始======", type: .tip)}
            
            if recursive != true {
                pull(project: project)
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                pull(project: pro)
            }
            pull(project: project)
            if quiet != false {po(tip: "======Pull工程结束======")}
        }
    }
}
