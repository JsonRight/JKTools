//
//  Clone.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation
extension JKTool.Git {
    struct Clone: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "clone",
            _superCommandName: "git",
            abstract: "利用git clone构建/更新项目结构",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
        @Option(name: .long, help: "移除不在submodules中的submodule，default：false")
        var prune: Bool?
        
        @Option(name: .shortAndLong, help: "执行目录")
        var path: String?
        
        mutating func run() {
            var cloneHistory: [String] = []
            func clone(project:Project) -> [String] {
                var subRecordList:[String] = []
                for module in project.moduleList {
                    // 组装module路径
                    let modulePath = project.rootProject.checkoutsPath + "/" + module.name
                    //通过检查文件夹的方式，检查是否已经存在
                    let needClone = !FileManager.default.fileExists(atPath: modulePath)
                    let isEmpty = FileManager.default.getFileList(directoryPath: modulePath)?.isEmpty

                    // clone module
                    if needClone || isEmpty == true {
                        do {
                            po(tip: "【\(module.name)】开始执行：git clone")
                            let date = Date.init().timeIntervalSince1970
                            try shellOut(to: .gitClone(url: module.url, to: modulePath, branch: module.branch))
                            po(tip: "【\(module.name)】clone成功[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
                            cloneHistory.append(module.name)
                        } catch {
                            let error = error as! ShellOutError
                            po(tip: "【\(module.name)】clone失败：\n" + error.message + error.output,type: .error)
                        }
                    } else if !cloneHistory.contains(module.name) {
                        po(tip: "【\(module.name)】已经存在,无需Clone！",type: .warning)
                        cloneHistory.append(module.name)
                    }
                    
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
            
            if force == true {
                _ = try? shellOut(to: .removeFolder(from: project.checkoutsPath))
            }
            
            po(tip: "======Clone子模块开始======", type: .tip)
            let date = Date.init().timeIntervalSince1970
            let subRecordList = clone(project: project)
            let pruneRecordList = project.writeRecordList(recordList: subRecordList)
            if prune == true {
                for record in pruneRecordList {
                    do {
                        try shellOut(to: .removeFolder(from: "\(project.rootProject.checkoutsPath)/\(record)"),at: project.rootProject.directoryPath)
                        po(tip: "【\(record)】Remove 成功")
                    } catch {
                        let error = error as! ShellOutError
                        po(tip: "【\(record)】Remove 异常" + error.message + error.output,type: .warning)
                    }
                }
            }
            po(tip: "======clone子模块完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }
}



