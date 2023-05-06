//
//  JKTool.swift
//  JKTool
//
//  Created by 姜奎 on 2021/4/25.
//

import Darwin
import Foundation

struct JKTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "JKTool",
        abstract: "JKTool",
        version: "1.0.0",
        subcommands: [Modules.self,
                      Build.self,
                      Build.XCFramework.self,
                      Build.Clean.self,
                      Archive.self,
                      Export.self,
                      Upload.self,
                      Git.self,
                      Config.self,
                      Shell.self,
                      Zipper.self,
                      UNZipper.self,
                      ToolDictionary.self,
                      ToolArray.self,
                      Open.self,
                      ToolVersion.self,
                      HBBiz.self])
}

extension JKTool {
    struct ToolVersion: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "version",
            abstract: "JKTool检查更新",
            subcommands: [Update.self],
            defaultSubcommand: Update.self)
    }
}

extension JKTool.ToolVersion {
    struct Update: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "update",
            _superCommandName: "version",
            abstract: "JKTool检查更新",
            version: "1.0.0")
        
        mutating func run() {
            
            func downTool() {
                guard let toolUrl = URL(string: JKToolConfig.sharedInstance.config.toolUrl) else {
                    return po(tip: "转换JKTool下载路径失败，请检查路径是否有效",type: .error)
                }
                
                guard let data = try? Data(contentsOf: toolUrl) else {
                    return po(tip: "download JKTool失败")
                }
                
                let toolPath = "/usr/local/bin/JKTool"
                
                do {
                    _ = try data.write(to: URL(fileURLWithPath: toolPath), options: .atomicWrite)
                } catch {
                    po(tip: "`\(toolPath)`写入失败：\n" + error.localizedDescription,type: .error)
                }
                
                do {
                    try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o777], ofItemAtPath: toolPath)
                    po(tip: "`\(toolPath)`已更新！！",type: .tip)
                } catch {
                    po(tip: "修改`\(toolPath)`可执行权限失败：\n" + error.localizedDescription,type: .error)
                }
            }
            
            
            func downToolCompletion() {
                guard let completionUrl = URL(string: JKToolConfig.sharedInstance.config.completionUrl) else {
                    return po(tip: "转换JKTool命令提示下载路径失败，请检查路径是否有效",type: .error)
                }
                guard let data = try? Data(contentsOf: completionUrl) else {
                    return po(tip: "JKTool命令提示下载失败",type: .error)
                }
                
                
                let toolCompletionPath = "/usr/local/etc/bash_completion.d/JKTool-completion"
                do {
                    _ = try data.write(to: URL(fileURLWithPath: toolCompletionPath), options: .atomicWrite)
                } catch {
                    po(tip: "`\(toolCompletionPath)`写入失败：\n" + error.localizedDescription,type: .error)
                }
                
                do {
                    try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o777], ofItemAtPath: toolCompletionPath)
                } catch {
                    po(tip: "修改`\(toolCompletionPath)`可执行权限失败：\n" + error.localizedDescription,type: .error)
                }
            }
            
            downTool()
            
            downToolCompletion()
                
            let profilePath = URL(fileURLWithPath: "\(NSHomeDirectory())/.bash_profile")
            
            let data = try? Data(contentsOf: profilePath)
            
            
            var profile = String(data: data ?? Data(), encoding: .utf8) ?? ""
            
            do {
                if !profile.contains("/usr/local/etc/bash_completion.d/JKTool-completion") {
                    profile = profile + """
                    \n
                    if [ -f /usr/local/etc/bash_completion.d/JKTool-completion ]; then
                        . /usr/local/etc/bash_completion.d/JKTool-completion
                    fi
                    """
                    try profile.write(to: profilePath, atomically: true, encoding: .utf8)
                }
            } catch {
                po(tip: "写入`\(profilePath)`JKTool命令提示功能失败：\n" + error.localizedDescription,type: .warning)
            }
            
            let zshrcPath = URL(fileURLWithPath: "\(NSHomeDirectory())/.zshrc")
            
            let zshrcData = try? Data(contentsOf: zshrcPath)
            
            
            var zshrc = String(data: zshrcData ?? Data(), encoding: .utf8) ?? ""
            
            do {
                if !zshrc.contains("source ~/.bash_profile") {
                    zshrc = zshrc + """
                    \n
                    source ~/.bash_profile
                    """
                    try zshrc.write(to: zshrcPath, atomically: true, encoding: .utf8)
                }
            } catch {
                po(tip: "写入`\(zshrcPath)`JKTool命令提示功能失败：\n" + error.localizedDescription,type: .warning)
            }
            
            do {
                _ = try shellOut(to: ShellOutCommand(string: "source ~/.bash_profile && source ~/.zshrc"))
                po(tip: "JKTool命令提示功能已更新",type: .tip)
            } catch {
                let error = error as! ShellOutError
                po(tip: "激活JKTool命令提示功能失败：\n" + error.message + error.output,type: .warning)
            }
        }
    }
}
