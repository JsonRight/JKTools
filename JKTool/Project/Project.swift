//
//  Project.swift
//  JKTool
//
//  Created by 姜奎 on 2020/5/29.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation


enum WorkSpaceType {
    case xcodeproj(String)
    case xcworkspace(String,String)
    case other(String)
    
    func vaild() -> Bool {
        switch self {
        case .xcodeproj(_):
            return true
        case .xcworkspace(_,_):
            return true
        case .other(_):
            return false
        }
    }
    
    func isWorkSpace() -> Bool {
        switch self {
        case .xcodeproj(_):
            return false
        case .xcworkspace(_,_):
            return true
        case .other(_):
            return false
        }
    }
    
    // 工程开启入口名称
    func entrance() -> String {
        switch self {
        case .xcodeproj(let xcodeprojName):
            return xcodeprojName
        case .xcworkspace(_,let xcworkspaceName):
            return xcworkspaceName
        case .other(let destination):
            return destination
        }
    }
    
    // 工程名称
    func projectName() -> String {
        switch self {
        case .xcodeproj(let xcodeprojName):
            return String(xcodeprojName.prefix(while: { $0 != "." }))
        case .xcworkspace(_,let xcworkspaceName):
            return String(xcworkspaceName.prefix(while: { $0 != "." }))
        case .other(let destination):
            return destination
        }
    }
    
    // 工程开启入口名称
    func pbxprojPath() -> String? {
        switch self {
        case .xcodeproj(let xcodeprojName):
            return "/\(xcodeprojName)/project.pbxproj"
        case .xcworkspace(let xcodeprojName,_):
            return "/\(xcodeprojName)/project.pbxproj"
        case .other(_):
            return nil
        }
    }
}

enum BuildType: CustomStringConvertible {
    var description: String {
        return "\(self.libName()).\(self.ext())"
    }
    
    case Static(name: String,libName:String,dstPath: String)
    case Framework(name: String,libName:String)
    case Bundle(name: String,libName:String)
    
    func isStatic() -> Bool {
        switch self {
        case .Static(_,_,_):
            return true
        case .Framework(_,_):
            return false
        case .Bundle(_,_):
            return false
        }
    }
    
    func isFramework() -> Bool {
        switch self {
        case .Static(_,_,_):
            return false
        case .Framework(_,_):
            return true
        case .Bundle(_,_):
            return false
        }
    }
    
    func isBundle() -> Bool {
        switch self {
        case .Static(_,_,_):
            return false
        case .Framework(_,_):
            return false
        case .Bundle(_,_):
            return true
        }
    }
    
    func name() -> String {
        switch self {
        case .Static(let name,_,_):
            return name
        case .Framework(let name,_):
            return name
        case .Bundle(let name,_):
            return name
        }
    }
    
    func libName() -> String {
        switch self {
        case .Static(_,let libName,_):
            return libName
        case .Framework(_,let libName):
            return libName
        case .Bundle(_,let libName):
            return libName
        }
    }
    
    func ext(_ isXCFramework: Bool? = false) -> String {
        switch self {
        case .Static(_,_,_):
            return "a"
        case .Framework(_,_):
            return isXCFramework == true ? "xcframework":"framework"
        case .Bundle(_,_):
            return "bundle"
        }
    }
    
    func dstPath() -> String {
        switch self {
        case .Static(_,_,let dstPath)://"Copy (.*?)\\.h"
            return dstPath
        case .Framework(_,_):
            return ""
        case .Bundle(_,_):
            return ""
        }
    }
    
    func libBuildPath(_ configuration: String, sdk: String,sdkType: SdkType) -> String {
        return "\(Platform(sdk).libBuildPath(configuration, sdk: sdkType))"
    }
    
}

//struct BuildSettingsModel: Decodable {
//    struct SettingsModel: Decodable {
//        var BUILD_ROOT: String
//        var XCODE_PRODUCT_BUILD_VERSION: String
//
//    }
//    var action: String
//    var buildSettings: SettingsModel
//    var target: String
//
//    static func projectList(project: Project) -> BuildSettingsModel? {
//        guard let json = try? shellOut(to: .buildSettings(isWorkspace: project.workSpaceType.isWorkSpace(),projectName: project.workSpaceType.entrance(), projectPath: project.directoryPath), at: project.directoryPath),
//              let data = json.data(using: .utf8),
//              let projectList = try? JSONDecoder().decode([BuildSettingsModel].self, from:data) else {
//            return nil
//        }
//        return projectList.first
//    }
//}

class Project {
    
    let directoryPath: String
    
