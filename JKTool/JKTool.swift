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
            let sema = DispatchSemaphore( value: 0 )
           
            guard let urlStr = JKToolConfig.sharedInstance.config.toolUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let url = URL(string: urlStr) else {
                return po(tip: "转换JKTool下载路径失败，请检查路径是否有效",type: .error)
            }
            po(tip: "download JKTool：\(urlStr)")
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringCacheData,
                timeoutInterval: 10)
            let downloadTask = session.downloadTask(with: request) { location, response, error in
                
                
                guard let locationPath = location?.path else {
                    return po(tip: "download JKTool失败")
                }
                
                guard error == nil else {
                    return po(tip: "download JKTool失败：\n" + error.debugDescription)
                }
                
                po(tip: "JKTool下载成功，地址：\(locationPath)",type: .tip)
                let manager = FileManager.default
                do {
                    try manager.removeItem(atPath: "/usr/local/bin/JKTool")
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "remove`/usr/local/bin/JKTool`失败：\n" + error.message + error.output,type: .error)
                }
                
                do {
                    try manager.moveItem(atPath: locationPath, toPath: "/usr/local/bin/JKTool")
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "move`/usr/local/bin/JKTool`失败：\n" + error.message + error.output,type: .error)
                }
                
                do {
                    try manager.setAttributes([FileAttributeKey.posixPermissions: 0o777], ofItemAtPath: "/usr/local/bin/JKTool")
                    po(tip: "`/usr/local/bin/JKTool`已更新",type: .tip)
                } catch {
                    let error = error as! ShellOutError
                    po(tip: "修改`/usr/local/bin/JKTool`可执行权限失败：\n" + error.message + error.output,type: .error)
                }
                sema.signal()
            }
            downloadTask.resume()
            sema.wait()
    
        }
    }
}
