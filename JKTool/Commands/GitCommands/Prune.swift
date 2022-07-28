//
//  Prune.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Prune: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "prune",
            _superCommandName: "git",
            abstract: "prune")
        
        
        @Argument(help: "递归子模块，default：false")
        var recursive: Bool?
        
        @Argument(help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func prune(project: Project){
                do {
                    let result = try shellOut(to: .gitPrune(), at: project.directoryPath)
                    po(tip: "【\(project.name)】Prune完成\n\(result)", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Prune失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive == true else {
                prune(project: project)
               return
            }
            
            po(tip: "======Prune工程开始======", type: .tip)
           
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                prune(project: pro)
            }
            
            prune(project: project)
            
            po(tip: "======Prune工程结束======")
        }
    }
}
