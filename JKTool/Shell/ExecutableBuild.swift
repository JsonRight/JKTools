//
//  ExecutableBuild.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/20.
//

import Foundation
import CommonCrypto

/// IOS build Framework commands
public extension ShellOutCommand {
    /// IOS build Framework Debug x86_64 iphonesimulator
    /// IOS build Framework Release arm64 iphoneos
    static func frameworkBuild(projectName:String,projectFilePath:String, derivedDataPath: String, configuration: String, sdk: String, verison: String, toPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration \(configuration) VALID_ARCHS='\(ValidArchs.framework(.Debug).archs())' -destination 'generic/platform=\(Platform(sdk).platform(configuration))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)"

        if ConfigOptions(configuration) == .Debug  {
            shell.connected(andCommand: "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration \(ConfigOptions.Release.rawValue) VALID_ARCHS='\(ValidArchs.framework(.Release).archs())' -destination 'generic/platform=\(Platform(sdk).platform(ConfigOptions.Release.rawValue))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)")
        }
        
        // cp Release shell
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk("Release"))/\(projectName).framework \(buildPath)/Universal/\(verison)/")
        
        // lipo Release & debug shell
        shell.connected(andCommand: "lipo -create")
        
        shell.connected(spaceCommand: "\(buildPath)/Build/Products/Release-\(Platform(sdk).sdk("Release"))/\(projectName).framework/\(projectName)")
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(spaceCommand: "\(buildPath)/Build/Products/Debug-\(Platform(sdk).sdk("Debug"))/\(projectName).framework/\(projectName)")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(projectName).framework/\(projectName)")
        // cp shell
        if let toPath = toPath {
            shell.connected(andCommand: "mkdir -p \(toPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName).framework \(toPath)")
        }
        
        return ShellOutCommand(string:shell)
    }
    
    static func frameworkWithCache(projectName:String, derivedDataPath: String, verison: String, toPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toPath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName).framework \(toPath)")
        return ShellOutCommand(string:shell)
    }
}

/// IOS build XCFramework commands
public extension ShellOutCommand {
    /// IOS build Framework Debug x86_64 iphonesimulator
    /// IOS build Framework Release arm64 iphoneos
    static func xcframeworkBuild(projectName:String,projectFilePath:String, derivedDataPath: String, configuration: String, sdk: String, verison: String, toPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration \(configuration) VALID_ARCHS='\(ValidArchs.framework(.Debug).archs())' -destination 'generic/platform=\(Platform(sdk).platform(configuration))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)"
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(andCommand: "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration \(ConfigOptions.Release.rawValue) VALID_ARCHS='\(ValidArchs.framework(.Release).archs())' -destination 'generic/platform=\(Platform(sdk).platform(ConfigOptions.Release.rawValue))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)")
        }
        // build shell
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "xcodebuild -create-xcframework")
        shell.connected(spaceCommand: "-framework \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk("Release"))/\(projectName).framework")
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(spaceCommand: "-framework \(buildPath)/Build/Products/Debug-\(Platform(sdk).sdk("Debug"))/\(projectName).framework")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(projectName).xcframework")
        
        // cp shell
        if let toPath = toPath {
            shell.connected(andCommand: "mkdir -p \(toPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName).xcframework \(toPath)")
        }
        
        return ShellOutCommand(string:shell)
    }
    
    static func xcframeworkWithCache(projectName:String, derivedDataPath: String, verison: String, toPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toPath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName).xcframework \(toPath)")
        return ShellOutCommand(string:shell)
    }
}

/// IOS build .a commands
public extension ShellOutCommand {
    
    /// IOS build Static.a
    static func staticBuild(projectName:String,projectFilePath:String, derivedDataPath: String, configuration: String, sdk: String, verison: String, toStaticPath: String?, toHeaderPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration \(configuration) VALID_ARCHS='\(ValidArchs.framework(.Debug).archs())' -destination 'generic/platform=\(Platform(sdk).platform(configuration))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)"
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(andCommand: "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration \(ConfigOptions.Release.rawValue) VALID_ARCHS='\(ValidArchs.framework(.Release).archs())' -destination 'generic/platform=\(Platform(sdk).platform(ConfigOptions.Release.rawValue))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)")
        }
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "lipo -create")
        shell.connected(spaceCommand: "\(buildPath)/Build/Products/Release-\(Platform(sdk).sdk("Release"))/\(projectName).a")
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(spaceCommand: "\(buildPath)/Build/Products/Debug-\(Platform(sdk).sdk("Debug"))/\(projectName).a")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(projectName).a")
        
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk("Release"))/include \(buildPath)/Universal/\(verison)/")
        if let toStaticPath = toStaticPath {
            shell.connected(andCommand: "mkdir -p \(toStaticPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName).a \(toStaticPath)")
        }
        if let toHeaderPath = toHeaderPath {
            shell.connected(andCommand: "mkdir -p \(toHeaderPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/include \(toHeaderPath)")
        }
        return ShellOutCommand(string:shell)
    }
    
    static func staticWithCache(projectName:String, derivedDataPath: String, verison: String, toStaticPath: String, toHeaderPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toStaticPath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName).a \(toStaticPath)")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/include \(toHeaderPath)")
        return ShellOutCommand(string:shell)
    }
}

/// IOS build Bundle commands
public extension ShellOutCommand {
    /// IOS build Bundle
    static func buildBundle(projectName:String, projectFilePath:String, derivedDataPath: String, sdk: String, verison: String, toBundlePath: String?) -> ShellOutCommand {
        
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        
        var shell = "xcodebuild -project \(projectFilePath) -scheme \(projectName)Bundle -configuration Release -destination 'generic/platform=\(Platform(sdk).platform("Release"))' -derivedDataPath \(buildPath)"
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk("Release"))/\(projectName)Bundle.bundle \(buildPath)/Universal/\(verison)/")
        if let toBundlePath = toBundlePath {
            shell.connected(andCommand: "mkdir -p \(toBundlePath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName)Bundle.bundle \(toBundlePath)")
        }

        return ShellOutCommand(string: shell)
    }
    static func bundleWithCache(projectName:String, derivedDataPath: String, verison: String, toBundlePath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toBundlePath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(projectName)Bundle.bundle \(toBundlePath)")
        return ShellOutCommand(string:shell)
    }
}

/// IOS archive upload fir  commands
public extension ShellOutCommand {
    /// IOS archive
    static func archive(scheme:String, isWorkspace:Bool, projectPath:String,configuration:String, export:String) -> ShellOutCommand {
        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(scheme).\(isWorkspace ? "xcworkspace" : "xcodeproj") -scheme \(scheme) -configuration \(configuration)"
        shell.connected(andCommand: "xcodebuild archive \(isWorkspace ? "-workspace" : "-project") \(scheme).\(isWorkspace ? "xcworkspace" : "xcodeproj") -scheme \(scheme) -configuration \(configuration) -archivePath \(projectPath)/Build/\(configuration)/\(scheme).xcarchive")
        shell.connected(andCommand: "xcodebuild -exportArchive -archivePath \(projectPath)/Build/\(configuration)/\(scheme).xcarchive -exportPath \(projectPath)/Build/\(configuration) -exportOptionsPlist \(export)")
        return ShellOutCommand(string: shell)
    }
}

public extension ShellOutCommand {
    static func MD5(string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

/// 通过Universal目录下文件夹名称获取verison
public extension ShellOutCommand {
    /// IOS framework cache
    static func readVerison(path:String) -> ShellOutCommand {
        let shell = "ls '\(path)'"
        return ShellOutCommand(string: shell)
    }
}
