//
//  ConfigType.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

public protocol ExecutableTypeProtocol {
    var value: String {set get}
    init(_ value: String)
}

public class ExecutableType: ExecutableTypeProtocol, CustomStringConvertible, Equatable {
    public var value: String
    
    required public init(_ value: String) {
        self.value = value
    }
    
    public static func == (lhs: ExecutableType, rhs: ExecutableType) -> Bool {
        return lhs.value == rhs.value
    }
    
    public var description: String {
        return value
    }
    
}

public class ConfigType: ExecutableType {
    init(_ options: ConfigOptions) {
        super.init(options.rawValue)
    }
    
    required public init(_ value: String) {
        super.init(value)
    }
}

public class LibraryType: ExecutableType {
    init(_ options: LibraryOptions) {
        super.init(options.rawValue)
    }
    
    required public init(_ value: String) {
        super.init(value)
    }
}


public enum LibraryOptions: String {
    case Framework = "Framework"
    case XCFramework = "XCFramework"
    case Static = "Static"
}

public enum ConfigOptions: String {
    case Debug = "Debug"
    case Release = "Release"
    public init(_ string: String) {
        if string == "Release" {
            self = .Release
        }else{
            self = .Debug
        }
    }
    public func archs()-> String {
        switch self {
        case .Debug:
            return "x86_64"
        case .Release:
            return "arm64"
        }
    }
}

public enum ValidArchs {
    case framework(ConfigOptions)
    case xcframework(ConfigOptions)
    case a(ConfigOptions)
    
    public func archs()-> String {
        switch self {
        case .framework(let configOptions):
            switch configOptions {
            case .Debug:
                return "x86_64 i386"
            case .Release:
                return "arm64"
            }
        case .xcframework(let configOptions):
            switch configOptions {
            case .Debug:
                return "x86_64 i386"
            case .Release:
                return "arm64"
            }
        case .a(let configOptions):
            switch configOptions {
            case .Debug:
                return "x86_64 i386"
            case .Release:
                return "arm64"
            }
        }
    }
}

public enum Platform: String {
    case iOS,iPadOS,macOS,tvOS,watchOS,carPlayOS
    
    init(_ string: String) {
        switch string {
        case Platform.iOS.rawValue:
            self = .iOS
        case Platform.iPadOS.rawValue:
            self = .iPadOS
        case Platform.macOS.rawValue:
            self = .macOS
        case Platform.tvOS.rawValue:
            self = .tvOS
        case Platform.watchOS.rawValue:
            self = .watchOS
        case Platform.carPlayOS.rawValue:
            self = .carPlayOS
        default:
            self = .iOS
        }
    }
    
    func sdk(_ config: ConfigOptions) -> String {
        switch self {
        case .iOS where config == .Debug:
            return "iphonesimulator"
        case .iOS:
            return "iphoneos"
        case .iPadOS where config == .Debug:
            return "ipadsimulator"
        case .iPadOS:
            return "ipados"
        case .macOS:
            return "macosx"
        case .tvOS where config == .Debug:
            return "appletvsimulator"
        case .tvOS:
            return "appletvos"
        case .watchOS where config == .Debug:
            return "watchsimulator"
        case .watchOS:
            return "watchos"
        case .carPlayOS where config == .Debug:
            return "carplaysimulator"
        case .carPlayOS:
            return "carplayos"
        }
    }
    
    func platform(_ config: ConfigOptions) -> String {
        switch self {
        case .iOS where config == .Debug:
            return "iOS Simulator"
        case .iOS:
            return "iOS"
        case .iPadOS where config == .Debug:
            return "iPadOS Simulator"
        case .iPadOS:
            return "iPadOS"
        case .macOS:
            return "macOS"
        case .tvOS where config == .Debug:
            return "tvOS Simulator"
        case .tvOS:
            return "tvOS"
        case .watchOS where config == .Debug:
            return "watchOS Simulator"
        case .watchOS:
            return "watchOS"
        case .carPlayOS where config == .Debug:
            return "carPlayOS Simulator"
        case .carPlayOS:
            return "carPlayOS"
        }
    }
    func fileExtension() -> String {
        switch self {
        case .iOS :
            return "ipa"
        case .macOS:
            return "app"
        case .iPadOS:
            return "ipa"
        case .tvOS:
            return "ipa"
        case .watchOS:
            return "ipa"
        case .carPlayOS:
            return "ipa"
        }
    }
}

public struct ProjectConfigModel: Decodable {
    
    struct SaveConfigModel:Decodable {
        var path: String
        
    }

    struct ExportConfigModel:Decodable {
        
        var configuration: String
        
        var exportOptionsPath: String
        
        var saveConfig: SaveConfigModel?
        
    }
    
    struct CertificateConfigModel:Decodable {
        
        var macPwd: String
        
        var p12sPath: String
        
        var p12Pwd: String
        
        var profilesPath: String
        
    }
    
    struct UploadAccountAuthConfigModel:Decodable {
        
        var username: String
        
        var password: String
        
    }
    
    struct UploadApiAuthConfigModel:Decodable {
        
        var apiKey: String
        
        var apiIssuerID: String
        
        var authKeyPath: String
        
    }
    
    struct UploadConfigModel:Decodable {
        
        var accountAuthConfig: UploadAccountAuthConfigModel?
        
        var apiAuthConfig: UploadApiAuthConfigModel?
        
        var ipaPath: String?
        
    }
    
    var sdk: String
    
    var certificateConfig: CertificateConfigModel
    
    var exportConfigList: [ExportConfigModel]
    
    var uploadConfig: UploadConfigModel
    
}

public struct ProjectListsModel: Decodable {
    struct ProjectModel: Decodable {
        var configurations:[String]
        var name: String
        var schemes: [String]
        var targets: [String]
    }
    var project: ProjectModel
    
    func defaultScheme(_ sdk: String) -> String? {
        var scheme: String?
        if self.project.schemes.contains(self.project.name) {
            scheme = self.project.name
        } else {
            for sch in self.project.schemes {
                if sch.contains(self.project.name) && sch.contains(sdk) {
                    scheme = sch
                    break
                }
            }
            if scheme == nil {
                scheme = self.project.schemes.first
            }
        }
        return scheme
    }
    
    static func projectList(project: Project) -> ProjectListsModel? {
        guard let json = try? shellOut(to: .list(isWorkspace: project.projectType.isWorkSpace(),projectName: project.projectType.entrance(), projectPath: project.directoryPath), at: project.directoryPath),
              let data = json.data(using: .utf8),
              let projectList = try? JSONDecoder().decode(ProjectListsModel.self, from:data) else {
            return nil
        }
        return projectList
    }
}

public class JKToolConfig {
    
    struct Config: Decodable {
        var checkouts: String = "Module/checkouts"
        var builds: String = "Module/Builds"
        var build: String = "Build"
        var toolUrl: String = "https://gitee.com/jk14138/JKTools/releases/download/JKTool/JKTool"
    }
    
    var config: Config
    
    static let sharedInstance = JKToolConfig()
    private init() {
        let url = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Containers/com.jk.JKTool/Data/Documents/config.json")
        if let data = try? Data(contentsOf: url),let config = try? JSONDecoder().decode(Config.self, from: data) {
            self.config = config
        } else {
            self.config = Config()
        }
    }
}

