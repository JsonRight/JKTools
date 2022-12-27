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
            abstract: "build部分命令对于固定工程格式封装",
            version: "1.0.0",
            subcommands: [Clean.self,Static.self,Framework.self,XCFramework.self,Unknown.self],
            defaultSubcommand: Unknown.self, helpNames: nil)
    }
}

private struct Options: ParsableArguments {
    
    @Option(name: .long, help: "仅编译，不使用缓存策略，不做后续处理，default：false")
    var simpleBuild: Bool = false
    
    @Option(name: .long, help: "是否使用缓存，default：true")
    var cache: Bool = true
    
    @Option(name: .shortAndLong, help: "代码环境，default：Release")
    var configuration: String = "Release"
    
    @Option(name: .shortAndLong, help: "设备类型，default：iOS")
    var sdk: String = "iOS"
    
    /*
     xcodebuild -workspace {...}.xcworkspace -scheme {...} -showBuildSettings  -destination "generic/platform=iOS"
     @Option(name: .shortAndLong, help: ".xcconfig路径")
     var xcconfigPath: String?
     */
    
    @Option(name: .shortAndLong, help: "执行路径")
    var path: String?
}

extension JKTool.Build {
    
    struct Clean: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "clean",
            _superCommandName: "build",
            abstract: "清除所有Universal中的编译产物",
            version: "1.0.0")

        mutating func run() {
            
            func clean(project:Project) {
                po(tip:"【\(project.destination)】clean开始")
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/" + project.destination))
                
                _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                
                _ = try? shellOut(to: .removeFolder(from: project.buildPath + "/Universal/"))
                
                
                po(tip:"【\(project.destination)】clean完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                
                clean(project: project)
                
               return
            }
            
            
            po(tip: "======Clean 项目开始======")
            let date = Date.init().timeIntervalSince1970
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    continue
                }
                clean(project: subProject)
                
            }
            
            po(tip: "======Clean 项目完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }

    struct Static: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "static",
            _superCommandName: "build",
            abstract: "编译成.a文件",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            
            func build(project:Project) {
                po(tip:"【\(project.destination)】build开始")
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧.a相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/" + project.destination))
                
                let configuration = options.configuration
                let sdk = options.sdk
                
                guard let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) else {
                    return po(tip: "\(project.directoryPath)无法解析出正确的项目",type: .error)
                }
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/"))
                let status = try? shellOut(to: .gitStatus(),at: project.directoryPath)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.directoryPath)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                
                func buildStatic(project:Project){
                    // 创建Module/Builds link 依赖库
                    if project.recordList.count > 0 {
                        _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                        
                        _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                        
                        for moduleName in project.recordList {
                            guard let link = Project.project(directoryPath: project.rootProject.checkoutsPath + "/" + moduleName) else {
                                return po(tip: "\(project.rootProject.buildsPath + "/" + moduleName)目录没有检索到工程", type: .error)
                            }
                            
                            if link.projectType.vaild() {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                            } else {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.checkoutsPath + "/" + moduleName, at: project.buildsPath))
                            }
                        }
                    }
                    let toStaticPath =  options.simpleBuild ? nil : (project.rootProject.buildsPath + "/" + project.destination)
                    let toHeaderPath =  options.simpleBuild ? nil : (project.rootProject.buildsPath + "/" + project.destination)
                    
                    let staticCommand = ShellOutCommand.staticBuild(scheme: scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk,verison: options.simpleBuild ? "Products" : currentVersion,toStaticPath: toStaticPath,toHeaderPath: toHeaderPath)
                    do {
                        try shellOut(to: staticCommand, at: project.directoryPath)
                        po(tip: "【\(project.destination)】.a Build成功",type: .tip)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.a Build失败\n" +  error.message + error.output,type: .error)
                    }
                }
                
                func buildBundle(project:Project){
                    if project.bundleName == "" {
                       return
                    }
                    let toBundlePath =  options.simpleBuild ? nil : (project.rootProject.buildsPath + "/" + project.destination)
                    
                    let buildCommand = ShellOutCommand.buildBundle(bundleName:project.bundleName,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, verison: options.simpleBuild ? "Products" : currentVersion, toBundlePath: toBundlePath)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                        po(tip: "【\(project.destination)】.bundle Build成功",type: .tip)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                if options.simpleBuild || options.cache == false || oldVersion != currentVersion {
                    po(tip:"【\(project.destination)】需重新编译")

                    // 删除历史build文件
                    let cachePath = options.simpleBuild ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                    _ = try? shellOut(to: .removeFolder(from: cachePath))
                    
                    buildStatic(project: project)
                    
                    buildBundle(project: project)
                    
                    
                } else {
                    let toStaticPath =  project.rootProject.buildsPath + "/" + project.destination
                    let toHeaderPath =  project.rootProject.buildsPath + "/" + project.destination
                    let staticCommand = ShellOutCommand.staticWithCache(scheme: scheme, derivedDataPath: project.buildPath, verison: currentVersion,toStaticPath: toStaticPath,toHeaderPath: toHeaderPath)
                    do {
                        try shellOut(to: staticCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.a copy失败\n" +  error.message + error.output,type: .warning)
                        buildStatic(project: project)
                    }
                    
                    if project.bundleName != "" {
                        let toBundlePath =  project.rootProject.buildsPath + "/" + project.destination
                        let buildCommand = ShellOutCommand.bundleWithCache(bundleName:project.bundleName, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: toBundlePath)
                        do {
                            try shellOut(to: buildCommand, at: project.directoryPath)
                        } catch  {
                            let error = error as! ShellOutError
                            po(tip: "【\(project.destination)】.bundle copy失败\n" + error.message + error.output,type: .warning)
                            buildBundle(project: project)
                        }
                    }
                    
                }
                
                po(tip:"【\(project.destination)】build完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project)
                
               return
            }
            
            guard project.recordList.count > 0 else {
                
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project)

               return
            }
            
            po(tip: "======Static build项目开始======")
            let date = Date.init().timeIntervalSince1970
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    continue
                }
                build(project: subProject)
                
            }
            
            po(tip: "======Static build项目完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }
    
    struct Framework: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "framework",
            _superCommandName: "build",
            abstract: "编译成.framework文件",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            
            func build(project:Project) {
                po(tip:"【\(project.destination)】build开始")
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧.framework相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/" + project.destination))
                
                let configuration = options.configuration
                let sdk = options.sdk
                
                guard let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) else {
                    return po(tip: "\(project.directoryPath)无法解析出正确的项目",type: .error)
                }
                
                let oldVersion = (try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/")))
                let status = try? shellOut(to: .gitStatus(),at: project.directoryPath)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.directoryPath)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                func buildFramework(project:Project){
                    // 创建Module/Builds link 依赖库
                    if project.recordList.count > 0 {
                        
                        _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                        _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                        
                        for moduleName in project.recordList {
                            guard let link = Project.project(directoryPath: project.rootProject.checkoutsPath + "/" + moduleName) else {
                                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
                            }
                            
                            if link.projectType.vaild() {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                            } else {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.checkoutsPath + "/" + moduleName, at: project.buildsPath))
                            }
                        }
                    }
                    let toPath =  options.simpleBuild ? nil : (project.rootProject.buildsPath + "/" + project.destination)
                    let frameworkCommand = ShellOutCommand.frameworkBuild(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk, verison: options.simpleBuild ? "Products" : currentVersion, toPath: toPath)
                    
                    do {
                        try shellOut(to: frameworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.framework Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                func buildBundle(project:Project){
                    
                    if project.bundleName == "" {
                       return
                    }
                    let toBundlePath =  options.simpleBuild ? nil : (project.rootProject.buildsPath + "/" + project.destination)
                    let buildCommand = ShellOutCommand.buildBundle(bundleName:project.bundleName,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, verison: options.simpleBuild ? "Products" : currentVersion, toBundlePath: toBundlePath)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                if options.simpleBuild || options.cache == false || !String(oldVersion ?? "").contains(currentVersion) {
                    po(tip:"【\(project.destination)】需重新编译")
                
                    /// 删除历史build文件
                    let cachePath = options.simpleBuild ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                    _ = try? shellOut(to: .removeFolder(from: cachePath))
                    
                    buildFramework(project: project)
                    
                    buildBundle(project: project)
                } else {
                    let toPath =  project.rootProject.buildsPath + "/" + project.destination
                    let frameworkCommand = ShellOutCommand.frameworkWithCache(scheme: scheme, derivedDataPath: project.buildPath, verison: currentVersion, toPath: toPath)
                    do {
                        try shellOut(to: frameworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.framework copy失败\n" + error.message + error.output,type: .warning)
                        buildFramework(project: project)
                    }
                    
                    if project.bundleName != "" {
                        let toBundlePath =  project.rootProject.buildsPath + "/" + project.destination
                        let buildCommand = ShellOutCommand.bundleWithCache(bundleName:project.bundleName, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: toBundlePath)
                        do {
                            try shellOut(to: buildCommand, at: project.directoryPath)
                        } catch  {
                            let error = error as! ShellOutError
                            po(tip: "【\(project.destination)】.bundle copy失败\n" + error.message + error.output,type: .warning)
                            buildBundle(project: project)
                        }
                    }
                    
                }
                
                po(tip:"【\(project.destination)】build完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project)

               return
            }
            
            guard project.recordList.count > 0 else {
                
                if !project.projectType.vaild() {
                    return
                }
                build(project: project)

               return
            }
            
            po(tip: "======Framework build项目开始======")
            let date = Date.init().timeIntervalSince1970
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    continue
                }
                build(project: subProject)
                
            }
            
            po(tip: "======Framework build项目完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }
    
    struct XCFramework: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "xcframework",
            _superCommandName: "build",
            abstract: "编译成.xcframework文件",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            
            func build(project:Project) {
                po(tip:"【\(project.destination)】build开始")
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧.xcframework相关文件
                _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + project.destination))
                
                let configuration = options.configuration
                let sdk = options.sdk
                
                guard let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) else {
                    return po(tip: "\(project.directoryPath)无法解析出正确的项目",type: .error)
                }
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/"))
                let status = try? shellOut(to: .gitStatus(),at: project.directoryPath)
                let code = try? shellOut(to: .gitCodeVerison(),at: project.directoryPath)
                
                let currentVersion  = ShellOutCommand.MD5(string: "\(status ?? "")\(code ?? "")")
                func buildXCFramework(project:Project){
                    // 创建Module/Builds link 依赖库
                    if project.recordList.count > 0 {
                        
                        _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                        _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                        
                        for moduleName in project.recordList {
                            guard let link = Project.project(directoryPath: project.rootProject.checkoutsPath + "/" + moduleName) else {
                                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
                            }
                            
                            if link.projectType.vaild() {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                            } else {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.checkoutsPath + "/" + moduleName, at: project.buildsPath))
                            }
                        }
                    }
                    
                    let toPath =  options.simpleBuild ? nil : (project.rootProject.buildsPath + "/" + project.destination)
                    
                    let xcframeworkCommand = ShellOutCommand.xcframeworkBuild(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk, verison: options.simpleBuild ? "Products" : currentVersion, toPath: toPath)
                    
                    do {
                        try shellOut(to: xcframeworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.xcframework Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                func buildBundle(project:Project){
                    
                    if project.bundleName == "" {
                       return
                    }
                    
                    let toBundlePath =  options.simpleBuild ? nil : (project.rootProject.buildsPath + "/" + project.destination)
                    let buildCommand = ShellOutCommand.buildBundle(bundleName:project.bundleName,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, verison: options.simpleBuild ? "Products" : currentVersion, toBundlePath: toBundlePath)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                if options.simpleBuild || options.cache == false || oldVersion != currentVersion {
                    po(tip:"【\(project.destination)】需重新编译")
                    
                    // 删除历史build文件
                    let cachePath = options.simpleBuild ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                    _ = try? shellOut(to: .removeFolder(from: cachePath))
                    
                    buildXCFramework(project: project)
                    buildBundle(project: project)
                    
                }else{
                    let toPath =  project.rootProject.buildsPath + "/" + project.destination
                    let xcframeworkCommand = ShellOutCommand.xcframeworkWithCache(scheme:scheme, derivedDataPath: project.buildPath, verison: currentVersion, toPath: toPath)
                    
                    do {
                        try shellOut(to: xcframeworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(project.destination)】.xcframework copy失败\n" + error.message + error.output,type: .warning)
                        buildXCFramework(project: project)
                    }
                    
                    if project.bundleName != "" {
                        let toBundlePath =  project.rootProject.buildsPath + "/" + project.destination
                        let buildCommand = ShellOutCommand.bundleWithCache(bundleName:project.bundleName, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: toBundlePath)
                        do {
                            try shellOut(to: buildCommand, at: project.directoryPath)
                        } catch  {
                            let error = error as! ShellOutError
                            po(tip: "【\(project.destination)】.bundle copy失败\n" + error.message + error.output,type: .warning)
                            buildBundle(project: project)
                        }
                    }
                    
                }
                po(tip:"【\(project.destination)】build完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                build(project: project)
                
               return
            }
            guard project.recordList.count > 0 else {
                
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project)

               return
            }
            
            po(tip: "======XCFramework build项目开始======")
            let date = Date.init().timeIntervalSince1970
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    return
                }
                build(project: subProject)
                
            }
            
            po(tip: "======XCFramework build项目完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }
    
    struct Unknown: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "unknown",
            _superCommandName: "build",
            abstract: "动态解析项目编译成.a｜.framework文件",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            func build(project:Project) {
                switch project.buildType {
                case .Framework:
                    JKTool.Build.Framework.main(["--simple-build","\(options.simpleBuild)","--cache","\(options.cache)","--configuration","\(options.configuration)","--sdk","\(options.sdk)","--path","\(project.directoryPath)"])
                case .Static:
                    JKTool.Build.Static.main(["--simple-build","\(options.simpleBuild)","--cache","\(options.cache)","--configuration","\(options.configuration)","--sdk","\(options.sdk)","--path","\(project.directoryPath)"])
                case .Other:
                    po(tip:"【\(project.destination)】无法检测出是Static或者Framework", type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project)
                
               return
            }
            
            
            guard project.recordList.count > 0 else {
                
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project)

               return
            }
            
            po(tip: "======Unknown build项目开始======")
            let date = Date.init().timeIntervalSince1970
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                if !subProject.projectType.vaild() {
                    continue
                }
                build(project: subProject)
            }
            
            po(tip: "======Unknown build项目完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }
}

