//
//  DeleteTagCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/11/20.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class DeleteTagCommon: PullCommon {
    override func run(options: ConsoleOptions) {
        guard let pro = Project.project() else {
            print(Colors.red("当前目录没有检索到工程"))
            exit(EXIT_FAILURE)
        }
        guard pro.rootProject == pro else {
            print(Colors.red("请在项目根目录执行脚本"))
            exit(EXIT_FAILURE)
        }
        self.deleteTag(pro: pro, options: options)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pro.recordListPath))
            let recordList = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<String>
            print(Colors.green("【\(pro.name)】Modulefile.recordList 读取成功"))
            for record in recordList {
                guard let pro1 = Project.project(directoryPath: "\(pro.checkoutsPath)/\(record)") else {
                    print(Colors.yellow("\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容"))
                    break
                }
                self.deleteTag(pro: pro1, options: options)
            }
        } catch {
            print(Colors.red("【\(pro.name)】Modulefile.recordList 读取失败"))
        }
    }
    
    func deleteTag(pro: Project,options: ConsoleOptions) {
        guard let tag = options.tag else {
            print(Colors.red("扩展参数-v：【tag】"))
            exit(EXIT_FAILURE)
        }
        do {
            print(Colors.green("【\(pro.name)】pull 开始"))
            let date = Date.init().timeIntervalSince1970
            try shellOut(to: .gitDelTag(tag: tag),at: pro.directoryPath)
            print(Colors.green("【\(pro.name)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s"))
        } catch {
            print(Colors.red("【\(pro.name)】pull 失败"))
            let error = error as! ShellOutError
            print(error.message) // Prints STDERR
            print(error.output) // Prints STDOUT
        }
    }
}
