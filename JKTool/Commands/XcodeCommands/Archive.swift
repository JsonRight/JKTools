//
//  Archive.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/22.
//

import Foundation

extension JKTool {
    struct Archive: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "archive",
            _superCommandName: "JKTool",
            abstract: "archive",
            version: "1.0.0",
            subcommands: [Config.self,Scheme.self]
        )
    }
}

struct ArchiveConfigModel: Decodable {
    
    var configuration: String
    
    var scheme: String
    
    var validArchs: [String]?
    
    var macPwd: String
    
    var p12sPath: String
    
    var p12Pwd: String
    
    var profilesPath: String
    
    var sdk: String
    
    var export: String
    
    var quiet: Bool?
    
}


extension JKTool.Archive {
    struct Config: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "config",
            _superCommandName: "archive",
            abstract: "archive config",
            version: "1.0.0")

        @Argument(help: "Archive 本地化配置路径")
        var configPath: String
        
        @Argument(help: "执行路径")
        var path: String?

        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            if configPath.lowercased() == "default" {
                configPath = project.directoryPath + "/defaultCOnfig.json"
            }
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ArchiveConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            if configs.quiet != false {po(tip: "======Archive项目开始======")}
            let date = Date.init().timeIntervalSince1970
            do {
                try shellOut(to: .unlockSecurity(password: configs.macPwd))
            } catch  {
                let error = error as! ShellOutError
                po(tip: "unlockSecurity" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .importP12(p12sPath: configs.p12sPath, password: configs.p12Pwd), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "importP12" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .installProfiles(profilesPath: configs.profilesPath), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "installProfiles:" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .archive(scheme: configs.scheme, isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, configuration: configs.configuration,validArchs: configs.validArchs, sdk: configs.sdk, export: configs.export), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            if configs.quiet != false {po(tip: "======Archive项目完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")}
        }
    }
    struct Scheme: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "scheme",
            _superCommandName: "archive",
            abstract: "archive scheme",
            version: "1.0.0")

        @Argument(help: "archive scheme")
        var scheme: String
        
        @Argument(help: "export.plist存放路径")
        var export: String
        
        @Argument(help: "执行日志")
        var quiet: Bool?
        
        @Argument(help: "代码环境，default：Release")
        var configuration: String?
        
        @Argument(help: "编译架构，default read Xcode VALID_ARCHS：iOS(arm64,armv7)")
        var validArchs: String?
        
        @Argument(help: "设备类型，default：iOS")
        var sdk: String?
        
        @Argument(help: "执行路径")
        var path: String?

        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请使用项目根目录执行脚本", type: .error)
            }
            
            if quiet != false {po(tip: "======Archive项目开始======")}
            let date = Date.init().timeIntervalSince1970
            do {
                try shellOut(to: .archive(scheme: scheme, isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, configuration: configuration ?? "Release", validArchs: (validArchs ?? "").split(separator: ",").map({ $0.base }), sdk: sdk ?? "iOS", export: export))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            if quiet != false {po(tip: "======Archive项目完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")}
        }
    }
}







