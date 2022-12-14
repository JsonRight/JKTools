//
//  Clone.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

extension JKTool.Git.SubModule {
    struct Update: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "update",
            _superCommandName: "submodule",
            abstract: "Update",
            version: "1.0.0",
            subcommands: [Sub.self,All.self],
            defaultSubcommand: Sub.self)
        
    }
}

extension JKTool.Git.SubModule.Update {
    struct Sub: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "sub",
            _superCommandName: "submodule",
            abstract: "Update SubModule",
            version: "1.0.0")
        
        @Argument(help: "移除不在SubModule中的SubProject，default：false")
        var prune: Bool?
        
        @Argument(help: "更新 submodule 为远程项目的最新版本，default：false")
        var remote: Bool?
        
        @Argument(help: "执行目录")
        var path: String?
        
        mutating func run() {
            var cloneHistory: [String] = []
            
            func clone(project:Project) -> [String] {
                let submodules = try? shellOut(to: .gitSubmoduleStatus(),at: project.rootProject.directoryPath)
                var subRecordList:[String] = []
                for module in project.moduleList {
                
                    if !cloneHistory.contains(module.name) {
                        if let submodules = submodules, submodules.contains(module.name) {
                            
                            do {
                                try shellOut(to: .gitSubmoduleUpdate(remote: remote ?? false,path: "\(JKToolConfig.sharedInstance.config.checkouts)/\(module.name)"),at: project.rootProject.directoryPath)
                                po(tip: "【\(module.name)】已存在， update 成功")

                            } catch {
                                let error = error as! ShellOutError
                                po(tip:"【\(module.name)】已存在， update 异常" + error.message + error.output,type: .warning)
                            }
                        }else {
                            
                            do {
                                try shellOut(to: .gitSubmoduleAdd(name: module.name,url: module.url, path: "\(JKToolConfig.sharedInstance.config.checkouts)/\(module.name)"),at: project.rootProject.directoryPath)
                                po(tip: "【\(module.name)】:Add 成功")
                            } catch {
                                let error = error as! ShellOutError
                                po(tip: "【\(module.name)】:Add 异常" + error.message + error.output,type: .warning)
                            }
                        }
                    }
                    
                    cloneHistory.append(module.name)
                    // 组装module路径
                    let modulePath = project.rootProject.checkoutsPath + "/" + module.name
                    
                    //创建module的Project
                    if let subModule = Project.project(directoryPath: modulePath) {
                        // 递归Clone subModule
                        let list = clone(project: subModule)
                        _ = subModule.writeRecordList(recordList: list)
                        
                        subRecordList += list
                        // 将module加入即将需要subModule中
                        subRecordList.append(module.name)
                    }else{
                        po(tip: "【\(module.name)】初始化失败，请检查项目",type: .error)
                    }
                }
                
                return subRecordList
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Update SubModule or Add SubModule开始======", type: .tip)
            
            let subRecordList = clone(project: project)
            
            let pruneRecordList = project.writeRecordList(recordList: subRecordList)
            if prune == true {
                for record in pruneRecordList {
                    do {
                        try shellOut(to: .gitSubmoduleRemove(path: "\(JKToolConfig.sharedInstance.config.checkouts)/\(record)"),at: project.rootProject.directoryPath)
                        po(tip: "【\(record)】:Remove 成功")
                    } catch {
                        let error = error as! ShellOutError
                        po(tip: "【\(record)】:Remove 异常" + error.message + error.output,type: .error)
                    }
                }
            }
            po(tip: "======Update SubModule or Add SubModule完成======")
        }
    }
    
    struct All: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "all",
            _superCommandName: "submodule",
            abstract: "Clone Project and Update SubModule",
            version: "1.0.0")

        @Argument(help: "项目git地址")
        var url: String
        
        @Argument(help: "保存目录【绝对路径】")
        var path: String
        
        @Argument(help: "更新 submodule 为远程项目的最新版本，default：false")
        var remote: Bool?
        
        @Argument(help: "分支名")
        var branch: String?
        
        mutating func run() {
            
            po(tip: "======开始准备Clone Project and Update SubModule项目======")
            do {
                try shellOut(to: .removeFolder(from: path))
            } catch {
                po(tip: "\(path) 无法删除",type: .warning)
            }
            do {
                try shellOut(to: .gitClone(url: url, to: path, branch: branch))
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            JKTool.Git.SubModule.Update.Sub.main(["\(false)","\(remote ?? false)",path])
            po(tip: "======Clone Project and Update SubModule项目完成======")
        }
    }
}



