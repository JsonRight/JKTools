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
            version: "1.0.0",
            subcommands: [Init.self])
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
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
                    let needClone = !project.fileManager.fileExists(atPath: modulePath)

                    // clone module
                    if needClone {
                        do {
                            try shellOut(to: .gitClone(url: module.url, to: modulePath, branch: module.branch))
                            po(tip: "【\(module.name)】:clone成功")
                            cloneHistory.append(module.name)
                        } catch {
                            let error = error as! ShellOutError
                            po(tip:  error.message + error.output,type: .error)
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
            
            let subRecordList = clone(project: project)
            _ = project.writeRecordList(recordList: subRecordList)
            po(tip: "======clone子模块完成======")
        }
    }
}


extension JKTool.Git.Clone {
    struct Init: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "init",
            _superCommandName: "clone",
            abstract: "clone项目，并利用git clone构建/更新项目结构",
            version: "1.0.0")

        @Option(name: .shortAndLong, help: "项目git地址")
        var url: String
        
        @Option(name: .shortAndLong, help: "保存目录【绝对路径】")
        var path: String
        
        @Option(name: .shortAndLong, help: "强制 clone，default：false")
        var force: Bool?
        
        @Option(name: .shortAndLong, help: "分支名")
        var branch: String?
        
        mutating func run() {
            
            po(tip: "======开始准备clone项目======")
            let exist = FileManager.default.fileExists(atPath: path)
            
            if force == true && exist {
                do {
                    try shellOut(to: .removeFolder(from: path))
                } catch {
                    po(tip: "\(path) 无法删除",type: .error)
                }
            }
            do {
                try shellOut(to: .gitClone(url: url, to: path, branch: branch))
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            
            var args = [String]()
            
            if let force = force {
                args.append(contentsOf: ["--force",String(force)])
            }
            
            args.append(contentsOf: ["--path",String(path)])
            
            JKTool.Git.Clone.main(args)
            po(tip: "======clone项目完成======")
        }
    }
}



