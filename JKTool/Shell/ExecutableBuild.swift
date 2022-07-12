//
//  ExecutableBuild.swift
//  JKTool
//
//  Created by 姜奎 on 2022/6/20.
//

import Foundation
import CommonCrypto

/// build Framework commands
public extension ShellOutCommand {
    /// IOS build Framework Debug x86_64 iphonesimulator
    /// IOS build Framework Release arm64 iphoneos
    static func frameworkBuild(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, configuration: String, sdk: String, verison: String, toPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(ConfigOptions(configuration).archs())' -destination 'generic/platform=\(Platform(sdk).platform(ConfigOptions(configuration)))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)"

        if ConfigOptions(configuration) == .Debug  {
            shell.connected(andCommand: "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(ConfigOptions.Release) VALID_ARCHS='\(ConfigOptions.Release.archs())' -destination 'generic/platform=\(Platform(sdk).platform(.Release))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)")
        }
        
        // cp Release shell
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.Release))/\(scheme).framework \(buildPath)/Universal/\(verison)/")
        
        // lipo Release & debug shell
        shell.connected(andCommand: "lipo -create")
        
        shell.connected(spaceCommand: "\(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.Release))/\(scheme).framework/\(scheme)")
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(spaceCommand: "\(buildPath)/Build/Products/Debug-\(Platform(sdk).sdk(.Debug))/\(scheme).framework/\(scheme)")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(scheme).framework/\(scheme)")
        // cp shell
        if let toPath = toPath {
            shell.connected(andCommand: "mkdir -p \(toPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).framework \(toPath)")
        }
        
        return ShellOutCommand(string:shell)
    }
    
    static func frameworkWithCache(scheme:String, derivedDataPath: String, verison: String, toPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toPath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).framework \(toPath)")
        return ShellOutCommand(string:shell)
    }
}

/// build XCFramework commands
public extension ShellOutCommand {
    /// IOS build Framework Debug x86_64 iphonesimulator
    /// IOS build Framework Release arm64 iphoneos
    static func xcframeworkBuild(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, configuration: String, sdk: String, verison: String, toPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(ConfigOptions(configuration).archs())' -destination 'generic/platform=\(Platform(sdk).platform(ConfigOptions(configuration)))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)"
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(andCommand: "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(ConfigOptions.Release) VALID_ARCHS='\(ConfigOptions.Release.archs())' -destination 'generic/platform=\(Platform(sdk).platform(.Release))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)")
        }
        // build shell
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "xcodebuild -create-xcframework")
        shell.connected(spaceCommand: "-framework \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.Release))/\(scheme).framework")
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(spaceCommand: "-framework \(buildPath)/Build/Products/Debug-\(Platform(sdk).sdk(.Debug))/\(scheme).framework")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(scheme).xcframework")
        
        // cp shell
        if let toPath = toPath {
            shell.connected(andCommand: "mkdir -p \(toPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).xcframework \(toPath)")
        }
        
        return ShellOutCommand(string:shell)
    }
    
    static func xcframeworkWithCache(scheme:String, derivedDataPath: String, verison: String, toPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toPath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).xcframework \(toPath)")
        return ShellOutCommand(string:shell)
    }
}

/// build .a commands
public extension ShellOutCommand {
    
    /// IOS build Static.a
    static func staticBuild(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, configuration: String, sdk: String, verison: String, toStaticPath: String?, toHeaderPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(ConfigOptions(configuration).archs())' -destination 'generic/platform=\(Platform(sdk).platform(ConfigOptions(configuration)))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)"
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(andCommand: "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(ConfigOptions.Release) VALID_ARCHS='\(ConfigOptions.Release.archs())' -destination 'generic/platform=\(Platform(sdk).platform(.Release))' ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES -UseModernBuildSystem=YES -derivedDataPath \(buildPath)")
        }
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "lipo -create")
        shell.connected(spaceCommand: "\(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.Release))/\(scheme).a")
        if ConfigOptions(configuration) == .Debug  {
            shell.connected(spaceCommand: "\(buildPath)/Build/Products/Debug-\(Platform(sdk).sdk(.Debug))/\(scheme).a")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(scheme).a")
        
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.Release))/include \(buildPath)/Universal/\(verison)/")
        if let toStaticPath = toStaticPath {
            shell.connected(andCommand: "mkdir -p \(toStaticPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).a \(toStaticPath)")
        }
        if let toHeaderPath = toHeaderPath {
            shell.connected(andCommand: "mkdir -p \(toHeaderPath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/include \(toHeaderPath)")
        }
        return ShellOutCommand(string:shell)
    }
    
    static func staticWithCache(scheme:String, derivedDataPath: String, verison: String, toStaticPath: String, toHeaderPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toStaticPath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).a \(toStaticPath)")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/include \(toHeaderPath)")
        return ShellOutCommand(string:shell)
    }
}

