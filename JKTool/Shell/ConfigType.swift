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
        if string == "Debug" {
            self = .Debug
        }else{
            self = .Release
        }
    }
    public func archs()-> String {
        switch self {
        case .Debug:
            return "x86_64 i386"
        case .Release:
            return "arm64 armv7"
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
                return "arm64 armv7"
            }
        case .xcframework(let configOptions):
            switch configOptions {
            case .Debug:
                return "x86_64 i386"
            case .Release:
                return "arm64 armv7"
            }
        case .a(let configOptions):
            switch configOptions {
            case .Debug:
                return "x86_64 i386"
            case .Release:
                return "arm64 armv7"
            }
        }
    }
}

enum Platform: String {
    case iOS,iPadOS,macOS,tvOS,watchOS,carPlayOS
    
    init(_ string: String) {
        if string == "iOS" {
            self = .iOS
        } else if string == "iPadOS" {
            self = .iPadOS
        } else if string == "macOS" {
            self = .macOS
        } else if string == "tvOS" {
            self = .tvOS
        } else if string == "tvOS" {
            self = .tvOS
        } else if string == "watchOS" {
            self = .watchOS
        } else if string == "carPlayOS" {
            self = .carPlayOS
        } else {
            self = .iOS
        }
    }
    
    func sdk(_ string: String) -> String {
        switch self {
        case .iOS:
            if string == ConfigOptions.Debug.rawValue {
                return "iphonesimulator"
            }
            return "iphoneos"
        case .iPadOS:
            if string == ConfigOptions.Debug.rawValue {
                return "iphonesimulator"
            }
            return "iphoneos"
        case .macOS:
            return "macosx"
        case .tvOS:
            if string == ConfigOptions.Debug.rawValue {
                return "appletvsimulator"
            }
            return "appletvos"
        case .watchOS:
            if string == ConfigOptions.Debug.rawValue {
                return "watchsimulator"
            }
            return "watchos"
        case .carPlayOS:
            if string == ConfigOptions.Debug.rawValue {
                return "carplaysimulator"
            }
            return "carplayos"
        }
    }
    
    func platform(_ string: String) -> String {
        switch self {
        case .iOS:
            if string == ConfigOptions.Debug.rawValue {
                return "iOS Simulator"
            }
            return "iOS"
        case .iPadOS:
            if string == ConfigOptions.Debug.rawValue {
                return "iPadOS Simulator"
            }
            return "iPadOS"
        case .macOS:
            return "macOS"
        case .tvOS:
            if string == ConfigOptions.Debug.rawValue {
                return "tvOS Simulator"
            }
            return "tvOS"
        case .watchOS:
            if string == ConfigOptions.Debug.rawValue {
                return "watchOS Simulator"
            }
            return "watchOS"
        case .carPlayOS:
            if string == ConfigOptions.Debug.rawValue {
                return "carPlayOS Simulator"
            }
            return "carPlayOS"
        }
    }
}


