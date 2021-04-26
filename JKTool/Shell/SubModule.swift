//
//  SubModule.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/12.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

public class SubModule {
    
    var source:String
    var url:String
    var branch:String
    
    public init(source: String, url: String, branch: String) {
        self.source = source
        self.url = url
        self.branch = branch
    }
    
    lazy var name: String = {
        if let url = URL(string: self.url) {
           return url.lastPathComponent.components(separatedBy: ".").first!
        }
        return ""
    }()
    lazy var desp: String = {
        return """
        \(self.source)
        \(self.url)
        \(self.branch)
        """
    }()
}
