//
//  Projects.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/22.
//

import Foundation
let ProjectsKey = "ProjectsKey"


class Projects {
    static func projectsList() -> ([ProjectInfoBean]) {
        let array: [Dictionary<String,String>] = UserDefaults.standard.array(forKey: ProjectsKey) as? [Dictionary<String, String>] ?? []
        var list = [ProjectInfoBean]()
        for item in array {
            let bean = ProjectInfoBean(projectName: item["projectName"], projectPath: item["projectPath"], sourcePath: item["sourcePath"])
            list.append(bean)
        }
        
        return list
    }
    static func save(projects: [ProjectInfoBean]) {
        var list = [Dictionary<String,String>]()
        for item in projects {
            list.append(["projectName":item.projectName,"projectPath":item.projectPath,"sourcePath":item.sourcePath])
        }
        let userDefault = UserDefaults.standard
        
        userDefault.setValue(list, forKey: ProjectsKey)
        userDefault.synchronize()
    }
}
