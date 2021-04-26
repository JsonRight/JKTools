//
//  ConfigType.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
public struct ConfigType {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }
}

extension ConfigType: Equatable {
    public static func == (lhs: ConfigType, rhs: ConfigType) -> Bool {
        return lhs.name == rhs.name
    }
}

extension ConfigType: CustomStringConvertible {
    public var description: String {
        return name
    }
}
