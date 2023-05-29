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
            abstract: "archive命令对于固定工程格式封装",
            version: "1.0.0"
        )
        
        @Option(name: .shortAndLong, help: "归档环境，default：Release")
        var configuration: String = "Release"
        
        @Option(name: .shortAndLong, help: "Scheme")
        var scheme: String
        
        @Option(name: .long, help: "内容格式请参照：JKTool config")
        var configPath: String
        
        @Option(name: .shortAndLong, help: "是否导出IPA，default：true")
        var export: Bool = true
        
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
            
            po(tip: "======Archive项目开始======")
            let date = Date.init().timeIntervalSince1970
            
            let archivePath = configs.needConfigurationInProductsPath == true ? "\(project.buildPath)/\(configuration)/\(scheme).xcarchive": "\(project.buildPath)/\(scheme).xcarchive"
            
            do {
                try shellOut(to: .archive(scheme: scheme, isWorkspace: project.workSpaceType.isWorkSpace(), projectName: project.workSpaceType.entrance(), configuration: configuration, sdk: configs.sdk,archivePath: archivePath), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            
            po(tip: "======Archive项目完成[\(GlobalConstants.duration(to: date) + " s")]======")
            
            if export {
                JKTool.Export.main(["--configuration","\(configuration)","--scheme","\(scheme)","--config-path","\(configPath)","--path","\(project.directoryPath)"])
            }
        }
    }
}







