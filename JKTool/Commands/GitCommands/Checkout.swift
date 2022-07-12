//
//  Checkout.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation
extension JKTool.Git {
    struct Checkout: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "checkout",
            _superCommandName: "git",
            abstract: "checkout")
        
        @Argument(help: "Checkout branch")
        var branch: String
        
        @Argument(help: "强制")
        var force: Bool?
        
        @Argument(help: "递归子模块")
        var recursive: Bool?
        
        @Argument(help: "执行日志")
        var quiet: Bool?
        
        @Argument(help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func checkout(project: Project){
                do {
                    try shellOut(to: .gitCheckout(branch: branch, force: force ?? false), at: project.directoryPath)
                    if quiet != false {po(tip: "【\(project.name)】Checkout完成", type: .tip)}
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.name)】 Checkout失败\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                checkout(project: project)
               return
            }
            
            if quiet != false {po(tip: "======Checkout工程开始======", type: .tip)}
            
            checkout(project: project)
            
            if recursive != true {
                return
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                checkout(project: pro)
            }
            
            if quiet != false {po(tip: "======Checkout工程结束======")}
        }
    }
}
