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
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath(absolutPath:project.directoryPath))) else {
                return po(tip: "请检查配置文件是否存在！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件格式是否正确！",type: .error)
            }
            
            let date = Date.init().timeIntervalSince1970
            let archivePath =  configs.needConfigurationInProductsPath == true ? "\(project.buildPath)/\(configuration)/\(scheme).xcarchive": "\(project.buildPath)/\(scheme).xcarchive"
            
            let exportPath =  configs.needConfigurationInProductsPath == true ? "\(project.buildPath)/\(configuration)": project.buildPath
            
            guard FileManager.default.fileExists(atPath: archivePath) else {
                return po(tip: "【\(scheme)】没有找到可导出文件(\(archivePath))",type: .error)
            }
            
            po(tip: "======Export IPA 开始======")
            
            do {
                try shellOut(to: .unlockSecurity(password: configs.certificateConfig.macPwd))
            } catch  {
                let error = error as! ShellOutError
                po(tip: "【\(scheme)】unlockSecurity" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .importP12(p12sPath: configs.certificateConfig.p12sPath.convertRelativePath(absolutPath:project.directoryPath), password: configs.certificateConfig.p12Pwd), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "【\(scheme)】importP12" + error.message + error.output,type: .error)
            }
            
            do {
                try shellOut(to: .installProfiles(profilesPath: configs.certificateConfig.profilesPath.convertRelativePath(absolutPath:project.directoryPath)), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  "【\(scheme)】installProfiles:" + error.message + error.output,type: .error)
            }
            
            guard let exportConfig = configs.exportConfigList.first(where: { $0.configuration == configuration }) else {
                return po(tip: "【\(scheme)】exportConfigList没有匹配到\(configuration)",type: .error)
            }
            
            var savePath: String?
            if let path = exportConfig.saveConfig?.path {
                savePath = path.convertRelativePath(absolutPath: project.directoryPath)
            }
            
            do {
                try shellOut(to: .export(scheme: scheme, archivePath: archivePath, export: exportConfig.exportOptionsPath.convertRelativePath(absolutPath:project.directoryPath), exportPath: exportPath, fileExtension: Platform(configs.sdk).fileExtension(), toSavePath: savePath, allFiles: exportConfig.saveConfig?.allFiles), at: project.directoryPath)
                
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            po(tip: "======Export IPA 完成[\(GlobalConstants.duration(to: date) + " s")]======")
        }
    }
}
