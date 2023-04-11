//
//  Build.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

private struct Options: ParsableArguments {
    
    @Option(name: .long, help: "是否使用缓存，default：true")
    var cache: Bool?
    
    @Option(name: .shortAndLong, help: "代码环境，default：Release")
    var configuration: String?
    
    @Option(name: .shortAndLong, help: "设备类型，default：iOS")
    var sdk: String?
    
    @Option(name: .long, help: "对Bundle进行签名，default：true")
    var signBundle: Bool?
    
    /*
     xcodebuild -workspace {...}.xcworkspace -scheme {...} -showBuildSettings  -destination "generic/platform=iOS"
     @Option(name: .shortAndLong, help: ".xcconfig路径")
     var xcconfigPath: String?
     */
    
    @Option(name: .shortAndLong, help: "执行路径")
    var path: String?
    
    @Option(name: .long, help: "build产物副本存储路径【copyPath/{*.a\\*.framework\\*.xcframework\\Header}】")
    var copyPath: String?
    
    @Option(name: .long, help: "检查本地是否有自定义脚本，若有则执行自定义脚本[{projectPath}/build.sh]")
    var checkCustomBuildScript: Bool?
    
    
    func encode(appedingCopyPath:Bool, projectPath: String?) -> Array<String> {
        var args = [String]()
        if let cache = cache {
            args.append(contentsOf: ["--cache",String(cache)])
        }
        if let configuration = configuration {
            args.append(contentsOf: ["--configuration",String(configuration)])
        }
        if let sdk = sdk {
            args.append(contentsOf: ["--sdk",String(sdk)])
        }
        
        if let signBundle = signBundle {
            args.append(contentsOf: ["--sign-bundle",String(signBundle)])
        }
        
        if appedingCopyPath, let copyPath = copyPath {
            args.append(contentsOf: ["--copy-path",String(copyPath)])
        }
        
        if let projectPath = projectPath {
            args.append(contentsOf: ["--path",String(projectPath)])
        }
        
        if let checkCustomBuildScript = checkCustomBuildScript {
            args.append(contentsOf: ["--check-custom-build-script",String(checkCustomBuildScript)])
        }
        
        return args
      }
}

extension JKTool {
    struct Build: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "build",
            _superCommandName: "JKTool",
            abstract: "build部分命令对于固定工程格式封装",
            version: "1.0.0",
            subcommands: [Clean.self,Static.self,Framework.self,XCFramework.self, Other.self])
        
        @OptionGroup private var options: Options

        mutating func run() {
            func build(project:Project,appedingCopyPath:Bool) {
                
                let args = options.encode(appedingCopyPath:appedingCopyPath,projectPath: project.directoryPath)
                
                switch project.buildType {
                case .Framework:
                    JKTool.Build.Framework.main(args)
                case .Static:
                    JKTool.Build.Static.main(args)
                case .Application:
                    break
                case .Other:
                    JKTool.Build.Other.main(args)
                }
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            guard project.rootProject == project else {
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project, appedingCopyPath: true)
                
               return
            }
            
            
            guard project.recordList.count > 0 else {
                
                if !project.projectType.vaild() {
                    return
                }
                
                build(project: project, appedingCopyPath: true)

               return
            }
            
            po(tip: "======build项目开始======")
            let date = Date.init().timeIntervalSince1970
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                
                build(project: subProject, appedingCopyPath: false)
            }
            
            switch project.buildType {
                case .Static,.Framework:
                    build(project: project, appedingCopyPath: true)
                default: break
            }
            
            po(tip: "======build项目完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }
}


extension JKTool.Build {
    
