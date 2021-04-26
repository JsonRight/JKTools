//
//  BuildCommon.swift
//  JKTool
//
//  Created by 姜奎 on 2021/4/21.
//  Copyright © 2021 JK. All rights reserved.
//

import Foundation

class BuildCommon: CommonProtocol {
    
    func run(options: ConsoleOptions) {
        
        switch options.libraryOptions {
        
            case .Framework:
                BuildFrameworkCommon().run(options: options)
            case .XCFramework:
                BuildXCFrameworkCommon().run(options: options)
            case .Static:
                BuildStaticCommon().run(options: options)
        }
    }
}
