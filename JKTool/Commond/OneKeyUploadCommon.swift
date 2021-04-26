//
//  OneKeyUploadCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/7/2.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class OneKeyUploadCommon: CommonProtocol {
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
        print(Colors.green("======开始准备oneKeyUpload【\(scheme)】项目======"))
        var buildOption = options;
        buildOption.config = ConfigType("Debug")
        BuildCommon().run(options: buildOption)
        ArchiveCommon().run(options: options)
        UploadCommon().run(options: options)
        print(Colors.green("======oneKeyUpload项目结束======"))
    }
}
