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
//        if project.fileManager.fileExists(atPath: project.rootProject.modulePath) {
//
//        }
//        do {
//            try shellOut(to: .removeFolder(from: project.rootProject.modulePath))
//        } catch {
//            print(Colors.yellow("Clone 命令执行异常！删除工程Module文件夹失败"))
//        }
        
        let subRecordList = self.clone(pro: project.rootProject)
        var recordList:[String] = []
        for item in subRecordList {
            if !recordList.contains(item) {
                recordList.append(item)
            }
        }
        let oldRecordList = project.recordList
        if oldRecordList.isEmpty || !recordList.elementsEqual(oldRecordList)  {
            do {
                let data = try JSONSerialization.data(withJSONObject: recordList, options: .fragmentsAllowed)
                try data.write(to: URL(fileURLWithPath: project.rootProject.recordListPath), options: .atomicWrite)
                print(Colors.green("【\(project.name)】Modulefile.recordList 写入成功"))
            } catch {
                print(Colors.yellow("【\(project.name)】Modulefile.recordList 写入失败"))
            }
        }
        
        print(Colors.green("======clone子模块结束======"))
    }
    
    func clone(pro: Project) -> [String] {
        var subRecordList:[String] = []
        for module in pro.moduleList {
            // 组装module路径
            let modulePath = pro.rootProject.checkoutsPath + "/" + module.name
            //通过检查文件夹的方式，检查是否已经存在
            let needClone = !pro.fileManager.fileExists(atPath: modulePath)
            // clone module
            if needClone {
                do {
                    try shellOut(to: .gitClone(url: module.url, to: modulePath))
                    print(Colors.green("【\(module.name)】:clone成功"))
                } catch {
                    print(Colors.yellow("【\(module.name)】已经存在,无需Clone！"))
                }
            }
            //创建module的Project
            guard let subModule = Project.project(directoryPath: modulePath) else {
                print(Colors.red("【\(module.name)】初始化失败，请检查项目"))
                exit(EXIT_FAILURE)
            }
            // 递归Clone subModule
            let list = self.clone(pro: subModule)
            updateSubModule(module: pro, subModule: subModule, needClone: needClone, subRecordList: list)
            
            subRecordList += list
            // 将module加入即将需要subModule中
            subRecordList.append(module.name)
        }
        
        return subRecordList
    }
    
    func updateSubModule(module: Project, subModule: Project, needClone: Bool, subRecordList: Array<String>) {
        // 检查是否还有subModule。没有则直接return
        if subRecordList.isEmpty {
            return
        }
        
        // 过滤当前module的subModule，按照工程层级
        var recordList:[String] = []
        for item in subRecordList {
            if !recordList.contains(item) {
                recordList.append(item)
            }
        }
//         当前Project如果不是根Project则创建子Project的工程软链接
//        if module.rootProject != module {
//            //删除当前subModule的checkoutsPath
//            do {
//                try shellOut(to: .removeFolder(from: module.checkoutsPath))
//            } catch {
//                print(Colors.yellow("【\(module.name)】Clone 命令执行异常！删除工程Module文件夹失败"))
//            }
//            //重建当前subModule的checkoutsPath
//            do {
//                try shellOut(to: .createFolder(path: module.checkoutsPath))
//            } catch {
//                print(Colors.yellow("【\(module.name)】创建'checkouts'目录 失败，可能已经存在"))
//            }
//            //创建子Project的工程软链接
//            for item in recordList {
//                let subModulePath = module.rootProject.checkoutsPath + "/" + item
//                do {
//                    try shellOut(to: .createSymlink(to: subModulePath, at: module.checkoutsPath))
//                    print(Colors.green("【\(module.name)】创建\(item) links 成功"))
//                } catch {
//                    print(Colors.yellow("【\(module.name)】创建\(item) links 失败，可能已经存在"))
//                }
//            }
//        }
        // 写入当前工程所有subModule
        if needClone {
            
            let oldRecordList = subModule.recordList
            if oldRecordList.isEmpty || !recordList.elementsEqual(oldRecordList)  {
                do {
                    let data = try JSONSerialization.data(withJSONObject: recordList, options: .fragmentsAllowed)
                    try data.write(to: URL(fileURLWithPath: subModule.recordListPath), options: .atomicWrite)
                    print(Colors.green("【\(subModule.name)】Modulefile.recordList 写入成功"))
                } catch {
                    print(Colors.yellow("【\(subModule.name)】Modulefile.recordList 写入失败"))
                }
            }
        }
    }
    
    
}
