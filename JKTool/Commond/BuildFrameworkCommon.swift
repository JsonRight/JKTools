//
//  BuildFrameworkCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/17.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class BuildFrameworkCommon: BaseBuildCommon {
    func librarySuffix() -> String {
        return ".framework"
    }

    func build(pro: Project,options: ConsoleOptions) {
        
        if pro.moduleList.count > 0 {
            do {
                try shellOut(to: .createFolder(path: pro.buildsPath + "/"))
            } catch {
                print(Colors.yellow("【\(pro.name)】创建 Module/Builds 失败，可能已经存在"))
            }
            
            for module in pro.moduleList {
                do {
                    try shellOut(to: .createSymlink(to: pro.rootProject.buildsPath + "/" + module.name + librarySuffix(), at: pro.buildsPath))
                } catch {
                    print(Colors.yellow("【\(pro.name)】创建\(module.name)\(librarySuffix()) links 失败，可能已经存在"))
                }
            }
        }
        
        let version = try? shellOut(to: .readVerisonIOS(plistPath: pro.rootProject.buildsPath + "/" + pro.name + librarySuffix(), plistName: "Info"))
        let status = try? shellOut(to: .gitStatus(),at: pro.rootProject.checkoutsPath + "/" + pro.name)
        var codeVersion = try? shellOut(to: .gitCodeVerison(),at: pro.rootProject.checkoutsPath + "/" + pro.name)
        if status != nil && status != "" {
            codeVersion = MD5(string: status!)
        }
        
        if options.cache && version == codeVersion {
            print(Colors.green("【\(pro.name)】无需重新编译"))
            return
        }else{
            print(Colors.green("【\(pro.name)】需重新编译"))
        }
        
        do {
            try shellOut(to: .removeFolder(from: pro.buildPath))
        } catch {
            print(Colors.yellow("【\(pro.name)】删除历史Build 失败"))
        }
        
        let needMerge = options.config == ConfigType("Debug")
        
        if needMerge {
            do {
                try shellOut(to:.buildDebugFrameworkIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath))
            } catch {
                print(Colors.red("【\(pro.name)】\(librarySuffix()) Build Debug 失败"))
                let error = error as! ShellOutError
                echoError(name: pro.name, filePath: pro.buildPath + "/" + "error.log", content: error.message + error.output)
                exit(EXIT_FAILURE)
            }
        }
        
        do {
            try shellOut(to:.buildReleaseFrameworkIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath))
        } catch {
            print(Colors.red("【\(pro.name)】\(librarySuffix()) Build Release 失败"))
            let error = error as! ShellOutError
            echoError(name: pro.name, filePath: pro.buildPath + "/" + "error.log", content: error.message + error.output)
            exit(EXIT_FAILURE)
        }
        
        do {
            try shellOut(to: .removeFolder(from: pro.rootProject.buildsPath + "/\(pro.name)\(librarySuffix())"))
        } catch {
            print(Colors.yellow("【\(pro.name)】\(librarySuffix()) 删除失败"))
        }
        
        do {
            try shellOut(to:.lipoCreateFrameworkIOS(projectName: pro.name, derivedDataPath: pro.buildPath, toPath: pro.rootProject.buildsPath, needMerge: needMerge))
        } catch {
            print(Colors.red("【\(pro.name)】\(librarySuffix()) merge 失败"))
            let error = error as! ShellOutError
            echoError(name: pro.name, filePath: pro.buildPath + "/" + "error.log", content: error.message + error.output)
            exit(EXIT_FAILURE)
        }
        
        do {
            try shellOut(to: .writeVerisonIOS(plistPath: pro.rootProject.buildsPath + "/" + pro.name + librarySuffix(), plistName: "Info",verison: codeVersion ?? ""))
        } catch {
            print(Colors.yellow("【\(pro.name)】\(librarySuffix()) 写入代码版本号失败"))
        }
        
        if !pro.fileManager.fileExists(atPath: pro.directoryPath + "/" + pro.name + "Bundle") {
           return
        }
        do {
            try shellOut(to:.buildBundleIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath, toBundlePath: pro.rootProject.buildsPath + "/" + pro.name + librarySuffix()))
        } catch {
            print(Colors.yellow("【\(pro.name)】.bundle Build失败"))
            let error = error as! ShellOutError
            echoError(name: pro.name, filePath: pro.buildPath + "/" + "error.log", content: error.message + error.output)
            exit(EXIT_FAILURE)
        }
    }
}
