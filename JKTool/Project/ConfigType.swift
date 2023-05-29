//
//  ConfigType.swift
//  JKTool
//
//  Created by 姜奎 on 2020/6/23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation

public enum LibraryOptions: String {
    case Framework = "Framework"
    case XCFramework = "XCFramework"
    case Static = "Static"
}

public enum SdkType: String {
    case Simulator, RealMachine
    init(_ isSimulators: Bool?) {
        switch isSimulators {
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
    
    func arch(_ sdk: SdkType) -> String {
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
    func archs(_ sdks: [SdkType]) -> [String] {
        return sdks.compactMap { sdk in
            return arch(sdk)
        }
    }
    
    func libBuildPath(_ configuration: String,sdk: SdkType) -> String {
        switch self {
        case .iOS where sdk == .Simulator:
            return "\(configuration)-\(self.sdk(sdk))"
        case .iOS:
            return "\(configuration)-\(self.sdk(sdk))"
        case .iPadOS where sdk == .Simulator:
            return "\(configuration)-\(self.sdk(sdk))"
        case .iPadOS:
            return "\(configuration)-\(self.sdk(sdk))"
        case .macOS where sdk == .Simulator:
            return "\(configuration)"
        case .macOS:
            return "\(configuration)"
        case .tvOS where sdk == .Simulator:
            return "\(configuration)-\(self.sdk(sdk))"
        case .tvOS:
            return "\(configuration)-\(self.sdk(sdk))"
        case .watchOS where sdk == .Simulator:
            return "\(configuration)-\(self.sdk(sdk))"
        case .watchOS:
            return "\(configuration)-\(self.sdk(sdk))"
        case .carPlayOS where sdk == .Simulator:
            return "\(configuration)-\(self.sdk(sdk))"
        case .carPlayOS:
            return "\(configuration)-\(self.sdk(sdk))"
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
        var path: String?
        var allFiles: Bool?
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
    
    var needConfigurationInProductsPath: Bool?
    
    var certificateConfig: CertificateConfigModel
    
    var exportConfigList: [ExportConfigModel]
    
    var uploadConfig: UploadConfigModel
    
}


