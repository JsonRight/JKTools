//
//  Shell.swift
//  JKTool
//
//  Created by 姜奎 on 2022/7/8.
//

import Foundation
extension JKTool {
    struct Shell: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "shell",
            _superCommandName: "JKTool",
            abstract: "对于固定工程格式封装(对当前目录下及其子模块执行shell命令)",
            version: "1.0.0"
        )
        
        @Option(name: .shortAndLong, help: "命令内容")
        var shell: String
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?

        mutating func run() {
            
            func doShell(project:Project){
                do {
                    try shellOut(to: ShellOutCommand(string: shell),at: project.directoryPath)
                } catch  {
                    let error = error as! ShellOutError
                    po(tip: "doShell：\n" + error.message + error.output,type: .error)
                }
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project else {
                doShell(project: project)
                return
            }
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                
                doShell(project: subProject)
            }
            
            doShell(project: project)
            
        }
            
    }
}
