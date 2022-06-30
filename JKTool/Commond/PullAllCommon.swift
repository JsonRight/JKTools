//
//  PullAllCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/11/20.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class PullAllCommon: PullCommon {
    
    override func pull(pro: Project, options: ConsoleOptions) {
        super.pull(pro: pro, options: options)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pro.rootProject.recordListPath))
            let recordList = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<String>
            print(Colors.green("【\(pro.rootproject.scheme)】Modulefile.recordList 读取成功"))
            for record in recordList {
        
                guard let pro1 = Project.project(directoryPath: "\(pro.rootProject.checkoutsPath)/\(record)") else {
                    print(Colors.yellow("\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容"))
                    break
                }
                super.pull(pro: pro1, options: options)
            }
        } catch {
            print(Colors.red("【\(pro.rootproject.scheme)】Modulefile.recordList 读取失败"))
            exit(EXIT_FAILURE)
        }
    }
}
