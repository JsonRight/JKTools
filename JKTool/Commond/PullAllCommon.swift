//
//  PullAllCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/11/20.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class PullAllCommon: PullCommon {
    override func run(options: ConsoleOptions) {
        
        guard let project = Project.project() else {
            print(Colors.red("当前目录没有检索到工程"))
            exit(EXIT_FAILURE)
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: project.rootProject.recordListPath))
            let recordList = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<String>
            print(Colors.green("【\(project.rootProject.name)】Modulefile.recordList 读取成功"))
            for record in recordList {
        
                guard let pro1 = Project.project(directoryPath: "\(project.rootProject.checkoutsPath)/\(record)") else {
                    print(Colors.yellow("\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容"))
                    break
                }
                self.pull(pro: pro1, options: options)
            }
        } catch {
            print(Colors.red("【\(project.rootProject.name)】Modulefile.recordList 读取失败"))
            exit(EXIT_FAILURE)
        }
    }
}
