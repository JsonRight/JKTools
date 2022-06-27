//
//  ArchiveCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/22.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class ArchiveCommon: CommonProtocol {
    func run(options: ConsoleOptions) {
        
        guard let pro = Project.project() else {
            print(Colors.red("请在项目根目录执行脚本"))
            exit(EXIT_FAILURE)
        }
        guard pro.rootProject == pro else {
            print(Colors.red("请在项目根目录执行脚本"))
            exit(EXIT_FAILURE)
        }
        self.archive(pro: pro, options: options)
    }
    
    func archive(pro: Project,options: ConsoleOptions) {
        
        guard let scheme = options.scheme else {
            print(Colors.red("扩展参数-c：【Debug｜Release】，-t：【traget名称】"))
            exit(EXIT_FAILURE)
        }
        print(Colors.green("======开始准备archive【\(scheme)】项目======"))
        do {
            try shellOut(to: .archiveIOS(scheme: scheme, projectPath: pro.directoryPath, config: options.config.value, exportName: options.export))
        } catch  {
            print(Colors.red("archive：\(scheme).ipa 失败"))
            let error = error as! ShellOutError
            print(error.message) // Prints STDERR
            print(error.output) // Prints STDOUT
            exit(EXIT_FAILURE)
        }
        print(Colors.green("======archive项目结束======"))
    }
}
