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
        
        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "是否递归！")
        var recursive: Bool?
        
        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                do {
                    try shellOut(to: .gitPull(), at: project.directoryPath)
                    po(tip: "【\(project.name)】Pull完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Pull失败\n" + error.message + error.output,type: .error)
                }
               return
            }
            po(tip: "======Pull工程开始======", type: .tip)
            
            do {
                try shellOut(to: .gitPull(), at: project.directoryPath)
                po(tip: "【\(project.name)】Pull完成", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip: "【\(project.name)】 Pull失败\n" + error.message + error.output,type: .error)
            }
            
            if recursive != false {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                do {
                    try shellOut(to: .gitPull(), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Pull完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(pro.name)】 Pull失败\n" + error.message + error.output,type: .error)
                }
            }
            
            po(tip: "======Pull工程结束======")
        }
    }
}
