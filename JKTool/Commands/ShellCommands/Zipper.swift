//
//  Zipper.swift
//  JKTool
//
//  Created by 姜奎 on 2022/12/21.
//

import Foundation

extension JKTool {
    
    struct Zipper: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "zip",
            _superCommandName: "JKTool",
            abstract: "zip",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "需要压缩的文件")
        var source: String
        
        @Option(name: .shortAndLong, help: "压缩后保存位置")
        var path: String
        
        @Option(name: .long, help: "压缩密码")
        var password: String?
        
        mutating func run() {
            
            let sourceURL = URL(fileURLWithPath: source.convertRelativePath())
            let toPathURL = URL(fileURLWithPath: path.convertRelativePath())
            
            do {
                try Zip.zipFiles(paths: [sourceURL], zipFilePath: toPathURL, password: password, progress: nil)
            } catch {
                po(tip: "【\(source)】zip失败",type: .error)
            }
            
            po(tip: "【\(path)】zip完成")
        }
    }
}

extension JKTool {
    struct UNZipper: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "unzip",
        _superCommandName: "JKTool",
            abstract: "unzip",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "需要解压缩的文件")
        var source: String
        
        @Option(name: .shortAndLong, help: "解压缩后保存位置")
        var path: String
        
        @Option(name: .shortAndLong, help: "允许覆盖，default：true")
        var overwrite: Bool = true
        
        @Option(name: .long, help: "解压缩密码")
        var password: String?
        
        mutating func run() {
            
            let sourceURL = URL(fileURLWithPath: source.convertRelativePath())
            let toPathURL = URL(fileURLWithPath: path.convertRelativePath())
            
            do {
                try Zip.unzipFile(sourceURL, destination: toPathURL, overwrite: overwrite, password: password, progress: nil, fileOutputHandler: nil)
            } catch {
                po(tip: "【\(source)】unzip失败",type: .error)
            }
            
            po(tip: "【\(path)】unzip完成")
        }
    }
}
