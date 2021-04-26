//
//  BuildStaticCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/7/3.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class BuildStaticCommon: BaseBuildCommon {
    func librarySuffix() -> String {
        return ".a"
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
                    try shellOut(to: .createSymlink(to: pro.rootProject.buildsPath + "/" + module.name, at: pro.buildsPath))
                } catch {
                    print(Colors.yellow("【\(pro.name)】创建\(module.name)\(librarySuffix()) links 失败，可能已经存在"))
                }
            }
        }
        
        do {
            try shellOut(to: .removeFolder(from: pro.buildPath))
        } catch {
            print(Colors.yellow("【\(pro.name)】\(librarySuffix()) 历史Build 删除失败"))
        }
        
        do {
            try shellOut(to: .removeFolder(from: pro.rootProject.buildsPath + "/\(pro.name)"))
        } catch {
            print(Colors.yellow("【\(pro.name)】\(librarySuffix()) 删除失败"))
        }
        
//        do {
//            try shellOut(to:.buildStaticIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath, toStaticPath: pro.rootBuildsPath + "/" + pro.name))
//        } catch  {
//            print(Colors.red("【\(pro.name)】.a Build失败"))
//            let error = error as! ShellOutError
//            print(error.message) // Prints STDERR
//            print(error.output) // Prints STDOUT
//            exit(EXIT_FAILURE)
//        }
        
        let needMerge = options.config == ConfigType("Debug")
        
        if needMerge {
            do {
                try shellOut(to:.buildDebugStaticIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath))
            } catch  {
                print(Colors.red("【\(pro.name)】\(librarySuffix()) Build Debug 失败"))
                let error = error as! ShellOutError
                print(error.message) // Prints STDERR
                print(error.output) // Prints STDOUT
                exit(EXIT_FAILURE)
            }
        }
        
        do {
            try shellOut(to:.buildReleaseStaticIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath))
        } catch  {
            print(Colors.red("【\(pro.name)】\(librarySuffix()) Build Release 失败"))
            let error = error as! ShellOutError
            print(error.message) // Prints STDERR
            print(error.output) // Prints STDOUT
            exit(EXIT_FAILURE)
        }
        
        do {
            try shellOut(to:.lipoCreateStaticIOS(projectName: pro.name, derivedDataPath: pro.buildPath, toStaticPath: pro.rootProject.buildsPath + "/" + pro.name, needMerge: needMerge))
        } catch  {
            print(Colors.red("【\(pro.name)】\(librarySuffix()) Build merge 失败"))
            let error = error as! ShellOutError
            print(error.message) // Prints STDERR
            print(error.output) // Prints STDOUT
            exit(EXIT_FAILURE)
        }
        
        do {
            try shellOut(to: .copyStaticHeaderIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath, toHeaderPath: pro.rootProject.buildsPath + "/" + pro.name))
        } catch  {
            print(Colors.red("【\(pro.name)】copy头文件 失败"))
            let error = error as! ShellOutError
            print(error.message) // Prints STDERR
            print(error.output) // Prints STDOUT
            exit(EXIT_FAILURE)
        }
        
        if !pro.fileManager.fileExists(atPath: pro.directoryPath + "/" + pro.name + "Bundle") {
           return
        }
        do {
            try shellOut(to:.buildBundleIOS(projectName: pro.name, projectFilePath: pro.directoryPath + "/" + pro.name + ".xcodeproj", derivedDataPath: pro.buildPath, toBundlePath: pro.rootProject.buildsPath + "/" + pro.name))
        } catch  {
            print(Colors.red("【\(pro.name)】.bundle Build失败"))
            let error = error as! ShellOutError
            print(error.message) // Prints STDERR
            print(error.output) // Prints STDOUT
            exit(EXIT_FAILURE)
        }
    }
}
