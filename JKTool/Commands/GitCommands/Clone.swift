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
            abstract: "clone",
            version: "1.0.0",
            subcommands: [Sub.self, All.self],
            defaultSubcommand: Sub.self)
    }
}

extension JKTool.Git.Clone {
    struct Sub: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "sub",
            _superCommandName: "clone",
            abstract: "clone sub",
            version: "1.0.0")

        @Argument(help: "工程存放路径！")
        var path: String?
        
        @Argument(help: "force Clone")
        var force: Bool?

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
                            try shellOut(to: .gitClone(url: module.url, to: modulePath))
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
                        subModule.writeRecordList(recordList: list)
                        
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
            
            if force ?? false {
                _ = try? shellOut(to: .removeFolder(from: project.checkoutsPath))
            }
            
            po(tip: "======Clone子模块开始======", type: .tip)
            
            let subRecordList = clone(project: project)
            project.writeRecordList(recordList: subRecordList)
            po(tip: "======clone子模块完成======")
        }
    }
    
    struct All: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "all",
            _superCommandName: "clone",
            abstract: "clone all",
            version: "1.0.0")

        @Argument(help: "工程 git url！")
        var url: String
        
        @Argument(help: "工程存放路径！")
        var path: String
        
        @Argument(help: "Clone by branch")
        var branch: String?

        mutating func run() {
            
            po(tip: "======开始准备clone项目======")
            do {
                try shellOut(to: .removeFolder(from: path))
            } catch {
                po(tip: "\(path) 无法删除",type: .warning)
            }
//            guard let urr = URL(string: url) else {
//                return
//            }
//            let session = URLSession.shared
//
//            let path = path
//            var sema = DispatchSemaphore( value: 0 )
//            let task = session.downloadTask(with: urr) { location, response, error in
//
//                guard let locationPath = location?.path else {
//                    return
//                }
//
//                let fileManager = FileManager.default
//                do {
//                    try fileManager.moveItem(atPath: locationPath, toPath: path)
//                } catch {
//                    po(tip: "下载失败",type: .error)
//                }
//                sema.signal()
//            }
//
//            task.resume()
//
//            sema.wait()
            do {
                try shellOut(to: .gitClone(url: url, to: path, branch: branch))
            } catch {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            Sub.main([path])
            po(tip: "======clone项目完成======")
        }
    }
}



