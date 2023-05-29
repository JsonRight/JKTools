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
            subcommands: [AccountAuth.self,ApiAuth.self])
    }
}

extension JKTool.Upload {
    struct AccountAuth: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "account",
            _superCommandName: "upload",
            abstract: "upload account",
            version: "1.0.0")

        @Option(name: .shortAndLong, help: "导出环境，default：Release")
        var configuration: String = "Release"
        
        @Option(name: .shortAndLong, help: "Scheme")
        var scheme: String
        
        @Option(name: .long, help: "内容格式请参照：JKTool config")
        var configPath: String
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?

        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath(absolutPath: project.directoryPath))) else {
                return po(tip: "请检查配置文件是否存在！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件格式是否正确！",type: .error)
            }
            
            let date = Date.init().timeIntervalSince1970
            let exportPath: String
            
            if let ipaPath = configs.uploadConfig.ipaPath {
                exportPath = ipaPath
                po(tip: "【\(scheme)】配置文件中已指定上传文件(\(exportPath))")
            } else {
                exportPath = configs.needConfigurationInProductsPath == true ? "\(project.buildPath)/\(configuration)/\(scheme).\(Platform(configs.sdk).fileExtension())": "\(project.buildPath)/\(scheme).\(Platform(configs.sdk).fileExtension())"
                po(tip: "【\(scheme)】前往项目目录查找上传文件(\(exportPath))")
            }
            
            guard FileManager.default.fileExists(atPath: exportPath) else {
                return po(tip: "【\(scheme)】没有找到可上传的文件(\(exportPath))",type: .error)
            }
            
            guard let username = configs.uploadConfig.accountAuthConfig?.username,
            let password = configs.uploadConfig.accountAuthConfig?.password else {
                return po(tip: "【\(scheme)】配置文件中未指定(uploadConfig.accountAuthConfig.username/password)",type: .error)
            }
            
            po(tip: "======Upload项目开始======")
            
            do {
                try shellOut(to: .upload(scheme: scheme, path: exportPath, username: username, password: password))
                
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Upload项目完成[\(GlobalConstants.duration(to: date) + " s")]======")
        }
    }
    struct ApiAuth: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "api",
            _superCommandName: "upload",
            abstract: "upload api",
            version: "1.0.0")

        @Option(name: .shortAndLong, help: "导出环境，default：Release")
        var configuration: String = "Release"
        
        @Option(name: .shortAndLong, help: "Scheme")
        var scheme: String
        
        @Option(name: .long, help: "内容格式请参照：JKTool config")
        var configPath: String
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath(absolutPath: project.directoryPath))) else {
                return po(tip: "请检查配置文件是否存在！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件格式是否正确！",type: .error)
            }
            
            let date = Date.init().timeIntervalSince1970
            
            let exportPath: String
            
            if let ipaPath = configs.uploadConfig.ipaPath {
                exportPath = ipaPath
                po(tip: "【\(scheme)】配置中已指定上传文件(\(exportPath))")
            } else {
                exportPath = configs.needConfigurationInProductsPath == true ? "\(project.buildPath)/\(configuration)/\(scheme).\(Platform(configs.sdk).fileExtension())": "\(project.buildPath)/\(scheme).\(Platform(configs.sdk).fileExtension())"
                po(tip: "【\(scheme)】前往项目目录查找上传文件(\(exportPath))")
            }
            
            guard FileManager.default.fileExists(atPath: exportPath) else {
                return po(tip: "【\(scheme)】没有找到可上传的文件(\(exportPath))",type: .error)
            }
            
            guard let apiKey = configs.uploadConfig.apiAuthConfig?.apiKey,
            let apiIssuerID = configs.uploadConfig.apiAuthConfig?.apiIssuerID,
            let authKeyPath = configs.uploadConfig.apiAuthConfig?.authKeyPath else {
                return po(tip: "【\(scheme)】配置文件中未指定(uploadConfig.apiAuthConfig.apiKey/apiIssuerID/authKeyPath)",type: .error)
            }
            
            po(tip: "======Upload项目开始======")
            
            
            do {
                try shellOut(to: .installApiP8(apiKey: apiKey, authKeyPath: authKeyPath))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            do {
                
                try shellOut(to: .upload(scheme: scheme, path: exportPath, apiKey: apiKey, apiIssuerID: apiIssuerID))
                
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Upload项目完成[\(GlobalConstants.duration(to: date) + " s")]======")
        }
    }
}







