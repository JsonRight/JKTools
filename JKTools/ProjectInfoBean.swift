//
//  ProjectInfoBean.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/9.
//

import Foundation

class ProjectInfoBean {
    var projectName = ""
    var projectPath = ""
    var sourcePath = ""
    init(projectName: String?, projectPath: String?, sourcePath: String?) {
        self.projectName = projectName ?? ""
        self.projectPath = projectPath ?? ""
        self.sourcePath = sourcePath ?? ""
    }
    
    public func projectPathURL() -> URL? {
        let url = URL(string: projectPath)
        return url
    }
    
    public func sourcePathURL() -> URL? {
        let url = URL(string: sourcePath)
        return url
    }
}
