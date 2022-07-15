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
            abstract: "archive部分命令对于固定工程格式封装",
            version: "1.0.0",
            subcommands: [Config.self,Scheme.self],
            defaultSubcommand: Config.self
        )
    }
}

extension JKTool.Archive {
    struct Config: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "config",
            _superCommandName: "archive",
            abstract: "archive config",
            version: "1.0.0")

        @Argument(help: """
                        Archive 本地化配置路径
                        ‘’‘
                        {
                          "activeConfig": {
                            "configuration": "Debug/Release",
                            "scheme": "String",
                            "validArchs": [
                              "arm64 armv7 | x86_64 i386"
                            ],
                            "sdk": "iOS/iPadOS/macOS/tvOS/watchOS/carPlayOS",
                            "export": "export.plist绝对路径",
                            "saveConfig": {
                              "nameSuffix": "String",
                              "path": "绝对路径"
                            }
                          },
                          "certificateConfig": {
                            "macPwd": "mac密码",
                            "p12sPath": "路径",
                            "p12Pwd": "p12文件密码",
                            "profilesPath": "路径"
                          },
                          "uploadConfig": {
                            "username": "appleid账户",
                            "password": "appleid密码",
                            "path": "ipa路径"
                          },
                          "quiet": false
                        }
                        ’‘’
                        """)
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
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath())) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            if configs.quiet != false {po(tip: "======Archive项目开始======")}
            let date = Date.init().timeIntervalSince1970
            do {
                try shellOut(to: .unlockSecurity(password: configs.certificateConfig.macPwd))
            } catch  {
                let error = error as! ShellOutError
                po(tip: "unlockSecurity" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .importP12(p12sPath: configs.certificateConfig.p12sPath.convertRelativePath(), password: configs.certificateConfig.p12Pwd), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "importP12" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .installProfiles(profilesPath: configs.certificateConfig.profilesPath.convertRelativePath()), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "installProfiles:" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .archive(scheme: configs.activeConfig.scheme, isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, configuration: configs.activeConfig.configuration, sdk: configs.activeConfig.sdk, export: configs.activeConfig.export.convertRelativePath(), nameSuffix: configs.activeConfig.saveConfig?.nameSuffix,toSavePath: configs.activeConfig.saveConfig?.path), at: project.directoryPath)
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
        
        @Argument(help: "执行日志，default：true")
        var quiet: Bool?
        
        @Argument(help: "代码环境，default：Release")
        var configuration: String?
        
        @Argument(help: "设备类型，default：iOS")
        var sdk: String?
        
        @Argument(help: "ipa另存地址")
        var toPath: String?
        
        @Argument(help: "ipa名称后缀")
        var nameSuffix: String?
        
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
                try shellOut(to: .archive(scheme: scheme, isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, configuration: configuration ?? "Release", sdk: sdk ?? "iOS", export: export, nameSuffix: nameSuffix,toSavePath: toPath),at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            if quiet != false {po(tip: "======Archive项目完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")}
        }
    }
}







