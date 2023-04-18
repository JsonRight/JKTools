//
//  MergeSquash.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/28.
//

import Foundation
extension JKTool.Git {
    struct Squash: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "squash",
            _superCommandName: "git",
            abstract: "merge squash",
            version: "1.0.0")
        
        @Option(name: .shortAndLong, help: "merge from branch")
        var from: String
        
        @Option(name: .shortAndLong, help: "merge to branch")
        var to: String
        
        @Option(name: .shortAndLong, help: "commit的信息")
        var message: String
        
        @Option(name: .shortAndLong, help: "删除 from 分支，default：false")
        var del: Bool = false
        
        @Option(name: .shortAndLong, help: "递归子模块，default：false")
        var recursive: Bool = false
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            func squash(project: Project) {
                
                JKTool.Git.Checkout.main(["--branch",from,"--recursive","\(false)","--force","\(false)","--path",project.directoryPath])
                
                JKTool.Git.Pull.main(["--recursive","\(false)","--path",project.directoryPath])
                
                JKTool.Git.Checkout.main(["--branch",to,"--recursive","\(false)","--force","\(false)","--path",project.directoryPath])
                
                JKTool.Git.Pull.main(["--recursive","\(false)","--path",project.directoryPath])
                
                JKTool.Git.Merge.main(["--branch",from,"--squash","\(true)","--recursive","\(false)","--commit","\(false)","--message",message,"--path",project.directoryPath])
                
                JKTool.Git.Push.main(["--branch",to,"--recursive","\(false)","--path",project.directoryPath])
                
                if del {
                    
                    JKTool.Git.Branch.Del.Local.main(["--branch",from,"--recursive","\(false)","--path",project.directoryPath])
                    
                    JKTool.Git.Branch.Del.Origin.main(["--branch",from,"--recursive","\(false)","--path",project.directoryPath])
                }
                
                po(tip: "【\(project.destination)】Merge squash完成", type: .tip)
            }
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录没有检索到工程", type: .error)
            }
            
            guard project.rootProject == project || recursive else {
                let status = try? shellOut(to: .gitDiffHEAD(), at: project.directoryPath)
                
                guard  status?.count ?? 0 <= 0 else {
                    return po(tip: "【\(project.destination)】 存在需要提交的内容",type: .error)
                }
                squash(project: project)
               return
            }
            
            po(tip: "======Merge squash工程开始======", type: .tip)
            
            for record in project.recordList {
                guard let pro = Project.project(directoryPath: "\(project.checkoutsPath)/\(record)/") else {
                    po(tip: "\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容",type: .warning)
                    continue
                }
                let status = try? shellOut(to: .gitDiffHEAD(), at: pro.directoryPath)
                
                guard  status?.count ?? 0 <= 0 else {
                    return po(tip: "【\(pro.destination)】 存在需要提交的内容",type: .error)
                }
                squash(project: pro)
            }
            
            let status = try? shellOut(to: .gitDiffHEAD(), at: project.directoryPath)
            
            guard  status?.count ?? 0 <= 0 else {
                return po(tip: "【\(project.destination)】 存在需要提交的内容",type: .error)
            }
            squash(project: project)
            
            po(tip: "======Merge squash工程结束======")
        }
    }
}
