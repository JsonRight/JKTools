//
//  Project.swift
//  JKTool
//
//  Created by 姜奎 on 2020/5/29.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

public func nameForPath(path: String) ->String {
    return URL(fileURLWithPath: path).lastPathComponent
}

public func schemeForPath(path: String) ->String {
    return URL(fileURLWithPath: path).lastPathComponent
}

public class Project {
    
    public  enum ProjectType {
        case xcodeproj(String)
        case xcworkspace(String)
        func isWorkSpace() -> Bool {
            switch self {
            case .xcodeproj(_):
                return false
            case .xcworkspace(_):
                return true
            }
        }
        func name() -> String {
            switch self {
            case .xcodeproj(let string):
                return string
            case .xcworkspace(let string):
                return string
            }
        }
    }
    
    let fileManager = FileManager.default
    
    let directoryPath: String
    
    let projectType: ProjectType
    
    lazy var name: String = {
        return nameForPath(path: self.directoryPath)
    }()
    
    lazy var modulefilePath: String = {
        return self.directoryPath.appending("/Modulefile")
    }()
    
    lazy var modulefile: String = {
        do {
            return try String(contentsOf: URL(fileURLWithPath: self.modulefilePath))
        } catch {
            return ""
        }
    }()
    lazy var moduleList:[SubModule] = {
        var list:[SubModule] = []
        self.modulefile.enumerateLines { (line, stop) in
            let scannerWithComments = Scanner(string: line)

            if scannerWithComments.scanString("#") != nil {
                return
            }
            if scannerWithComments.isAtEnd {
                // The line was all whitespace.
                return
            }
            
            var remainingString = scannerWithComments.string.replacingOccurrences(of: "\"", with: "")
            
            remainingString = remainingString.replacingOccurrences(of: "\'", with: "")
            
            remainingString = remainingString.replacingOccurrences(of: "\\", with: "")
            
            var arr = remainingString.components(separatedBy: " ").filter { (str) -> Bool in
                return str != ""
            }
            if arr.count <= 2 {
                return
            }
            if arr.contains("==") {
                
            } else if arr.contains(">=") {
                
            } else if arr.contains("~>") {
                
            }
            
            let module = SubModule(source: arr[0], url: arr[1], branch: (arr.count >= 3) ? (arr[2]) : "master" )
            list.append(module)
        }
        return list
    }()
    
    lazy var recordListPath: String = {
        return self.directoryPath.appending("/Modulefile.recordList")
    }()
    
    lazy var recordList: [String] = {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: self.recordListPath))
            let recordList = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<String>
            return recordList
        } catch {
            return []
        }
    }()
    
    lazy var checkoutsPath: String = {
        let modulePath = self.modulePath.appending("/checkouts")
        return modulePath
    }()
    
    lazy var buildsPath: String = {
        let buildPath = self.modulePath.appending("/Builds")
        return buildPath
    }()
    
    lazy var buildPath: String = {
        let buildPath = self.directoryPath.appending("/Build")
        return buildPath
    }()
    
    lazy var modulePath: String = {
        let buildPath = self.directoryPath.appending("/Module")
        return buildPath
    }()
    
    
    lazy var rootProject: Project = {
        guard self.directoryPath.contains("/Module/checkouts") else {
            return self
        }
        let rootPath = self.directoryPath.replacingOccurrences(of: "/Module/checkouts/"+self.name, with: "")
        return Project.project(directoryPath: rootPath)!
    }()
    
    
    init(directoryPath: String, projectType: ProjectType) {
        self.directoryPath = directoryPath
        self.projectType = projectType
    }

}


extension Project {
    
    func writeRecordList(recordList: Array<String>, quiet: Bool?) {
        // 检查是否还有subModule。没有则直接return
        if recordList.isEmpty {
            return
        }
        
        // 过滤当前module的subModule，按照工程层级
        var list:[String] = []
        for item in recordList {
            if !list.contains(item) {
                list.append(item)
            }
        }
        // 写入当前工程所有subModule
        let oldRecordList = self.recordList
        if oldRecordList.isEmpty || !list.elementsEqual(oldRecordList)  {
            do {
                let data = try JSONSerialization.data(withJSONObject: list, options: .fragmentsAllowed)
                try data.write(to: URL(fileURLWithPath: self.recordListPath), options: .atomicWrite)
                if quiet != false {po(tip: "【\(self.name)】Modulefile.recordList 写入成功")}
            } catch {
                po(tip: "【\(self.name)】Modulefile.recordList 写入失败",type: .error)
            }
        }
    }
    
    private static func check(directoryPath: String) -> ProjectType? {
        
        let fileManager = FileManager.default
        
        guard let fileList = try? fileManager.contentsOfDirectory(atPath: directoryPath) else {
            return nil
        }
        var projectType: ProjectType?
        
        for file in fileList {
            if file == "Pods.xcodeproj" {
                return nil
            }
            if file.hasSuffix(".xcworkspace") {
                projectType = .xcworkspace("\(file)")
                break
            }
            
            if file.hasSuffix(".xcodeproj") {
                projectType = .xcodeproj("\(file)")
                continue
            }
            
        }
        return projectType
    }
    
    static func project(directoryPath: String = FileManager.default.currentDirectoryPath) -> Project? {
        
        guard let projectType = check(directoryPath: directoryPath) else {
            return nil
        }
        return Project(directoryPath: directoryPath, projectType: projectType)
    }
}

extension Project: Equatable {
    public static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.directoryPath == rhs.directoryPath
    }
    
    public static func != (lhs: Project, rhs: Project) -> Bool {
        return lhs.directoryPath != rhs.directoryPath
    }
}
