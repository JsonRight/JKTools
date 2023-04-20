//
//  Open.swift
//  JKTool
//
//  Created by 姜奎 on 2023/4/19.
//

import Foundation

extension JKTool {
    
    struct Open: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "open",
            _superCommandName: "JKTool",
            abstract: "某程序快捷打开某文件/文件夹", subcommands: [Xcode.self, VSCode.self])
    }
}

extension JKTool.Open {
    
    struct Xcode: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "xcode",
            _superCommandName: "open",
            abstract: "Xcode快捷打开某文件/文件夹")
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            if FileManager.default.isDirectory(path: project.directoryPath) {
                _ = try? shellOut(to: ShellOutCommand(string: "xed \(project.directoryPath)/\(project.projectType.entrance())"))
            } else {
                _ = try? shellOut(to: ShellOutCommand(string: "xed \(project.directoryPath)"))
            }
        }
    }
    
    struct VSCode: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "vscode",
            _superCommandName: "open",
            abstract: "VSCode快捷打开某文件/文件夹")
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            _ = try? shellOut(to: ShellOutCommand(string: "code \(project.directoryPath)"))
        }
    }
    
}