/// build Bundle commands
public extension ShellOutCommand {
    /// IOS build Bundle
    static func buildBundle(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, sdk: String, verison: String, toBundlePath: String?) -> ShellOutCommand {
        
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        
        var shell = "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme)Bundle -configuration \(ConfigOptions.Release) -destination 'generic/platform=\(Platform(sdk).platform(.Release))' -derivedDataPath \(buildPath)"
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.Release))/\(scheme)Bundle.bundle \(buildPath)/Universal/\(verison)/")
        if let toBundlePath = toBundlePath {
            shell.connected(andCommand: "mkdir -p \(toBundlePath)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme)Bundle.bundle \(toBundlePath)")
        }

        return ShellOutCommand(string: shell)
    }
    static func bundleWithCache(scheme:String, derivedDataPath: String, verison: String, toBundlePath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "mkdir -p \(toBundlePath)"
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme)Bundle.bundle \(toBundlePath)")
        return ShellOutCommand(string:shell)
    }
}

/// archive commands
public extension ShellOutCommand {
    
    /// IOS archive VALID_ARCHS=\("arm64")
    static func archive(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String,configuration:String, validArchs:[String]?, sdk: String, export:String, nameSuffix:String?,toSavePath:String?) -> ShellOutCommand {
        
        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration)"
        shell.connected(andCommand: "xcodebuild archive \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration)")
        if let validArchs = validArchs, validArchs.isEmpty == false {
            shell.connected(spaceCommand: "VALID_ARCHS=\(validArchs.joined(separator: " "))")
        }
        shell.connected(spaceCommand: "-archivePath \(projectPath)/Build/\(configuration)/\(scheme).xcarchive")
        shell.connected(andCommand: "xcodebuild -exportArchive -archivePath \(projectPath)/Build/\(configuration)/\(scheme).xcarchive -exportPath \(projectPath)/Build/\(configuration) -exportOptionsPlist \(export)")
        if let toSavePath = toSavePath ,toSavePath != "" {
            shell.connected(andCommand: "cp -R \(projectPath)/Build/\(configuration)/\(scheme).ipa \(toSavePath)/\(scheme)\(configuration)\(nameSuffix ?? "").ipa")
        }
        return ShellOutCommand(string: shell)
    }
}

/// archive commands
public extension ShellOutCommand {
    
    /// IOS archive VALID_ARCHS=\("arm64")
    static func upload(path:String, username: String, password: String) -> ShellOutCommand {
        
        var shell = "altool --validate-app -f \(path) -u \(username) -p \(password) --output-format xml"
        shell.connected(andCommand: "altool --upload-app -f \(path) -u \(username) -p \(password) --output-format xml")
        return ShellOutCommand(string: shell)
    }
}

/// archive upload fir  commands
public extension ShellOutCommand {
    static func list(isWorkspace:Bool,projectName: String, projectPath:String) -> ShellOutCommand {
        let shell = "xcodebuild -list \(isWorkspace ? "-workspace" : "-project") \(projectPath)/\(projectName) -json"
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

/// 证书管理
public extension ShellOutCommand {
    // 解锁钥匙串
    static func unlockSecurity(password: String) -> ShellOutCommand {
        var shell = "security default-keychain -s ~/Library/Keychains/login.keychain-db"
        shell.connected(andCommand: "security unlock-keychain -p \(password) ~/Library/Keychains/login.keychain-db")
        return ShellOutCommand(string: shell)
    }
    
    // 安装.p12文件
    static func importP12(p12sPath: String, password: String) -> ShellOutCommand {
        let shell = """
        pushd \(p12sPath)
        function FileSuffix() {
          local filename=$1
          echo ${filename##*.}
        }
        for file in * ;do
          if [ $(FileSuffix ${file}) = 'p12' ]
            then
             security import ${file} -k ~/Library/Keychains/login.keychain-db -P 123456
          else
            continue
          fi
        done
        popd
        """
        return ShellOutCommand(string: shell)
    }
    
    // 安装.mobileprovision文件
    static func installProfiles(profilesPath: String) -> ShellOutCommand {
        let shell = """
                    pushd \(profilesPath)
                    function FileSuffix() {
                      local filename=$1
                      echo ${filename##*.}
                    }
                    for file in * ;do
                      if [ $(FileSuffix ${file}) = 'mobileprovision' ]
                        then
                          uuid=`/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< $(/usr/bin/security cms -D -i ${file})`
                          cp -R ${file} ~/Library/MobileDevice/Provisioning\\ Profiles/${uuid}.mobileprovision
                        else
                          continue
                        fi
                    done
                    popd
                    """
        return ShellOutCommand(string: shell)
    }
    
}
