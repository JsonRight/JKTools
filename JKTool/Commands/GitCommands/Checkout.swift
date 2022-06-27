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
            abstract: "checkout",
            subcommands: [Sub.self, All.self],
            defaultSubcommand: Sub.self)
    }
}


extension JKTool.Git.Checkout {
    struct Sub: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "sub",
            _superCommandName: "checkout",
            abstract: "checkout sub",
            version: "1.0.0")
        
        @Argument(help: "Checkout branch")
        var branch: String
        
        @Argument(help: "子模块名称！")
        var force: Bool?
        
        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "子模块名称！")
        var module: String?
        

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            var checkoutPath = project.directoryPath
            
            if project.rootProject == project, let module = module {
                checkoutPath = "\(project.checkoutsPath)/\(module)/"
            }
            
            guard let pro = Project.project(directoryPath: checkoutPath) else {
                return po(tip: "\(checkoutPath)目录没有检索到工程", type: .error)
            }
            po(tip: "======【\(pro.name)】Checkout开始======", type: .tip)
            do {
                try shellOut(to: .gitCheckout(branch: branch, force: force ?? false), at: checkoutPath)
                po(tip: "======【\(pro.name)】Checkout完成======", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
        }
    }
    
    struct All: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "all",
            _superCommandName: "checkout",
            abstract: "checkout all",
            version: "1.0.0")
        @Argument(help: "Checkout branch")
        var branch: String
        
        @Argument(help: "子模块名称！")
        var force: Bool?
        
        @Argument(help: "工程存放路径！")
        var path: String?

        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Checkout工程开始======", type: .tip)
            
            do {
                try shellOut(to: .gitCheckout(branch: branch, force: force ?? false), at: project.directoryPath)
                po(tip: "【\(project.name)】Checkout完成", type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            
            for record in project.recordList {
        
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                do {
                    try shellOut(to: .gitCheckout(branch: branch, force: force ?? false), at: pro.directoryPath)
                    po(tip: "【\(pro.name)】Checkout完成", type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip:  error.message + error.output,type: .error)
                }
            }
            
            po(tip: "======Checkout工程结束======")
        }
    }
}