    struct Clean: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "clean",
            _superCommandName: "build",
            abstract: "清除所有Universal中的编译产物",
            version: "1.0.0")

        @Option(name: .shortAndLong, help: "设备类型，default：iOS")
        var sdk: String?
        
        /*
         xcodebuild -workspace {...}.xcworkspace -scheme {...} -showBuildSettings  -destination "generic/platform=iOS"
         @Option(name: .shortAndLong, help: ".xcconfig路径")
         var xcconfigPath: String?
         */
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func clean(project:Project) {
                
                let sdk = sdk ?? "iOS"
                
                let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
                
                po(tip:"【\(scheme)】clean开始")
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧相关文件
                if project != project.rootProject {
                    _ = try? shellOut(to: .removeFolder(from: project.rootProject.buildsPath + "/" + scheme))
                }
                
                _ = try? shellOut(to: .removeFolder(from: project.buildPath + "/Universal/"))
                
                _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                
                
                po(tip:"【\(scheme)】clean完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
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
            
            let cache = options.cache ?? true
            let configuration = options.configuration ?? "Release"
            let sdk = options.sdk ?? "iOS"
            let signBundle = options.signBundle ?? true
            
            func build(project:Project) {
                
                let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
                
                po(tip:"【\(scheme)】build开始")
                
                let isRootProject = (project == project.rootProject)
                
                let copyPath = isRootProject ? options.copyPath: (options.copyPath ?? project.rootProject.buildsPath + "/" + scheme)
                
                let date = Date.init().timeIntervalSince1970
                // 删除旧.a相关文件
                if let copyPath = copyPath {
                    _ = try? shellOut(to: .removeFolder(from: copyPath))
                }
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/"))
                let status = try? shellOut(to: .gitDiffHEAD(),at: project.directoryPath)
                let commitId = try? shellOut(to: .gitCurrentCommitId(),at: project.directoryPath)
                
                let currentVersion  =  String.safeString(string: commitId).appendingBySeparator(ShellOutCommand.MD5(string: String.safeString(string: status))).appendingBySeparator(configuration).appendingBySeparator(sdk)
                let hasCache = oldVersion?.contains(currentVersion) ?? false
                
                func buildStatic(project:Project){
                    // 创建Module/Builds link 依赖库
                    if project.recordList.count > 0 {
                        _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                        
                        _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                        
                        for moduleName in project.recordList {
                            guard let link = Project.project(directoryPath: project.rootProject.checkoutsPath + "/" + moduleName) else {
                                return po(tip: "\(project.rootProject.buildsPath + "/" + moduleName)目录不存在", type: .error)
                            }
                            
                            if link.projectType.vaild() {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                            } else {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.checkoutsPath + "/" + moduleName, at: project.buildsPath))
                            }
                        }
                    }
                    let toStaticPath =  copyPath
                    let toHeaderPath =  copyPath
                    
                    let staticCommand = ShellOutCommand.staticBuild(scheme: scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk,dstPath: project.dstPath,verison: isRootProject ? "Products" : currentVersion,toStaticPath: toStaticPath,toHeaderPath: toHeaderPath)
                    do {
                        try shellOut(to: staticCommand, at: project.directoryPath)
                        po(tip: "【\(scheme)】.a Build成功",type: .tip)
                    } catch  {
                        let error = error as! ShellOutError
                        project.writeBuildLog(log: error.message + error.output)
                        po(tip: "【\(scheme)】.a Build失败\n" +  error.message + error.output,type: .error)
                    }
                }
                
                func buildBundle(project:Project){
                    if project.bundleName == "" {
                       return
                    }
                    let toBundlePath =  copyPath
                    
                    let buildCommand = ShellOutCommand.buildBundle(bundleName:project.bundleName,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, codeSignAllowed: signBundle, verison: isRootProject ? "Products" : currentVersion, toBundlePath: toBundlePath)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                        po(tip: "【\(scheme)】.bundle Build成功",type: .tip)
                    } catch  {
                        let error = error as! ShellOutError
                        project.writeBuildBundleLog(log: error.message + error.output)
                        po(tip: "【\(scheme)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                if isRootProject || cache == false || !hasCache {
                    po(tip:"【\(scheme)】需重新编译")

                    // 删除历史build文件
                    let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                    _ = try? shellOut(to: .removeFolder(from: cachePath))
                    
                    buildStatic(project: project)
                    
                    buildBundle(project: project)
                    
                    
                } else {
                    po(tip:"【\(scheme)】尝试读取缓存")
                    guard let toStaticPath =  copyPath else {
                        let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                        po(tip: "\(cachePath)已经存在缓存，请确认是否需要重新编译,如果缓存不可用,请手动删除，再重新编译", type: .warning)
                        return
                    }
                    guard let toHeaderPath =  copyPath else {
                        let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                        po(tip: "\(cachePath)已经存在缓存，请确认是否需要重新编译,如果缓存不可用,请手动删除，再重新编译", type: .warning)
                        return
                    }
                    let staticCommand = ShellOutCommand.staticWithCache(scheme: scheme,projectPath: project.directoryPath, derivedDataPath: project.buildPath, verison: currentVersion,toStaticPath: toStaticPath,toHeaderPath: toHeaderPath)
                    do {
                        try shellOut(to: staticCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(scheme)】.a copy失败\n" +  error.message + error.output,type: .warning)
                        buildStatic(project: project)
                    }
                    
                    if project.bundleName != "" {
                        guard let toBundlePath =  copyPath else {
                            let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                            po(tip: "\(cachePath)已经存在缓存，请确认是否需要重新编译,如果缓存不可用,请手动删除，再重新编译", type: .warning)
                            return
                        }
                        let buildCommand = ShellOutCommand.bundleWithCache(bundleName:project.bundleName,projectPath: project.directoryPath, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: toBundlePath)
                        do {
                            try shellOut(to: buildCommand, at: project.directoryPath)
                        } catch  {
                            let error = error as! ShellOutError
                            po(tip: "【\(scheme)】.bundle copy失败\n" + error.message + error.output,type: .warning)
                            buildBundle(project: project)
                        }
                    }
                    
                }
                
                po(tip:"【\(scheme)】build完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
            
            if options.checkCustomBuildScript == true, FileManager.default.fileExists(atPath: project.directoryPath + "/build.sh") {
                do {
                    po(tip:"【\(scheme)】执行build.sh")
                    let msg = try shellOut(to: ShellOutCommand(string: "chmod +x build.sh && ./build.sh \(scheme) \(configuration) \(sdk) \(signBundle) \(project.directoryPath)"),at: project.directoryPath)
                    po(tip:"\(msg)")
                } catch  {
                    let error = error as! ShellOutError
                    po(tip: "【\(scheme)】build.sh run error：\n" + error.message + error.output,type: .error)
                }
                return
            }
            
            if !project.projectType.vaild() {
                return
            }
            
            if project.buildType != .Static {
                return
            }
            
            build(project: project)
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
            
            let cache = options.cache ?? true
            let configuration = options.configuration ?? "Release"
            let sdk = options.sdk ?? "iOS"
            let signBundle = options.signBundle ?? true
            
            func build(project:Project) {
                
                let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
                
                po(tip:"【\(scheme)】build开始")
                let isRootProject = (project == project.rootProject)
                
                let copyPath = isRootProject ? options.copyPath: (options.copyPath ?? project.rootProject.buildsPath + "/" + scheme)
                
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧.framework相关文件
                if let copyPath = copyPath {
                    _ = try? shellOut(to: .removeFolder(from: copyPath))
                }
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/"))
                let status = try? shellOut(to: .gitDiffHEAD(),at: project.directoryPath)
                let commitId = try? shellOut(to: .gitCurrentCommitId(),at: project.directoryPath)
                
                let currentVersion  =  String.safeString(string: commitId).appendingBySeparator(ShellOutCommand.MD5(string: String.safeString(string: status))).appendingBySeparator(configuration).appendingBySeparator(sdk)
                let hasCache = oldVersion?.contains(currentVersion) ?? false
                
                func buildFramework(project:Project){
                    // 创建Module/Builds link 依赖库
                    if project.recordList.count > 0 {
                        
                        _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                        _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                        
                        for moduleName in project.recordList {
                            guard let link = Project.project(directoryPath: project.rootProject.checkoutsPath + "/" + moduleName) else {
                                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
                            }
                            
                            if link.projectType.vaild() {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                            } else {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.checkoutsPath + "/" + moduleName, at: project.buildsPath))
                            }
                        }
                    }
                    let toPath =  copyPath
                    let frameworkCommand = ShellOutCommand.frameworkBuild(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk, verison: isRootProject ? "Products" : currentVersion, toPath: toPath)
                    
                    do {
                        let msg = try shellOut(to: frameworkCommand, at: project.directoryPath)
                        po(tip: msg)
                    } catch  {
                        let error = error as! ShellOutError
                        project.writeBuildLog(log: error.message + error.output)
                        po(tip: "【\(scheme)】.framework Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                func buildBundle(project:Project){
                    
                    if project.bundleName == "" {
                       return
                    }
                    let toBundlePath =  copyPath
                    let buildCommand = ShellOutCommand.buildBundle(bundleName:project.bundleName,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, codeSignAllowed: signBundle, verison: isRootProject ? "Products" : currentVersion, toBundlePath: toBundlePath)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        project.writeBuildBundleLog(log: error.message + error.output)
                        po(tip: "【\(scheme)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                if isRootProject || cache == false || !hasCache {
                    po(tip:"【\(scheme)】需重新编译")
                
                    /// 删除历史build文件
                    let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                    _ = try? shellOut(to: .removeFolder(from: cachePath))
                    
                    buildFramework(project: project)
                    
                    buildBundle(project: project)
                } else {
                    po(tip:"【\(scheme)】尝试读取缓存")
                    guard let toPath =  copyPath else {
                        let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                        po(tip: "\(cachePath)已经存在缓存，请确认是否需要重新编译,如果缓存不可用,请手动删除，再重新编译", type: .warning)
                        return
                    }
                    let frameworkCommand = ShellOutCommand.frameworkWithCache(scheme: scheme,projectPath: project.directoryPath, derivedDataPath: project.buildPath, verison: currentVersion, toPath: toPath)
                    do {
                        try shellOut(to: frameworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(scheme)】.framework copy失败\n" + error.message + error.output,type: .warning)
                        buildFramework(project: project)
                    }
                    
                    if project.bundleName != "" {
                        guard let toBundlePath =  copyPath else {
                            let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                            po(tip: "\(cachePath)已经存在缓存，请确认是否需要重新编译,如果缓存不可用,请手动删除，再重新编译", type: .warning)
                            return
                        }
                        let buildCommand = ShellOutCommand.bundleWithCache(bundleName:project.bundleName,projectPath: project.directoryPath, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: toBundlePath)
                        do {
                            try shellOut(to: buildCommand, at: project.directoryPath)
                        } catch  {
                            let error = error as! ShellOutError
                            po(tip: "【\(scheme)】.bundle copy失败\n" + error.message + error.output,type: .warning)
                            buildBundle(project: project)
                        }
                    }
                    
                }
                
                po(tip:"【\(scheme)】build完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
            
            if options.checkCustomBuildScript == true, FileManager.default.fileExists(atPath: project.directoryPath + "/build.sh") {
                
                do {
                    po(tip:"【\(scheme)】执行build.sh")
                    let msg = try shellOut(to: ShellOutCommand(string: "chmod +x build.sh && ./build.sh \(scheme) \(configuration) \(sdk) \(signBundle) \(project.directoryPath)"),at: project.directoryPath)
                    po(tip:"\(msg)")
                } catch  {
                    let error = error as! ShellOutError
                    po(tip: "【\(scheme)】build.sh run error：\n" + error.message + error.output,type: .error)
                }
                return
            }
            
            if !project.projectType.vaild() {
                return
            }
            
            if project.buildType != .Framework {
                return
            }
            
            build(project: project)
            
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
            
            let cache = options.cache ?? true
            let configuration = options.configuration ?? "Release"
            let sdk = options.sdk ?? "iOS"
            let signBundle = options.signBundle ?? true
            
            func build(project:Project) {
                
                let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
                
                po(tip:"【\(scheme)】build开始")
                let isRootProject = (project == project.rootProject)

                let copyPath = isRootProject ? options.copyPath: (options.copyPath ?? project.rootProject.buildsPath + "/" + scheme)
                
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧.xcframework相关文件
                if let copyPath = copyPath {
                    _ = try? shellOut(to: .removeFolder(from: copyPath))
                }
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/"))
                let status = try? shellOut(to: .gitDiffHEAD(),at: project.directoryPath)
                let commitId = try? shellOut(to: .gitCurrentCommitId(),at: project.directoryPath)
                
                let currentVersion  =  String.safeString(string: commitId).appendingBySeparator(ShellOutCommand.MD5(string: String.safeString(string: status))).appendingBySeparator(configuration).appendingBySeparator(sdk)
                let hasCache = oldVersion?.contains(currentVersion) ?? false
                
                func buildXCFramework(project:Project){
                    // 创建Module/Builds link 依赖库
                    if project.recordList.count > 0 {
                        
                        _ = try? shellOut(to: .removeFolder(from: project.buildsPath + "/"))
                        _ = try? shellOut(to: .createFolder(path: project.buildsPath + "/"))
                        
                        for moduleName in project.recordList {
                            guard let link = Project.project(directoryPath: project.rootProject.checkoutsPath + "/" + moduleName) else {
                                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
                            }
                            
                            if link.projectType.vaild() {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.buildsPath + "/" + moduleName, at: project.buildsPath))
                            } else {
                                _ = try? shellOut(to: .createSymlink(to: project.rootProject.checkoutsPath + "/" + moduleName, at: project.buildsPath))
                            }
                        }
                    }
                    
                    let toPath =  copyPath
                    
                    let xcframeworkCommand = ShellOutCommand.xcframeworkBuild(scheme:scheme,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, configuration: configuration, sdk: sdk, verison: isRootProject ? "Products" : currentVersion, toPath: toPath)
                    
                    do {
                        try shellOut(to: xcframeworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        project.writeBuildLog(log: error.message + error.output)
                        po(tip: "【\(scheme)】.xcframework Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                
                func buildBundle(project:Project){
                    
                    if project.bundleName == "" {
                       return
                    }
                    
                    let toBundlePath =  copyPath
                    let buildCommand = ShellOutCommand.buildBundle(bundleName:project.bundleName,isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath, derivedDataPath: project.buildPath, sdk: sdk, codeSignAllowed: signBundle, verison: isRootProject ? "Products" : currentVersion, toBundlePath: toBundlePath)
                    do {
                        try shellOut(to: buildCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        project.writeBuildBundleLog(log: error.message + error.output)
                        po(tip: "【\(scheme)】.bundle Build失败\n" + error.message + error.output,type: .error)
                    }
                }
                if isRootProject || cache == false || !hasCache {
                    po(tip:"【\(scheme)】需重新编译")
                    
                    // 删除历史build文件
                    let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                    _ = try? shellOut(to: .removeFolder(from: cachePath))
                    
                    buildXCFramework(project: project)
                    buildBundle(project: project)
                    
                }else{
                    po(tip:"【\(scheme)】尝试读取缓存")
                    guard let toPath =  copyPath else {
                        let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                        po(tip: "\(cachePath)已经存在缓存，请确认是否需要重新编译,如果缓存不可用,请手动删除，再重新编译", type: .warning)
                        return
                    }
                    let xcframeworkCommand = ShellOutCommand.xcframeworkWithCache(scheme:scheme,projectPath: project.directoryPath, derivedDataPath: project.buildPath, verison: currentVersion, toPath: toPath)
                    
                    do {
                        try shellOut(to: xcframeworkCommand, at: project.directoryPath)
                    } catch  {
                        let error = error as! ShellOutError
                        po(tip: "【\(scheme)】.xcframework copy失败\n" + error.message + error.output,type: .warning)
                        buildXCFramework(project: project)
                    }
                    
                    if project.bundleName != "" {
                        guard let toBundlePath =  copyPath else {
                            let cachePath = isRootProject ? (project.buildPath + "/Universal"): (project.buildPath + "/Universal/\(currentVersion)")
                            po(tip: "\(cachePath)已经存在缓存，请确认是否需要重新编译,如果缓存不可用,请手动删除，再重新编译", type: .warning)
                            return
                        }
                        let buildCommand = ShellOutCommand.bundleWithCache(bundleName:project.bundleName,projectPath: project.directoryPath, derivedDataPath: project.buildPath, verison: currentVersion, toBundlePath: toBundlePath)
                        do {
                            try shellOut(to: buildCommand, at: project.directoryPath)
                        } catch  {
                            let error = error as! ShellOutError
                            po(tip: "【\(scheme)】.bundle copy失败\n" + error.message + error.output,type: .warning)
                            buildBundle(project: project)
                        }
                    }
                    
                }
                po(tip:"【\(scheme)】build完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
            
            if options.checkCustomBuildScript == true, FileManager.default.fileExists(atPath: project.directoryPath + "/build.sh") {
                do {
                    po(tip:"【\(scheme)】执行build.sh")
                    let msg = try shellOut(to: ShellOutCommand(string: "chmod +x build.sh && ./build.sh \(scheme) \(configuration) \(sdk) \(signBundle) \(project.directoryPath)"),at: project.directoryPath)
                    po(tip:"\(msg)")
                } catch  {
                    let error = error as! ShellOutError
                    po(tip: "【\(scheme)】build.sh run error：\n" + error.message + error.output,type: .error)
                }
                return
            }
            
            if !project.projectType.vaild() {
                return
            }
            
            if project.buildType != .Framework {
                return
            }
            
            build(project: project)
              
        }
    }
    
    struct Other: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "other",
            _superCommandName: "build",
            abstract: "直接引用路径中的文件",
            version: "1.0.0")

        @OptionGroup private var options: Options

        mutating func run() {
            
            let configuration = options.configuration ?? "Release"
            let sdk = options.sdk ?? "iOS"
            let signBundle = options.signBundle ?? true
            
            func build(project:Project) {
                
                let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
                
                po(tip:"【\(scheme)】不是一个可编译项目，将直接引用此目录。")
                let isRootProject = (project == project.rootProject)
                let copyPath = isRootProject ? options.copyPath: (options.copyPath ?? project.rootProject.buildsPath + "/" + scheme)
                
                let date = Date.init().timeIntervalSince1970
                // 删除主项目旧.framework相关文件
                if let copyPath = copyPath {
                    _ = try? shellOut(to: .removeFolder(from: copyPath))
                    
                    _ = try? shellOut(to: .copyFile(from: project.directoryPath, to: copyPath))
                }
                
                po(tip:"【\(scheme)】Copy完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]")
            }
            
            guard let project = Project.project(directoryPath: options.path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
            
            if options.checkCustomBuildScript == true, FileManager.default.fileExists(atPath: project.directoryPath + "/build.sh") {
                do {
                    po(tip:"【\(scheme)】执行build.sh")
                    let msg = try shellOut(to: ShellOutCommand(string: "chmod +x build.sh && ./build.sh \(scheme) \(configuration) \(sdk) \(signBundle) \(project.directoryPath)"),at: project.directoryPath)
                    po(tip:"\(msg)")
                } catch  {
                    let error = error as! ShellOutError
                    po(tip: "【\(scheme)】build.sh run error：\n" + error.message + error.output,type: .error)
                }
                return
            }
            
            switch project.buildType {
                case .Framework:
                    po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)检测到可以使用Framework编译，请确认命令", type: .warning)
                case .Static:
                    po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)检测到可以使用Framework编译，请确认命令", type: .warning)
                case .Application:
                    po(tip: "\(options.path ?? FileManager.default.currentDirectoryPath)检测到是一个App，请确认命令", type: .warning)
                case .Other:
                    build(project: project)
            }
        }
    }
}
