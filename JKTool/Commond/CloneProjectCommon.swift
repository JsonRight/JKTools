//
//  CloneProjectCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/7/6.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class CloneProjectCommon: CommonProtocol {
   
    func run(options: ConsoleOptions) {
        guard let url = options.url else {
            print(Colors.red("克隆整个项目 扩展参数，-u：【git地址】，-p：【clone到位置】，-b：【分支名称】"))
            exit(EXIT_FAILURE)
        }
        guard let path = options.path else {
            print(Colors.red("克隆整个项目 扩展参数，-u：【git地址】，-p：【clone到位置】，-b：【分支名称】"))
            exit(EXIT_FAILURE)
        }
        print(Colors.green("======开始准备clone项目======"))
        do {
            try shellOut(to: .removeFolder(from: path))
        } catch {
            print(Colors.yellow("\(path) 无法删除"))
        }
        
        do {
            try shellOut(to: .gitClone(url: url, to: path, branch: options.branch))
            CloneCommon().run(options: options)
        } catch {
            print(Colors.yellow("clone项目失败"))
        }
        print(Colors.green("======clone项目结束======"))
    }
}
