//
//  Zipper.swift
//  JKTool
//
//  Created by 姜奎 on 2022/12/21.
//

import Foundation
import Zip

//struct Options: ParsableArguments {
//    @Flag var tag: Bool
//
//    @Argument(parsing: .remaining, help: "zip文件保存对应的tag", completion: nil) var tagName: String
//}

extension JKTool.Git {
    
    struct Zipper: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "zip",
            _superCommandName: "git",
            abstract: "zip",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "zip文件保存对应的tag")
        var tag: String
        
        @Option(name: .shortAndLong, help: "执行目录")
        var path: String?
        
        mutating func run() {
            
            func zip(project: Project){
                
                let status = try? shellOut(to: .gitStatus(),at: project.directoryPath)
                
                if status != "" {
                    po(tip: "【\(project.name)】zip失败：git仓库存在未提交内容", type: .error)
                }
                guard let code = try? shellOut(to: .gitCodeVerison(),at: project.directoryPath) else {
                    po(tip: "【\(project.name)】zip失败：未能检索到commit id，请检查git仓库", type: .error)
                    return
                }
                let currentVersion  = ShellOutCommand.MD5(string:code)
                
                let oldVersion = try? shellOut(to: .readVerison(path: "\(project.buildPath)/Universal/"))
                
                if !String(oldVersion ?? "").contains(currentVersion) {
                    po(tip: "【\(project.name)】zip失败：未能找到可被压缩的build产物，请先使用`JKTool build ... `构建 build产物", type: .error)
                }
                
                let fileManager = FileManager.default
                let zipDirURL = URL(fileURLWithPath: "\(project.buildPath)/zip")
                try? fileManager.createDirectory(at: zipDirURL, withIntermediateDirectories: true)
                
                let zipURL = zipDirURL.appendingPathComponent("\(project.name).zip", isDirectory: false)
                try? fileManager.removeItem(at: zipURL)
                
                
                let cachePathURL = URL(fileURLWithPath: "\(project.buildPath)/Universal/\(currentVersion)")
                
                try? Zip.zipFiles(paths: [cachePathURL], zipFilePath: zipURL, password: nil, progress: nil)
                
//                Zip.quickZipFiles(<#T##paths: [URL]##[URL]#>, fileName: <#T##String#>)
                
//
//                JKTool.Git.Commit.main(["[zip]\(tag)"])
//
//                JKTool.Git.Push.main([])
//
//                JKTool.Git.Tag.Add.main([tag])
                
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }

            po(tip: "======Zip开始======", type: .tip)
            zip(project: project)
            po(tip: "======Zip结束======")
        }
    }
}
