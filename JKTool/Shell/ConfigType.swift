//
//  ConfigType.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

//public protocol ExecutableTypeProtocol {
//    var value: String {set get}
//    init(_ value: String)
//}
//
//public class ExecutableType: ExecutableTypeProtocol, CustomStringConvertible, Equatable {
//    public var value: String
//
//    required public init(_ value: String) {
//        self.value = value
//    }
//
//    public static func == (lhs: ExecutableType, rhs: ExecutableType) -> Bool {
//        return lhs.value == rhs.value
//    }
//
//    public var description: String {
//        return value
//    }
//
//}
//
//public class ConfigType: ExecutableType {
//    init(_ options: ConfigOptions) {
//        super.init(options.rawValue)
//    }
//
//    required public init(_ value: String) {
//        super.init(value)
//    }
//}
//
//public class LibraryType: ExecutableType {
//    init(_ options: LibraryOptions) {
//        super.init(options.rawValue)
//    }
//
//    required public init(_ value: String) {
//        super.init(value)
//    }
//}


public enum LibraryOptions: String {
    case Framework = "Framework"
    case XCFramework = "XCFramework"
    case Static = "Static"
}

//public enum ConfigOptions: String {
//    case Debug = "Debug"
//    case Release = "Release"
//    public init(_ string: String) {
//        if string == "Release" {
//            self = .Release
//        }else{
//            self = .Debug
//        }
//    }
//}

public enum SdkType: String {
    case Simulator, RealMachine
    init(_ includedSimulators: Bool?) {
        switch includedSimulators {
        case true:
            self = .Simulator
        default:
            self = .RealMachine
        }
    }
}

public enum ValidArchs {
    case framework(SdkType)
    case xcframework(SdkType)
    case a(SdkType)
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
//    ${PLATFORM_NAME} = iphoneos
//    ${EFFECTIVE_PLATFORM_NAME} = -iphoneos
    func sdk(_ sdk: SdkType) -> String {
        switch self {
        case .iOS where sdk == .Simulator:
            return "iphonesimulator"
        case .iOS:
            return "iphoneos"
        case .iPadOS where sdk == .Simulator:
            return "ipadsimulator"
        case .iPadOS:
            return "ipados"
        case .macOS:
            return "macosx"
        case .tvOS where sdk == .Simulator:
            return "appletvsimulator"
        case .tvOS:
            return "appletvos"
        case .watchOS where sdk == .Simulator:
            return "watchsimulator"
        case .watchOS:
            return "watchos"
        case .carPlayOS where sdk == .Simulator:
            return "carplaysimulator"
        case .carPlayOS:
            return "carplayos"
        }
    }
    
    func platform(_ sdk: SdkType) -> String {
        switch self {
        case .iOS where sdk == .Simulator:
            return "iOS Simulator"
        case .iOS:
            return "iOS"
        case .iPadOS where sdk == .Simulator:
            return "iPadOS Simulator"
        case .iPadOS:
            return "iPadOS"
        case .macOS:
            return "macOS"
        case .tvOS where sdk == .Simulator:
            return "tvOS Simulator"
        case .tvOS:
            return "tvOS"
        case .watchOS where sdk == .Simulator:
            return "watchOS Simulator"
        case .watchOS:
            return "watchOS"
        case .carPlayOS where sdk == .Simulator:
            return "carPlayOS Simulator"
        case .carPlayOS:
            return "carPlayOS"
        }
    }
    
    func archs(_ sdk: SdkType) -> String {
        switch self {
        case .iOS where sdk == .Simulator:
            return "x86_64"
        case .iOS:
            return "arm64"
        case .iPadOS where sdk == .Simulator:
            return "x86_64"
        case .iPadOS:
            return "arm64"
        case .macOS where sdk == .Simulator:
            return "x86_64"
        case .macOS:
            return "arm64"
        case .tvOS where sdk == .Simulator:
            return "x86_64"
        case .tvOS:
            return "arm64"
        case .watchOS where sdk == .Simulator:
            return "x86_64"
        case .watchOS:
            return "arm64"
        case .carPlayOS where sdk == .Simulator:
            return "x86_64"
        case .carPlayOS:
            return "arm64"
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
    
    func defaultScheme(_ sdk: String = "iOS") -> String? {
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
        var completionUrl: String = "https://gitee.com/jk14138/JKTools/releases/download/JKTool-completion/JKTool-completion"
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

