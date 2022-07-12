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
    
    @Argument(help: "执行日志")
    var quiet: Bool?
    
    @Argument(help: "是否使用缓存，default：true")
    var cache: Bool?

    @Argument(help: "代码环境，default：Release")
    var configuration: String?
    
    @Argument(help: "设备类型，default：iOS")
    var sdk: String?

    @Argument(help: "执行路径")
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
                
                let configuration = options.configuration ?? "Release"
                let sdk = options.sdk ?? "iOS"
                
                let json = try? shellOut(to: .list(isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath), at: project.directoryPath)
                
                guard let data = json?.data(using: .utf8), let configs = try? JSONDecoder().decode(ProjectListsModel.self, from:data), let scheme = findScheme(schemes: configs.project.schemes, projectName: project.name) else {
                    return po(tip: "\(project.directoryPath)无法解析出正确的项目",type: .error)
                }
                
                func findScheme(schemes:[String], projectName: String) ->String?{
                    var scheme: String?
                    if schemes.contains(projectName) {
                        scheme = projectName
                    } else {
                        for sch in schemes {
                            if sch.contains(projectName) && sch.contains(sdk) {
                                scheme = sch
                                break
                            }
                        }
                        scheme = schemes.first
                    }
                    return scheme
                }
                
                
                // 创建Module/Builds link 依赖库
                if project.recordList.count > 0 {
                    _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                    
                    for moduleName in project.recordList {
                        guard let project = Project.project(directoryPath: project.rootProject.buildsPath + "/" + moduleName) else {
                            return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
                        }
                        
                        if project.projectType.vaild() {
                            _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                        }
                    }
                }
                
                // 删除主项目旧.a相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/" + project.name))
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Build/Products/Universal/"))
                let status = try? shellOut(to: .gitStatus(),at: project.directoryPath)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.directoryPath)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                
                
                
                if options.cache == false || oldVersion != currentVersion {
                    if options.quiet != false {po(tip:"【\(project.name)】需重新编译")}
                    // 删除历史build文件
                    _ = try? shellOut(to: .removeFolder(from: project.buildPath))
                    
                    let staticCommand = ShellOutCommand.staticBuild(scheme: scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk,verison: currentVersion,toStaticPath: project.rootProject.buildsPath + "/" + project.name,toHeaderPath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: staticCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.a Build失败\n" +  error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.buildBundle(scheme: scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                } else {
                    let staticCommand = ShellOutCommand.staticWithCache(scheme: scheme, derivedDataPath: project.buildPath, verison: currentVersion,toStaticPath: project.rootProject.buildsPath + "/" + project.name,toHeaderPath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: staticCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.a copy失败\n" +  error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.bundleWithCache(scheme: scheme, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.bundle copy失败\n" + error.message + error.output,type: .error)
                    }
                }
                
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject != project else {
                if !project.projectType.vaild() {
                    return
                }
                if options.quiet != false {po(tip:"【\(project.name)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: project)
                if options.quiet != false {po(tip:"【\(project.name)】build 完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
               return
            }
            
            if options.quiet != false {po(tip: "======Static build项目开始======")}
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    continue
                }
                if options.quiet != false {po(tip:"【\(subProject.name)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: subProject)
                if options.quiet != false {po(tip:"【\(subProject.name)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
                
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
                
                let configuration = options.configuration ?? "Release"
                let sdk = options.sdk ?? "iOS"
                
                let jsonStr = try? shellOut(to: .list(isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath), at: project.directoryPath)
                
                guard let data = jsonStr?.data(using: .utf8), let configs = try? JSONDecoder().decode(ProjectListsModel.self, from:data), let scheme = findScheme(schemes: configs.project.schemes, projectName: project.name) else {
                    return po(tip: "\(project.directoryPath)无法解析出正确的项目",type: .error)
                }
                
                func findScheme(schemes:[String],projectName: String) ->String?{
                    var scheme: String?
                    if schemes.contains(projectName) {
                        scheme = projectName
                    } else {
                        for sch in schemes {
                            if sch.contains(projectName) && sch.contains(sdk) {
                                scheme = sch
                                break
                            }
                        }
                        scheme = schemes.first
                    }
                    return scheme
                }
                // 创建Module/Builds link 依赖库
                if project.recordList.count > 0 {
                    _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                    
                    for moduleName in project.recordList {
                        guard let project = Project.project(directoryPath: project.rootProject.buildsPath + "/" + moduleName) else {
                            return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
                        }
                        
                        if project.projectType.vaild() {
                            _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                        }
                    }
                }
                
                // 删除主项目旧.framework相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/" + project.name))
                
                let oldVersion = (try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/")))
                let status = try? shellOut(to: .gitStatus(),at: project.directoryPath)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.directoryPath)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                
                if options.cache == false || !String(oldVersion ?? "").contains(currentVersion) {
                    if options.quiet != false {po(tip:"【\(project.name)】需重新编译")}
                    
                    // 删除历史build文件
                    _ = try? shellOut(to: .removeFolder(from: project.buildPath))
                    
                    let frameworkCommand = ShellOutCommand.frameworkBuild(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk, verison: currentVersion, toPath: project.rootProject.buildsPath + "/" + project.name)
                    
                    do {
                        try shellOut(to: frameworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.framework Build失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.buildBundle(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                } else {
                    let frameworkCommand = ShellOutCommand.frameworkWithCache(scheme: scheme, derivedDataPath: project.buildPath, verison: currentVersion, toPath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: frameworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.framework copy失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.bundleWithCache(scheme:scheme, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.bundle copy失败\n" + error.message + error.output,type: .error)
                    }
                }
                
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                if options.quiet != false {po(tip:"【\(project.name)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: project)
                if options.quiet != false {po(tip:"【\(project.name)】build 完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
               return
            }
            
            if options.quiet != false {po(tip: "======Framework build项目开始======")}
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    continue
                }
                if options.quiet != false {po(tip:"【\(subProject.name)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: subProject)
                if options.quiet != false {po(tip:"【\(subProject.name)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
                
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
                
                let configuration = options.configuration ?? "Release"
                let sdk = options.sdk ?? "iOS"
                
                let json = try? shellOut(to: .list(isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath), at: project.directoryPath)
                
                guard let data = json?.data(using: .utf8), let configs = try? JSONDecoder().decode(ProjectListsModel.self, from:data), let scheme = findScheme(schemes: configs.project.schemes, projectName: project.name) else {
                    return po(tip: "\(project.directoryPath)无法解析出正确的项目",type: .error)
                }
                
                func findScheme(schemes:[String],projectName: String) ->String?{
                    var scheme: String?
                    if schemes.contains(projectName) {
                        scheme = projectName
                    } else {
                        for sch in schemes {
                            if sch.contains(projectName) && sch.contains(sdk) {
                                scheme = sch
                                break
                            }
                        }
                        scheme = schemes.first
                    }
                    return scheme
                }
                
                // 创建Module/Builds link 依赖库
                if project.recordList.count > 0 {
                    _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                    
                    for moduleName in project.recordList {
                        guard let project = Project.project(directoryPath: project.rootProject.buildsPath + "/" + moduleName) else {
                            return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
                        }
                        
                        if project.projectType.vaild() {
                            _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                        }
                    }
                }
                
                // 删除主项目旧.framework相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + project.name))
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Build/Products/Universal/"))
                let status = try? shellOut(to: .gitStatus(),at: project.directoryPath)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.directoryPath)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                
                if options.cache == false || oldVersion != currentVersion {
                    if options.quiet != false {po(tip:"【\(project.name)】需重新编译")}
                    
                    // 删除历史build文件
                    _ = try? shellOut(to: .removeFolder(from: project.buildPath))
                    
                    let xcframeworkCommand = ShellOutCommand.xcframeworkBuild(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk, verison: currentVersion, toPath: project.rootProject.buildsPath + "/" + project.name)
                    
                    do {
                        try shellOut(to: xcframeworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.xcframework Build失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.buildBundle(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        print(Colors.red("【\(project.name)】.bundle Build失败"))
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }else{
                    let xcframeworkCommand = ShellOutCommand.xcframeworkWithCache(scheme:scheme, derivedDataPath: project.buildPath, verison: currentVersion, toPath: project.rootProject.buildsPath + "/" + project.name)
                    
                    do {
                        try shellOut(to: xcframeworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.xcframework copy失败\n" + error.message + error.output,type: .error)
                    }
                    
                    if !project.fileManager.fileExists(atPath: project.directoryPath + "/" + scheme + "Bundle") {
                       return
                    }
                    let buildCommand = ShellOutCommand.bundleWithCache(scheme:scheme, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: project.rootProject.buildsPath + "/" + project.name)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        print(Colors.red("【\(project.name)】.bundle Build失败"))
                        let error = error as! ShellOutError
                        po(tip: "【\(project.name)】.bundle copy失败\n" + error.message + error.output,type: .error)
                    }
                }
                
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                if options.quiet != false {po(tip:"【\(project.name)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: project)
                if options.quiet != false {po(tip:"【\(project.name)】build 完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
               return
            }
            
            if options.quiet != false { po(tip: "======XCFramework build项目开始======")}
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    return
                }
                if options.quiet != false { po(tip:"【\(subProject.name)】build 开始")}
                let date = Date.init().timeIntervalSince1970
                build(project: subProject)
                if options.quiet != false {po(tip:"【\(subProject.name)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")}
                
            }
            
            if options.quiet != false {po(tip: "======XCFramework build项目完成======")}
        }
    }
}

