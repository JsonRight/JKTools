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
        
        @Argument(help: "Debug/Release...")
        var configuration: String
        
        @Argument(help: "Scheme")
        var scheme: String
        
        @Argument(help: "内容格式请参照：JKTool config")
        var configPath: String
        
        @Argument(help: "是否导出IPA，default：true")
        var export: Bool?
        
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
                try shellOut(to: .archive(scheme: scheme, isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.name(), projectPath: project.directoryPath, configuration: configuration, sdk: configs.sdk), at: project.directoryPath)
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            
            if configs.quiet != false {po(tip: "======Archive项目完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")}
            
            if export != false {
                JKTool.Export.main([configuration,scheme,configPath,project.directoryPath])
            }
            
        }
    }
}







