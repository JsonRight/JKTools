//
//  CloneCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/17.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
class CloneCommon: CommonProtocol {
   
    func run(options: ConsoleOptions) {
        
        guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
            print(Colors.red("当前目录没有检索到工程"))
            exit(EXIT_FAILURE)
        }
        
        guard project.rootProject == project else {
            print(Colors.red("请在项目根目录执行脚本"))
            exit(EXIT_FAILURE)
        }
        print(Colors.green("======Clone子模块开始======"))
        do {
            try shellOut(to: .removeFolder(from: project.rootProject.modulePath))
        } catch {
            print(Colors.yellow("Clone 命令执行异常！删除工程Module文件夹失败"))
        }
        
        let list = self.clone(pro: project.rootProject)
        var recordList:[String] = []
        for item in list.reversed() {
            if !recordList.contains(item) {
                recordList.append(item)
            }
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: recordList, options: .fragmentsAllowed)
            try data.write(to: URL(fileURLWithPath: project.rootProject.recordListPath), options: .atomicWrite)
            print(Colors.green("Modulefile.recordList 写入成功"))
        } catch {
            print(Colors.yellow("Modulefile.recordList 写入失败"))
        }
        print(Colors.green("======clone子模块结束======"))
    }
    
    func clone(pro: Project) -> [String] {
        var recordList:[String] = []
        for module in pro.moduleList {
            do {
                try shellOut(to: .gitClone(url: module.url, to: pro.rootProject.checkoutsPath + "/" + module.name))
                print(Colors.green("\(module.name):clone成功"))
            } catch {
                print(Colors.yellow("\(module.name) 已经存在,无需Clone！"))
            }
            if pro.rootProject != pro {
                do {
                    try shellOut(to: .createFolder(path: pro.checkoutsPath))
                } catch {
                    print(Colors.yellow("【\(pro.name)】创建'checkouts'目录 失败，可能已经存在"))
                }
                
                do {
                    try shellOut(to: .createSymlink(to: pro.rootProject.checkoutsPath + "/" + module.name, at: pro.checkoutsPath))
                    print(Colors.green("【\(pro.name)】创建\(module.name) links 成功"))
                } catch {
                    print(Colors.yellow("【\(pro.name)】创建\(module.name) links 失败，可能已经存在"))
                }
            }
            
            guard let pro1 = Project.project(directoryPath: "\(pro.rootProject.checkoutsPath)/\(module.name)") else {
                print(Colors.red("\(module.name)初始化失败，请检查项目"))
                exit(EXIT_FAILURE)
            }
            let list = self.clone(pro: pro1)
            recordList.append(module.name)
            recordList += list
            
        }
        
        return recordList
    }
    
    
}