    lazy var pbxprojPlist: [String:Any]? = {
        guard let pbxprojPath = self.workSpaceType.pbxprojPath(),
              let fileData = try? Data(contentsOf: URL(fileURLWithPath: self.directoryPath + pbxprojPath)),
              let plist = try? PropertyListSerialization.propertyList(from: fileData, options: .mutableContainersAndLeaves, format: nil) as? [String:Any] else { return nil }
        return plist
    }()
    
    lazy var workSpaceType: WorkSpaceType = {
        guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: self.directoryPath) else { return .other(self.destination) }
        
        var xcodeprojName: String?,xcworkspaceName:String?
        
        for file in fileList {
            if file.hasSuffix(".xcworkspace") {
                xcworkspaceName = file
            }
            
            if file.hasSuffix(".xcodeproj") {
                xcodeprojName = file
            }
        }
        guard let xcodeprojName = xcodeprojName else { return .other(self.destination) }
        guard let xcworkspaceName = xcworkspaceName else { return .xcodeproj(xcodeprojName) }
        return .xcworkspace(xcodeprojName, xcworkspaceName)
    }()
    
    lazy var targets: [BuildType] = {
        
        var targets = [BuildType]()
        
        guard let plist = self.pbxprojPlist,
              let rootObjectValue = plist["rootObject"] as? String,
              let objects = plist["objects"] as? [String:Any],
              let projectObject = objects[rootObjectValue] as? [String:Any],
              let targetsValue = projectObject["targets"] as? [String] else { return targets }
        

        for target in targetsValue {
            
            guard let targetObject = objects[target] as? [String:Any],
                  let productType = targetObject["productType"] as? String,
                  let name = targetObject["name"] as? String,
                  let productReferenceValue = targetObject["productReference"] as? String,
                  let productReference = objects[productReferenceValue] as? [String: Any],
                  let path = productReference["path"] as? String else { continue }
            
            let libName = String(path.prefix(while: { $0 != "." }))
            
            switch productType {
            case "com.apple.product-type.framework":
                targets.append(.Framework(name: name, libName: libName))
                continue
            case "com.apple.product-type.library.static":
                guard let buildPhases = targetObject["buildPhases"] as? [String] else { continue }
                
                for buildPhasesValue in buildPhases {
                    guard let copyFlies = objects[buildPhasesValue] as? [String:Any] else { continue }
                    guard let dst = copyFlies["dstPath"] as? String else { continue }
                    targets.append(.Static(name: name, libName: libName, dstPath: String(dst.prefix(while: { $0 != "$" }))))
                    continue
                }
                
                break
            case "com.apple.product-type.bundle":
                targets.append(.Bundle(name: name, libName: libName))
                continue
            default:
                continue
            }
            
        }
        return targets
    }()
    
    lazy var defaultTarget: String = {
        guard self.targets.count > 0 else { return self.destination }
        guard let name = self.targets.first(where: { $0.isBundle() == false })?.name() else { return self.targets.first!.name() }
        return name
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
        let checkoutsPath = self.directoryPath.appending("/\(ModulesConfigs.sharedInstance.config.checkouts)")
        return checkoutsPath
    }()
    
    lazy var buildsPath: String = {
        let buildPath = self.directoryPath.appending("/\(ModulesConfigs.sharedInstance.config.builds)")
        return buildPath
    }()
    
    lazy var buildPath: String = {
        let buildPath = self.directoryPath.appending("/\(ModulesConfigs.sharedInstance.config.build)")
        return buildPath
    }()

    lazy var rootProject: Project = {
        guard let range = self.directoryPath.range(of: "/\(ModulesConfigs.sharedInstance.config.checkouts)") else {
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
    
    /// 写入RecordList
    /// - Parameter recordList: 需要写入的List
    /// - Returns: 返回剔除的旧item
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
                po(tip: "【\(self.workSpaceType.projectName())】Modulefile.recordList 写入成功")
            } catch {
                po(tip: "【\(self.workSpaceType.projectName())】Modulefile.recordList 写入失败",type: .error)
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
        let data = log.data(using: .utf8)
        _ = try? data?.write(to: URL(fileURLWithPath: self.buildLogPath), options: .atomicWrite)
    }
    
    func removeBuildLog() {
        let exist = FileManager.default.fileExists(atPath: self.buildLogPath)
        if !exist {
            try? FileManager.default.removeItem(atPath: self.buildLogPath)
        }
    }
    
    func writeBuildBundleLog(log: String) {
        let data = log.data(using: .utf8)
        _ = try? data?.write(to: URL(fileURLWithPath: self.buildBundleLogPath), options: .atomicWrite)
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

public func destinationForPath(path: String) ->String {
    return URL(fileURLWithPath: path).lastPathComponent
}
