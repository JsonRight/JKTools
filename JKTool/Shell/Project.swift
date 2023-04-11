//
//  Project.swift
//  JKTool
//
//  Created by 姜奎 on 2020/5/29.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

public func destinationForPath(path: String) ->String {
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
        
        // 工程开启入口名称
        func entrance() -> String {
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
        case Application
        case Other
    }
                                          
    lazy var buildType: ProjectBuildType = {
        
        var buildType = ProjectBuildType.Other
        
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: self.directoryPath + "/\(self.projectType.entrance())/project.pbxproj")) else {
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
            if productType == "com.apple.product-type.application" {
                buildType = .Application
                break
            }
        }
        
        return buildType
    }()
    
    lazy var bundleName: String = {
        
        var bundleName = ""
        
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: self.directoryPath + "/\(self.projectType.entrance())/project.pbxproj")) else {
            return bundleName
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: fileData, options: .mutableContainersAndLeaves, format: nil) as? [String:Any] else {
            return bundleName
        }
        
        guard let rootObjectValue = plist["rootObject"] as? String else {
            return bundleName
        }
        
        guard let objects = plist["objects"] as? [String:Any] else {
            return bundleName
        }
        
        guard let projectObject = objects[rootObjectValue] as? [String:Any] else {
            return bundleName
        }
        
        guard let targetsValue = projectObject["targets"] as? [String] else {
            return bundleName
        }
        
        for target in targetsValue {
            guard let targetObject = objects[target] as? [String:Any] else {
                continue
            }
            guard let productType = targetObject["productType"] as? String else {
                continue
            }
            guard let name = targetObject["name"] as? String else {
                continue
            }
            if productType == "com.apple.product-type.bundle" {
                bundleName = name
                break
            }
        }
        
        return bundleName
    }()
    
    lazy var dstPath: String = {
        var dstPath = ""
        
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: self.directoryPath + "/\(self.projectType.entrance())/project.pbxproj")) else {
            return dstPath
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: fileData, options: .mutableContainersAndLeaves, format: nil) as? [String:Any] else {
            return dstPath
        }
        
        guard let rootObjectValue = plist["rootObject"] as? String else {
            return dstPath
        }
        
        guard let objects = plist["objects"] as? [String:Any] else {
            return dstPath
        }
        
        guard let projectObject = objects[rootObjectValue] as? [String:Any] else {
            return dstPath
        }
        
        guard let targetsValue = projectObject["targets"] as? [String] else {
            return dstPath
        }
        
        for target in targetsValue {
            guard let targetObject = objects[target] as? [String:Any] else {
                continue
            }
            guard let productType = targetObject["productType"] as? String else {
                continue
            }
            guard let buildPhasesValue = targetObject["buildPhases"] as? String else {
                continue
            }
            if productType == "com.apple.product-type.library.static" {
                guard let buildPhases = objects[buildPhasesValue] as? [String:Any] else {
                    continue
                }
                guard let dst = targetObject["dstPath"] as? String else {
                    continue
                }
                dstPath = dst
                break
            }
        }
        
        return dstPath
    }()
    
    lazy var teamID: String = {
        
        var teamID = ""
        
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: self.directoryPath + "/\(self.projectType.entrance())/project.pbxproj")) else {
            return teamID
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: fileData, options: .mutableContainersAndLeaves, format: nil) as? [String:Any] else {
            return teamID
        }
        
        guard let rootObjectValue = plist["rootObject"] as? String else {
            return teamID
        }
        
        guard let objects = plist["objects"] as? [String:Any] else {
            return teamID
        }
        
        guard let projectObject = objects[rootObjectValue] as? [String:Any] else {
            return teamID
        }
        
        guard let targetsValue = projectObject["targets"] as? [String] else {
            return teamID
        }
        
        for target in targetsValue {
            guard let targetObject = objects[target] as? [String:Any] else {
                continue
            }
            guard let productType = targetObject["productType"] as? String else {
                continue
            }
            guard let buildConfigurationListValue = targetObject["buildConfigurationList"] as? String else {
                continue
            }
            if productType == "com.apple.product-type.bundle" {
                guard let buildConfigurationList = objects[buildConfigurationListValue] as? [String:Any] else {
                    continue
                }
                guard let buildConfigurations = targetObject["buildConfigurations"] as? [String] else {
                    continue
                }
                for buildConfigurationValue in buildConfigurations {
                    guard let buildConfiguration = objects[buildConfigurationValue] as? [String:Any] else {
                        continue
                    }
                    guard let name = buildConfiguration["name"] as? String else {
                        continue
                    }
                    guard let buildSettings = buildConfiguration["buildSettings"] as? [String:Any] else {
                        continue
                    }
                    if name == "Release" {
                        guard let DEVELOPMENT_TEAM = buildSettings["DEVELOPMENT_TEAM"] as? String else {
                            continue
                        }
                        
                        teamID = DEVELOPMENT_TEAM
                        break
                    }
                }
            }
        }
        
        return teamID
    }()
    // 工程所在目录名称
    lazy var destination: String = {
        return destinationForPath(path: self.directoryPath)
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
            
            let module = SubProject(name: arr[0], url: arr[1], branch: (arr.count >= 3) ? (arr[2]) : nil )
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
    
    lazy var buildLogPath: String = {
        return self.buildPath.appending("/buildLog.log")
    }()
    lazy var buildBundleLogPath: String = {
        return self.buildPath.appending("/buildBundleLog.log")
    }()
    lazy var buildScriptPath: String = {
        return self.directoryPath.appending("/build.sh")
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
    
    func writeRecordList(recordList: Array<String>) -> [String] {
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
                po(tip: "【\(self.destination)】Modulefile.recordList 写入成功")
            } catch {
                po(tip: "【\(self.destination)】Modulefile.recordList 写入失败",type: .error)
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
    
    func writeBuildLog(log: String) {
        do {
            let data = log.data(using: .utf8)
            try data?.write(to: URL(fileURLWithPath: self.buildLogPath), options: .atomicWrite)
            po(tip: "【\(self.destination)】buildLog.log 写入成功")
        } catch {
            po(tip: "【\(self.destination)】buildLog.log 写入失败",type: .error)
        }
    }
    
    func removeBuildLog() {
        let exist = FileManager.default.fileExists(atPath: self.buildLogPath)
        if !exist {
            try? FileManager.default.removeItem(atPath: self.buildLogPath)
        }
    }
    
    func writeBuildBundleLog(log: String) {
        do {
            let data = log.data(using: .utf8)
            try data?.write(to: URL(fileURLWithPath: self.buildBundleLogPath), options: .atomicWrite)
            po(tip: "【\(self.destination)】buildBundleLog.log 写入成功")
        } catch {
            po(tip: "【\(self.destination)】buildBundleLog.log 写入失败",type: .error)
        }
    }
    
    func removeBuildBundleLog() {
        let exist = FileManager.default.fileExists(atPath: self.buildBundleLogPath)
        if !exist {
            try? FileManager.default.removeItem(atPath: self.buildBundleLogPath)
        }
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
