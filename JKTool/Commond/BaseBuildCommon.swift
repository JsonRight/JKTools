//
//  BaseBuildCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2021/4/21.
//  Copyright © 2021 JK. All rights reserved.
//

import Foundation
import CommonCrypto

protocol BaseBuildCommon: CommonProtocol {
    func build(pro: Project,options: ConsoleOptions)
    func librarySuffix() -> String
    func echoError(name: String, filePath: String, content:String)
}

extension BaseBuildCommon {
    func run(options: ConsoleOptions) {
        
        guard let pro = Project.project() else {
            print(Colors.red("当前目录没有检索到工程"))
            exit(EXIT_FAILURE)
        }
        if pro.rootProject != pro {
            print(Colors.green("【\(pro.name)】开始准备 build"))
            let date = Date.init().timeIntervalSince1970
            self.build(pro: pro, options: options)
            print(Colors.green("【\(pro.name)】build 结束"))
            print(Colors.green("【\(pro.name)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s"))
            return
        }
        print(Colors.green("======开始准备build子模块======"))
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pro.recordListPath))
            let recordList = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<String>
            print(Colors.green("【\(pro.name)】Modulefile.recordList 读取成功"))
            for record in recordList {
    
                guard let pro1 = Project.project(directoryPath: "\(pro.checkoutsPath)/\(record)") else {
                    print(Colors.yellow("\(record) 工程不存在，请检查 Modulefile.recordList 是否为最新内容"))
                    break
                }
                print(Colors.green("【\(pro1.name)】build 开始"))
                let date = Date.init().timeIntervalSince1970
                self.build(pro: pro1, options: options)
                print(Colors.green("【\(pro1.name)】:用时：" + String(format: "%.2f", Date.init().timeIntervalSince1970-date) + "s"))
                
            }
        } catch {
            print(Colors.red("【\(pro.name)】Modulefile.recordList 读取失败"))
            exit(EXIT_FAILURE)
        }
        print(Colors.green("======build子模块结束======"))
    }
    
    func echoError(name: String, filePath: String, content:String){
        print(Colors.yellow("【\(name)错误详情:(\(content))"))
        do {
            try shellOut(to: .createFile(named: filePath, contents: content))
            print(Colors.yellow("【\(name)错误详情:(\(filePath))"))
        } catch {
            print(Colors.red("【\(name)】错误详情写入失败！(\(filePath))"))
        }
    }
    
    func MD5(string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
