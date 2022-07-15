//
//  SubModule.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/12.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

public class SubProject {
    
    var name:String
    var url:String
    var branch:String
    
    public init(name: String, url: String, branch: String) {
        self.name = name
        self.url = url
        self.branch = branch
    }

    lazy var desp: String = {
        return """
        \(self.name)
        \(self.url)
        \(self.branch)
        """
    }()
}
