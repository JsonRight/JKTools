//
//  ConsoleOptions.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

struct ConsoleOptions {
    var config = ConfigType("Debug")
    var cache = true
    var url:String?
    var path:String?
    var branch:String?
    var scheme:String?
    var export = "export.plist"
    var tag:String?
    var desc = ""
    var libraryOptions = LibraryOptions.Framework
    
    init(arguments:[String]) {
        for argument in arguments {
            let arr = argument.components(separatedBy: "=").filter { (str) -> Bool in
                return str != ""
            }
            if arr.count < 2 {
                continue
            } else if arr.first == "-m" || arr.first == "mode" {
                self.config = ConfigType(arr[1])
            } else if arr.first == "-c" || arr.first == "cache" {
                self.cache = (arr[1].lowercased() == "true")
            } else if arr.first == "-u" || arr.first == "url" {
                self.url = arr[1]
            } else if arr.first == "-p" || arr.first == "path" {
                self.path = arr[1]
            } else if arr.first == "-b" || arr.first == "branch" {
                self.branch = arr[1]
            } else if arr.first == "-t" || arr.first == "target" {
                self.scheme = arr[1]
            } else if arr.first == "-e" || arr.first == "export" {
                self.export = arr[1]
            } else if arr.first == "-v" || arr.first == "tag" {
                self.tag = arr[1]
            } else if arr.first == "-d" || arr.first == "desc" {
                self.desc = arr[1]
            } else if arr.first == "-l" || arr.first == "libraryOptions" {
                self.libraryOptions = LibraryOptions(rawValue: arr[1]) ?? .Framework
            }
        }
    }
    init(config: ConfigType?, cache:Bool?, url:String?, path:String?,branch:String?,scheme:String?,export:String?,tag:String?,desc:String?,lib:LibraryOptions?) {
        self.config = config ?? ConfigType("Debug")
        self.cache = cache ?? true
        self.url = url
        self.path = path
        self.branch = branch
        self.scheme = scheme
        self.export = export ?? "export.plist"
        self.tag = tag
        self.desc = desc ?? ""
        self.libraryOptions = lib ?? .Framework
    }
}
