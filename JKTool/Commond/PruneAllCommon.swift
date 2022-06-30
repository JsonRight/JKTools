//
//  PruneAllCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2021/4/28.
//

import Foundation

class PruneAllCommon: PruneCommon {
    
    override func prune(pro: Project, options: ConsoleOptions) {
        super.prune(pro: pro, options: options)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pro.rootProject.recordListPath))
            let recordList = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<String>
            print(Colors.green("【\(pro.rootproject.scheme)】Modulefile.recordList 读取成功"))
            for record in recordList {
        
                guard let pro1 = Project.project(directoryPath: "\(pro.rootProject.checkoutsPath)/\(record)") else {
                    print(Colors.yellow("\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容"))
                    break
                }
                super.prune(pro: pro1, options: options)
            }
        } catch {
            print(Colors.red("【\(pro.rootproject.scheme)】Modulefile.recordList 读取失败"))
            exit(EXIT_FAILURE)
        }
    }
}
