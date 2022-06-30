//
//  Build.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

extension JKTool {
    struct Build: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "build",
            _superCommandName: "JKTool",
            abstract: "build",
            version: "1.0.0",
            subcommands: [Static.self,Framework.self,XCFramework.self],
            defaultSubcommand: Framework.self, helpNames: nil)
    }
}

private struct Options: ParsableArguments {
    
    @Argument(help: "是否输出详细信息！")
    var quiet: Bool?
    
    @Argument(help: "尝试使用缓存")
    var cache: Bool?

    @Argument(help: "default：Release")
    var configuration: String?
    
    @Argument(help: "default：iOS")
    var sdk: String?

    @Argument(help: "工程存放路径")
    var path: String?

}


extension JKTool.Build {

    struct Static: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "static",
            _superCommandName: "build",
            abstract: "build static",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            func build(project:Project) {
                // 创建Module/Builds link 依赖库
                if project.recordList.count > 0 {
                    _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                    
                    for moduleName in project.recordList {
                        _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                    }
                }
                
                // 删除主项目旧.a相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/\(project.scheme)"))
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Build/Products/Universal/"))
                let status = try? shellOut(to: .gitStatus(),at: project.rootProject.checkoutsPath + "/" + project.scheme)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.rootProject.checkoutsPath + "/" + project.scheme)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                
                
                
                if options.cache == false || oldVersion != currentVersion {
                    if options.quiet != false {po(tip:"【\(project.scheme)】需重新编译")}
                    // 删除历史build文件
                    _ = try? shellOut(to: .removeFolder(from: project.buildPath))
                    
                    let staticCommand = ShellOutCommand.staticBuild(scheme: project.scheme, projectPath: project.directoryPath + "/" + project.scheme + ".xcodeproj", derivedDataPath: project.buildPath, configuration: options.configuration ?? "Release", sdk: options.sdk ?? "iOS",verison: currentVersion,toStaticPath: project.rootProject.buildsPath + "/" + project.scheme,toHeaderPath: project.rootProject.buildsPath + "/" + project.scheme)
                    do {
                        try shellOut(to: staticCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.a Build失败\n" +  error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + project.scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.buildBundle(projectName: project.scheme, projectPath: project.directoryPath + "/" + project.scheme + ".xcodeproj", derivedDataPath: project.buildPath, sdk: options.sdk ?? "iOS", verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.scheme)
                    do {
                        try shellOut(to: buildCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                } else {
                    let staticCommand = ShellOutCommand.staticWithCache(projectName: project.scheme, derivedDataPath: project.buildPath, verison: currentVersion,toStaticPath: project.rootProject.buildsPath + "/" + project.scheme,toHeaderPath: project.rootProject.buildsPath + "/" + project.scheme)
                    do {
                        try shellOut(to: staticCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.a copy失败\n" +  error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + project.scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.bundleWithCache(projectName: project.scheme, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.scheme)
                    do {
                        try shellOut(to: buildCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.bundle copy失败\n" + error.message + error.output,type: .error)
                    }
                }
                
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject != project else {
                if options.quiet != false {po(tip:"【\(project.scheme)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: project)
                if options.quiet != false {po(tip:"【\(project.scheme)】build 完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
               return
            }
            
            if options.quiet != false {po(tip: "======Static build项目开始======")}
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                if options.quiet != false {po(tip:"【\(subProject.scheme)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: subProject)
                if options.quiet != false {po(tip:"【\(subProject.scheme)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
                
            }
            
            if options.quiet != false {po(tip: "======Static build项目完成======")}
        }
    }
    
    struct Framework: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "framework",
            _superCommandName: "build",
            abstract: "build framework",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            
            func build(project:Project) {
                // 创建Module/Builds link 依赖库
                if project.recordList.count > 0 {
                    _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                    
                    for moduleName in project.recordList {
                        _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName + ".framework", at: project.buildsPath))
                    }
                }
                
                // 删除主项目旧.framework相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/\(project.scheme).framework"))
                
                let oldVersion = (try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/")))
                let status = try? shellOut(to: .gitStatus(),at: project.rootProject.checkoutsPath + "/" + project.scheme)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.rootProject.checkoutsPath + "/" + project.scheme)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                
                if options.cache == false || !String(oldVersion ?? "").contains(currentVersion) {
                    if options.quiet != false {po(tip:"【\(project.scheme)】需重新编译")}
                    
                    // 删除历史build文件
                    _ = try? shellOut(to: .removeFolder(from: project.buildPath))
                    
                    let frameworkCommand = ShellOutCommand.frameworkBuild(projectName: project.scheme, projectPath: project.directoryPath + "/" + project.scheme + ".xcodeproj", derivedDataPath: project.buildPath, configuration: options.configuration ?? "Release", sdk: options.sdk ?? "iOS", verison: currentVersion, toPath: project.rootProject.buildsPath)
                    
                    do {
                        try shellOut(to: frameworkCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.framework Build失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + project.scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.buildBundle(projectName: project.scheme, projectPath: project.directoryPath + "/" + project.scheme + ".xcodeproj", derivedDataPath: project.buildPath, sdk: options.sdk ?? "iOS", verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.scheme + ".framework")
                    do {
                        try shellOut(to: buildCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                } else {
                    let frameworkCommand = ShellOutCommand.frameworkWithCache(projectName: project.scheme, derivedDataPath: project.buildPath, verison: currentVersion, toPath: project.rootProject.buildsPath)
                    do {
                        try shellOut(to: frameworkCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.framework copy失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + project.scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.bundleWithCache(projectName: project.scheme, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.scheme + ".framework")
                    do {
                        try shellOut(to: buildCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.bundle copy失败\n" + error.message + error.output,type: .error)
                    }
                }
                
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if options.quiet != false {po(tip:"【\(project.scheme)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: project)
                if options.quiet != false {po(tip:"【\(project.scheme)】build 完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
               return
            }
            
            if options.quiet != false {po(tip: "======Framework build项目开始======")}
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                if options.quiet != false {po(tip:"【\(subProject.scheme)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: subProject)
                if options.quiet != false {po(tip:"【\(subProject.scheme)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
                
            }
            
            if options.quiet != false {po(tip: "======Framework build项目完成======")}
        }
    }
    
    struct XCFramework: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "xcframework",
            _superCommandName: "build",
            abstract: "build xcframework",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            func build(project:Project) {
                // 创建Module/Builds link 依赖库
                if project.recordList.count > 0 {
                    _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                    
                    for moduleName in project.recordList {
                        _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName + ".xcframework", at: project.buildsPath))
                    }
                }
                
                // 删除主项目旧.framework相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/\(project.scheme).xcframework"))
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Build/Products/Universal/"))
                let status = try? shellOut(to: .gitStatus(),at: project.rootProject.checkoutsPath + "/" + project.scheme)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.rootProject.checkoutsPath + "/" + project.scheme)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                
                if options.cache == false || oldVersion != currentVersion {
                    if options.quiet != false {po(tip:"【\(project.scheme)】需重新编译")}
                    
                    // 删除历史build文件
                    _ = try? shellOut(to: .removeFolder(from: project.buildPath))
                    
                    let xcframeworkCommand = ShellOutCommand.xcframeworkBuild(projectName: project.scheme, projectPath: project.directoryPath + "/" + project.scheme + ".xcodeproj", derivedDataPath: project.buildPath, configuration: options.configuration ?? "Release", sdk: options.sdk ?? "iOS", verison: currentVersion, toPath: project.rootProject.buildsPath)
                    
                    do {
                        try shellOut(to: xcframeworkCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.xcframework Build失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + project.scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.buildBundle(projectName: project.scheme, projectPath: project.directoryPath + "/" + project.scheme + ".xcodeproj", derivedDataPath: project.buildPath, sdk: options.sdk ?? "iOS", verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.scheme + ".xcframework")
                    do {
                        try shellOut(to: buildCommand)
                    } catch  {
                        print(Colors.red("【\(project.scheme)】.bundle Build失败"))
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }else{
                    let xcframeworkCommand = ShellOutCommand.xcframeworkWithCache(projectName: project.scheme, derivedDataPath: project.buildPath, verison: currentVersion, toPath: project.rootProject.buildsPath)
                    
                    do {
                        try shellOut(to: xcframeworkCommand)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.xcframework copy失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + project.scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.bundleWithCache(projectName: project.scheme, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.scheme + ".xcframework")
                    do {
                        try shellOut(to: buildCommand)
                    } catch  {
                        print(Colors.red("【\(project.scheme)】.bundle Build失败"))
                        let error = error as! ShellOutError
                        po(tip: "【\(project.scheme)】.bundle copy失败\n" + error.message + error.output,type: .error)
                    }
                }
                
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if options.quiet != false {po(tip:"【\(project.scheme)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: project)
                if options.quiet != false {po(tip:"【\(project.scheme)】build 完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
               return
            }
            
            if options.quiet != false { po(tip: "======XCFramework build项目开始======")}
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                if options.quiet != false { po(tip:"【\(subProject.scheme)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: subProject)
                if options.quiet != false {po(tip:"【\(subProject.scheme)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
                
            }
            
            if options.quiet != false {po(tip: "======XCFramework build项目完成======")}
        }
    }
}

