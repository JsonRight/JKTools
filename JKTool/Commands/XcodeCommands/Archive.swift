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
            subcommands: [Config.self,Scheme.self],
            defaultSubcommand: Scheme.self
        )
    }
}

struct ArchiveConfigModel: Decodable {
    
    var configuration: String
    
    var path: String
    
    var scheme: String
    
    var export: String
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
        
        @Argument(help: "工程存放路径")
        var path: String
        

        mutating func run() {
            
            if configPath.lowercased() == "default" {
                guard let defaultConfigPath = Project.project()?.defaultConfigPath else {
                    return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
                }
                
                configPath = defaultConfigPath
            }
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ArchiveConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let project = Project.project(directoryPath: configs.path) else {
                return po(tip: "\(path)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Archive项目开始======")
            do {
                try shellOut(to: .archive(scheme: configs.scheme, isWorkspace: project.projectType == .scworkspace, projectPath: project.directoryPath, configuration: configs.configuration, export: configs.export))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Archive项目完成======")
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
        
        @Argument(help: "default：Release")
        var configuration: String?
        
        @Argument(help: "工程存放路径")
        var path: String?
        
        @Argument(help: "export.plist存放路径")
        var export: String

        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
               return po(tip: "请使用项目根目录执行脚本", type: .error)
            }
            
            po(tip: "======Archive项目开始======")
            do {
                try shellOut(to: .archive(scheme: scheme, isWorkspace: project.projectType == .scworkspace, projectPath: project.directoryPath, configuration: configuration ?? "Release", export: export))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Archive项目完成======")
        }
    }
}







