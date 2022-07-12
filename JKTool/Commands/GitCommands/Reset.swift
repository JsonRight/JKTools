//
//  Reset.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Reset: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "reset",
            _superCommandName: "git",
            abstract: "reset")
        
        @Argument(help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Argument(help: "执行日志，default：true")
        var quiet: Bool?
        
        @Argument(help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func reset(project: Project){
                do {
                    try shellOut(to: .gitPull(), at: project.directoryPath)
                    if quiet != false {po(tip: "【\(project.name)】Reset完成", type: .tip)}
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Reset失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                reset(project: project)
               return
            }
            
            if quiet != false {po(tip: "======Reset工程开始======", type: .tip)}
            
            reset(project: project)
            
            if recursive != true {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                reset(project: pro)
            }
            
            if quiet != false {po(tip: "======Reset工程完成======")}
        }
    }
}

