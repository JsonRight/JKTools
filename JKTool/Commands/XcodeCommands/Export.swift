//
//  Export.swift
//  JKTool
//
//  Created by 姜奎 on 2022/7/19.
//

import Foundation

extension JKTool {
    struct Export: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "export",
            _superCommandName: "JKTool",
            abstract: "export命令对于固定工程格式封装",
            version: "1.0.0"
        )
        
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
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath(absolutPath:project.directoryPath))) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            po(tip: "======Export IPA 开始======")
            let date = Date.init().timeIntervalSince1970
            do {
                try shellOut(to: .unlockSecurity(password: configs.certificateConfig.macPwd))
            } catch  {
                let error = error as! ShellOutError
                po(tip: "unlockSecurity" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .importP12(p12sPath: configs.certificateConfig.p12sPath.convertRelativePath(absolutPath:project.directoryPath), password: configs.certificateConfig.p12Pwd), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "importP12" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .installProfiles(profilesPath: configs.certificateConfig.profilesPath.convertRelativePath(absolutPath:project.directoryPath)), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "installProfiles:" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .export(scheme: scheme, projectPath: project.directoryPath, configuration: configuration, export: configs.exportConfig.exportOptionsPath.convertRelativePath(absolutPath:project.directoryPath), nameSuffix: configs.exportConfig.saveConfig?.nameSuffix,toSavePath: configs.exportConfig.saveConfig?.path), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Export IPA 完成[\(String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s")]======")
        }
    }
}
