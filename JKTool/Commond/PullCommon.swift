//
//  PullCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/11/20.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class PullCommon: CommonProtocol {
    func run(options: ConsoleOptions) {
        guard let pro = Project.project() else {
            print(Colors.red("当前目录没有检索到工程"))
            exit(EXIT_FAILURE)
        }
        self.pull(pro: pro, options: options)
    }
    
    func pull(pro: Project,options: ConsoleOptions) {
        do {
            print(Colors.green("【\(pro.name)】pull 开始"))
            let date = Date.init().timeIntervalSince1970
            try shellOut(to: .gitPull(),at: pro.directoryPath)
            print(Colors.green("【\(pro.name)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s"))
        } catch {
            print(Colors.red("【\(pro.name)】pull 失败"))
//            let error = error as! ShellOutError
//            print(error.message) // Prints STDERR
//            print(error.output) // Prints STDOUT
            exit(EXIT_FAILURE)
        }
    }
}
