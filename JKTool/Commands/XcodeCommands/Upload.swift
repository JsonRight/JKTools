//
//  Upload.swift
//  JKTool
//
//  Created by 姜奎 on 2022/7/11.
//

import Foundation


extension JKTool {
    struct Upload: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "upload",
            _superCommandName: "JKTool",
            abstract: "upload部分命令对于固定工程格式封装",
            version: "1.0.0",
            subcommands: [AccountAuth.self,ApiAuth.self,Export.self])
    }
}

extension JKTool.Upload {
    struct AccountAuth: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "account",
            _superCommandName: "upload",
            abstract: "upload account",
            version: "1.0.0")

        @Argument(help: "内容格式请参照：JKTool config")
        var configPath: String
        
        @Argument(help: "执行路径")
        var path: String?

        mutating func run() {
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath(absolutPath: path ?? FileManager.default.currentDirectoryPath))) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            po(tip: "======Upload项目开始======")
            let date = Date.init().timeIntervalSince1970
            
            do {
                try shellOut(to: .upload(path: configs.uploadConfig.ipaPath.convertRelativePath(absolutPath: path ?? FileManager.default.currentDirectoryPath), username: configs.uploadConfig.accountAuthConfig!.username, password: configs.uploadConfig.accountAuthConfig!.password))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Upload项目完成 用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")
        }
    }
    struct ApiAuth: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "api",
            _superCommandName: "upload",
            abstract: "upload api",
            version: "1.0.0")

        @Argument(help: "内容格式请参照：JKTool config")
        var configPath: String
        
        @Argument(help: "执行路径")
        var path: String?
        
        mutating func run() {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath(absolutPath: path ?? FileManager.default.currentDirectoryPath))) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            po(tip: "======Upload项目开始======")
            let date = Date.init().timeIntervalSince1970
            
            do {
                try shellOut(to: .installApiP8(apiKey: configs.uploadConfig.apiAuthConfig!.apiKey, authKeyPath: configs.uploadConfig.apiAuthConfig!.authKeyPath))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            do {
                try shellOut(to: .upload(path: configs.uploadConfig.ipaPath.convertRelativePath(absolutPath: path ?? FileManager.default.currentDirectoryPath), apiKey: configs.uploadConfig.apiAuthConfig!.apiKey, apiIssuerID: configs.uploadConfig.apiAuthConfig!.apiIssuerID))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Upload项目完成 用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")
        }
    }
    struct Export: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "export",
            _superCommandName: "upload",
            abstract: "upload export",
            version: "1.0.0")
        
        @Argument(help: "Debug/Release...")
        var configuration: String
        
        @Argument(help: "Scheme")
        var scheme: String
        
        @Argument(help: "内容格式请参照：JKTool config")
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
            
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath(absolutPath: project.directoryPath))) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            po(tip: "======Upload项目开始======")
            let date = Date.init().timeIntervalSince1970
            do {
                try shellOut(to: .upload(scheme: scheme, projectPath: project.directoryPath, configuration: configuration, export: configs.exportConfig.exportOptionsPath))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Upload项目完成 用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")
        }
    }
}







