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
            subcommands: [Config.self,Scheme.self],
            defaultSubcommand: Config.self
        )
    }
}

extension JKTool.Upload {
    struct Config: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "config",
            _superCommandName: "upload",
            abstract: "upload config",
            version: "1.0.0")

        @Argument(help: "Archive 本地化配置路径")
        var configPath: String
        
        @Argument(help: "执行路径")
        var path: String?

        mutating func run() {
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath.convertRelativePath())) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            guard let configs = try? JSONDecoder().decode(ProjectConfigModel.self, from: data) else {
                return po(tip: "请检查配置文件是否存在，或者格式是否正确！",type: .error)
            }
            
            if configs.quiet != false {po(tip: "======Upload项目开始======")}
            let date = Date.init().timeIntervalSince1970
            
            
            do {
                try shellOut(to: .upload(path: configs.uploadConfig.path.convertRelativePath(), username: configs.uploadConfig.username, password: configs.uploadConfig.password))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            if configs.quiet != false {po(tip: "======Upload项目完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")}
        }
    }
    struct Scheme: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "scheme",
            _superCommandName: "upload",
            abstract: "upload scheme",
            version: "1.0.0")

        @Argument(help: "执行日志，default：true")
        var quiet: Bool?
        
        @Argument(help: "appleid账号")
        var username: String
        
        @Argument(help: "appleid密码")
        var password: String
        
        @Argument(help: "ipa绝对路径")
        var ipaPath: String
        
        mutating func run() {
            
            if quiet != false {po(tip: "======Upload项目开始======")}
            let date = Date.init().timeIntervalSince1970
            do {
                try shellOut(to: .upload(path: ipaPath.convertRelativePath(), username: username, password: password))
            } catch  {
                let error = error as! ShellOutError
                po(tip:  error.message + error.output,type: .error)
            }
            if quiet != false {po(tip: "======Upload项目完成:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s======")}
        }
    }
}







