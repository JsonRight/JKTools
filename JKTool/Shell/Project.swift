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
        case other
        
        func vaild() -> Bool {
            switch self {
            case .xcodeproj(_):
                return true
            case .xcworkspace(_):
                return true
            case .other:
                return false
            }
        }
        
        func isWorkSpace() -> Bool {
            switch self {
            case .xcodeproj(_):
                return false
            case .xcworkspace(_):
                return true
            case .other:
                return false
            }
        }
        func name() -> String {
            switch self {
            case .xcodeproj(let string):
                return string
            case .xcworkspace(let string):
                return string
            case .other:
                return ""
            }
        }
    }
    
    let fileManager = FileManager.default
    
    let directoryPath: String
    
    lazy var projectType: ProjectType = {
        
        var projectType = ProjectType.other
        
        let fileManager = FileManager.default
        
        guard let fileList = try? fileManager.contentsOfDirectory(atPath: self.directoryPath) else {
            return projectType
        }
        
        for file in fileList {
            if file == "Pods.xcodeproj" {
                return projectType
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
    }()
    
    public enum ProjectBuildType {
        case Static
        case Framework
        case Other
    }
                                          
    lazy var buildType: ProjectBuildType = {
        
        var buildType = ProjectBuildType.Other
        
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: self.directoryPath + "/\(self.projectType.name())/project.pbxproj")) else {
            return buildType
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: fileData, options: .mutableContainersAndLeaves, format: nil) as? [String:Any] else {
            return buildType
        }
        
        guard let rootObjectValue = plist["rootObject"] as? String else {
            return buildType
        }
        
        guard let objects = plist["objects"] as? [String:Any] else {
            return buildType
        }
        
        guard let projectObject = objects[rootObjectValue] as? [String:Any] else {
            return buildType
        }
        
        guard let targetsValue = projectObject["targets"] as? [String] else {
            return buildType
        }
        
        for target in targetsValue {
            guard let targetObject = objects[target] as? [String:Any] else {
                continue
            }
            guard let productType = targetObject["productType"] as? String else {
                continue
            }
            if productType == "com.apple.product-type.framework" {
                buildType = .Framework
                break
            }
            if productType == "com.apple.product-type.library.static" {
                buildType = .Static
                break
            }
        }
        
        return buildType
    }()
    
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
    lazy var moduleList:[SubProject] = {
        var list:[SubProject] = []
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
            
            let module = SubProject(name: arr[0], url: arr[1], branch: (arr.count >= 3) ? (arr[2]) : "master" )
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
        let checkoutsPath = self.directoryPath.appending("/\(JKToolConfig.sharedInstance.config.checkouts)")
        return checkoutsPath
    }()
    
    lazy var buildsPath: String = {
        let buildPath = self.directoryPath.appending("/\(JKToolConfig.sharedInstance.config.builds)")
        return buildPath
    }()
    
    lazy var buildPath: String = {
        let buildPath = self.directoryPath.appending("/\(JKToolConfig.sharedInstance.config.build)")
        return buildPath
    }()

    lazy var rootProject: Project = {
        guard let range = self.directoryPath.range(of: "/\(JKToolConfig.sharedInstance.config.checkouts)") else {
            return self
        }
        
        let rootPath = String(self.directoryPath[..<range.lowerBound])
        return Project.project(directoryPath: rootPath)!
    }()
    
    init(directoryPath: String) {
        self.directoryPath = directoryPath
    }

}


extension Project {
    
    func writeRecordList(recordList: Array<String>, quiet: Bool?) -> [String] {
        // 检查是否还有SubProject。没有则直接return
        if recordList.isEmpty {
            return []
        }
        
        // 过滤当前module的SubProject，按照工程层级
        var list:[String] = []
        for item in recordList {
            if !list.contains(item) {
                list.append(item)
            }
        }
        // 写入当前工程所有SubProject
        let oldRecordList = self.recordList
        if oldRecordList.isEmpty || !list.elementsEqual(oldRecordList)  {
            do {
                let data = try JSONSerialization.data(withJSONObject: list, options: .fragmentsAllowed)
                try data.write(to: URL(fileURLWithPath: self.recordListPath), options: .atomicWrite)
                if quiet != false {po(tip: "【\(self.name)】Modulefile.recordList 写入成功")}
            } catch {
                po(tip: "【\(self.name)】Modulefile.recordList 写入失败",type: .error)
            }
            return oldRecordList.compactMap { record in
                if !list.contains(record) {
                    return record
                }
                return nil
            }
        }
        return []
    }

    static func project(directoryPath: String = FileManager.default.currentDirectoryPath) -> Project?{
        let exist = FileManager.default.fileExists(atPath: directoryPath)
        if !exist {
            return nil
        }
        return Project(directoryPath: directoryPath)
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
