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
            abstract: "shell",
            version: "1.0.0"
        )
        
        @Argument(help: "命令内容")
        var shell: String
        
        @Argument(help: "执行路径")
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
            
            doShell(project: project)
            
            for record in project.recordList {
    
                guard let subProject = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)") else {
                    po(tip:"\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    break
                }
                
                doShell(project: subProject)
            }
            
        }
            
    }
}
