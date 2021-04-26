//
//  HelperCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

class HelperCommon: CommonProtocol {
    func run(options: ConsoleOptions) {
        print( """
               \(Colors.blue("JKTool 提供项目Framework私有库以下功能：【执行目录必须在相关根目录】"))
               1、\(Colors.green("clone")) 遍历 Modulefile 及内部引用，克隆全部Framework仓库至子文件夹：/Module/checkouts/ 下。
                   示例：\(Colors.green("JKTool clone"))
               2、\(Colors.green("clone_project")) 克隆整个项目 扩展参数，-u：【git地址】，-p：【clone到位置】，-b：【分支名称】。
                    示例：\(Colors.green("JKTool cloneProject -u=https://XXX.git -p=/XXX/XXX -b=master"))
               3、\(Colors.green("pull")) 根据所在目录不同【项目根目录｜Framework根目录】，pull单个工程
                   示例：\(Colors.green("JKTool pull"))
               4、\(Colors.green("pull_all")) pull 整个项目
                   示例：\(Colors.green("JKTool pull_all"))
               5、\(Colors.green("add_tag")) 给整个项目添加一个 tag，扩展参数，-v：【tag】
                   示例：\(Colors.green("JKTool add_tag -v=v1.0.0"))
               6、\(Colors.green("del_tag")) 给整个项目删除一个 tag，扩展参数，-v：【tag】
                   示例：\(Colors.green("JKTool del_tag -v=v1.0.0"))
               7、\(Colors.green("build")) 根据所在目录不同【项目根目录｜Framework根目录】，编译【全部｜单个Framework】扩展参数，-c：【是否使用cache默认true】，-m：【Debug｜Release】， -l：【子库格式】默认Framework
                   示例：\(Colors.green("JKTool build -c=true"))
               8、\(Colors.green("buildFramework")) 根据所在目录不同【项目根目录｜Framework根目录】，编译【全部｜单个Framework】扩展参数，-c：【是否使用cache默认true】，-m：【Debug｜Release】
                   示例：\(Colors.green("JKTool buildFramework -c=true"))
               9、\(Colors.green("buildXCFramework")) 根据所在目录不同【项目根目录｜Framework根目录】，编译【全部｜单个Framework】扩展参数，-c：【是否使用cache默认true】
                   示例：\(Colors.green("JKTool buildXCFramework -c=true"))
               10、\(Colors.green("buildStatic")) 根据所在目录不同【项目根目录｜.a根目录】，编译【全部｜单个.a】，-m：【Debug｜Release】
                    示例：\(Colors.green("JKTool buildStatic"))
               11、\(Colors.green("archive")) 归档ipa包，扩展参数-m：【Debug｜Release】，-t：【target名称】，-e：【默认export.plist】
                   示例：\(Colors.green("JKTool archive -m=Debug -t=targetName -e=export.plist"))
               12、\(Colors.green("upload")) 上传ipa包至fir平台，扩展参数，-t：【target名称】，-d：【描述】请提前配置好fir账号
                   示例：\(Colors.green("JKTool upload -t=targetName -d=这是个app"))
               13、\(Colors.green("oneKeyUpload")) 上传ipa包至fir平台(适用于framework)，扩展参数，-t：【target名称】，-m：【Debug｜Release】，-c：【是否使用cache默认true】，-d：【描述】请提前配置好fir账号，-e：【默认export.plist】,-l：【子库格式】默认Framework
                    示例：\(Colors.green("JKTool one_key_upload -t=targetName -m=Debug -d=这是个app"))
               """)
    }
}
