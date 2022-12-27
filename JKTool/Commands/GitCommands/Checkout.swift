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
        
        @Option(name: .shortAndLong, help: "Checkout branch")
        var branch: String
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "强制 checkout，default：false")
        var force: Bool = false
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func checkout(project: Project){
                do {
                    try shellOut(to: .gitCheckout(branch: branch, force: force), at: project.directoryPath)
                    po(tip: "【\(project.destination)】Checkout[\(branch)]完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "【\(project.destination)】 Checkout失败\n" + error.message + error.output,type: .warning)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive else {
                checkout(project: project)
               return
            }
            
            po(tip: "======Checkout工程开始======", type: .tip)
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                checkout(project: pro)
            }
            
            checkout(project: project)
            
            po(tip: "======Checkout工程结束======")
        }
    }
}
