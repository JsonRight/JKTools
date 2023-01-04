//
//  Help.swift
//  JKTool
//
//  Created by 姜奎 on 2022/7/19.
//

import Foundation

extension JKTool {
    struct Config: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "config",
            _superCommandName: "JKTool",
            abstract: "config文件格式",
            version: "1.0.0")
        mutating func run() {
            po(tip: """
               ‘’‘
               {
                 "sdk": "iOS/iPadOS/macOS/tvOS/watchOS/carPlayOS",
                 "certificateConfig": {
                   "macPwd": "mac密码",
                   "p12sPath": "路径",
                   "p12Pwd": "p12文件密码",
                   "profilesPath": "路径"
                 },
                 "exportConfig": {
                   "exportOptionsPath": "export.plist路径",
                   "saveConfig": {
                     "nameSuffix": "String",
                     "path": "路径"
                   }
                 },
                 "uploadConfig": {
                   "accountAuthConfig": {
                     "username": "appleid账户",
                     "password": "account专用密码"
                   },
                   "apiAuthConfig": {
                     "apiKey": "String",
                     "apiIssuerID": "String",
                     "authKeyPath": "ipa路径"
                   },
                    "ipaPath": "ipa路径"
                 }
               }
               ’‘’
               """)
        }
    }
}
