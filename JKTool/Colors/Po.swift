//
//  Po.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/23.
//

import Foundation

public enum Status {
    case desp, tip, warning, error
}

public func po(tip: String, type:Status? = .tip){
    switch type {
    case .desp:
        print(Colors.blue("\(tip)"))
    case .tip,.none:
        print(Colors.green("\(tip)"))
    case .warning:
        print(Colors.yellow("\(tip)"))
    case .error:
        print(Colors.red("\(tip)"))
        Darwin.exit(EXIT_FAILURE)
    }
}
