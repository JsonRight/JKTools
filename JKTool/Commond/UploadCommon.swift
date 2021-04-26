//
//  UploadCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
class UploadCommon: CommonProtocol {
    func run(options: ConsoleOptions) {
        
        guard let pro = Project.project() else {
            print(Colors.red("当前目录没有检索到工程"))
            exit(EXIT_FAILURE)
        }
        guard pro.rootProject == pro else {
            print(Colors.red("请在项目根目录执行脚本"))
            exit(EXIT_FAILURE)
        }
        self.upload(pro: pro, options: options)
    }
    
    func upload(pro: Project,options: ConsoleOptions) {
        guard let scheme = options.scheme else {
            print(Colors.red("扩展参数-c：【Debug｜Release】，-t：【traget名称】，-d：【描述】"))
            exit(EXIT_FAILURE)
        }
        print(Colors.green("======开始准备upload【\(scheme)】项目======"))
        do {
            try shellOut(to: .uploadIOS(scheme: scheme, projectPath: pro.directoryPath, config: options.config.name, desc: options.desc))
        } catch {
            print(Colors.red("upload：\(scheme).ipa 失败"))
            let error = error as! ShellOutError
            print(error.message) // Prints STDERR
            print(error.output) // Prints STDOUT
            exit(EXIT_FAILURE)
        }
        print(Colors.green("======upload项目结束======"))
    }
}
