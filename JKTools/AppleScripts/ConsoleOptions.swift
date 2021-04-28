//
//  ConsoleOptions.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

public struct ConsoleOptions {
    var config:ConfigType?
    var cache:Bool?
    var url:String?
    var path:String?
    var branch:String?
    var scheme:String?
    var export:String?
    var tag:String?
    var desc:String?
    var libraryOptions:LibraryOptions?
    
    init(url:String?,path:String?) {
        self.url = url
        self.path = path
    }
}

public enum LibraryOptions: String {
    case Framework = "Framework"
    case XCFramework = "XCFramework"
    case Static = "Static"
}
