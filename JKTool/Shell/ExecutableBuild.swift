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
    static func frameworkBuild(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, configuration: String, sdk: String, includedSimulators: Bool?, verison: String, toPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path

        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) -quiet -UseModernBuildSystem=YES"
        
        shell.connected(andCommand: "xcodebuild build \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(Platform(sdk).archs(.RealMachine))' -destination 'generic/platform=\(Platform(sdk).platform(.RealMachine))' -UseModernBuildSystem=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -derivedDataPath \(buildPath)")
        shell.fileExisted(at: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/\(scheme).framework/\(scheme)")
        
        
        if includedSimulators == true  {
            shell.connected(andCommand: "xcodebuild build \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(Platform(sdk).archs(.Simulator))' -destination 'generic/platform=\(Platform(sdk).platform(.Simulator))' -UseModernBuildSystem=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -derivedDataPath \(buildPath)")
            shell.fileExisted(at: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.Simulator))/\(scheme).framework/\(scheme)")
        }
        
        
        // cp Release shell
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/\(scheme).framework \(buildPath)/Universal/\(verison)/")
        
        // lipo Release & debug shell
        shell.connected(andCommand: "lipo -create")
        
        shell.connected(spaceCommand: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/\(scheme).framework/\(scheme)")
        if includedSimulators == true  {
            shell.connected(spaceCommand: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.Simulator))/\(scheme).framework/\(scheme)")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(scheme).framework/\(scheme)")
        // cp shell
        if let toPath = toPath {
            shell.connected(andCommand: "mkdir -p \(toPath.convertRelativePath(absolutPath: projectPath))")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).framework \(toPath.convertRelativePath(absolutPath: projectPath))")
        }
        
        return ShellOutCommand(string:shell)
    }
    
    static func frameworkWithCache(scheme:String,projectPath:String, derivedDataPath: String, verison: String, toPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "".fileExisting(at: "\(buildPath)/Universal/\(verison)/\(scheme).framework/\(scheme)")
        shell.connected(andCommand: "mkdir -p \(toPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).framework \(toPath.convertRelativePath(absolutPath: projectPath))")
        return ShellOutCommand(string:shell)
    }
}

/// build XCFramework commands
public extension ShellOutCommand {
    /// IOS build Framework Debug x86_64 iphonesimulator
    /// IOS build Framework Release arm64 iphoneos
    static func xcframeworkBuild(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, configuration: String, sdk: String, includedSimulators: Bool?, verison: String, toPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        
        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) -quiet -UseModernBuildSystem=YES"
        
        shell.connected(andCommand: "xcodebuild build \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(Platform(sdk).archs(.RealMachine))' -destination 'generic/platform=\(Platform(sdk).platform(.RealMachine))' -UseModernBuildSystem=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -derivedDataPath \(buildPath)")
        shell.fileExisted(at: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/\(scheme).framework/\(scheme)")
        
        if includedSimulators == true  {
            shell.connected(andCommand: "xcodebuild build \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(Platform(sdk).archs(.Simulator))' -destination 'generic/platform=\(Platform(sdk).platform(.Simulator))' -UseModernBuildSystem=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -derivedDataPath \(buildPath)")
            shell.fileExisted(at: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.Simulator))/\(scheme).framework/\(scheme)")
        }

        // build shell
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "xcodebuild -create-xcframework")
        shell.connected(spaceCommand: "-framework \(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/\(scheme).framework")
        if includedSimulators == true  {
            shell.connected(spaceCommand: "-framework \(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.Simulator))/\(scheme).framework")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/\(scheme).xcframework")
        
        // cp shell
        if let toPath = toPath {
            shell.connected(andCommand: "mkdir -p \(toPath.convertRelativePath(absolutPath: projectPath))")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).xcframework \(toPath.convertRelativePath(absolutPath: projectPath))")
        }
        
        return ShellOutCommand(string:shell)
    }
    
    static func xcframeworkWithCache(scheme:String,projectPath:String, derivedDataPath: String, verison: String, toPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "".folderExisting(at: "\(buildPath)/Universal/\(verison)/\(scheme).xcframework")
        shell.connected(andCommand: "mkdir -p \(toPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme).xcframework \(toPath.convertRelativePath(absolutPath: projectPath))")
        return ShellOutCommand(string:shell)
    }
}

/// build .a commands
public extension ShellOutCommand {
    
    /// IOS build Static.a
    static func staticBuild(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, configuration: String, sdk: String, includedSimulators: Bool?, dstPath:String, verison: String, toStaticPath: String?, toHeaderPath: String?) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        
        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) -quiet -UseModernBuildSystem=YES"
        
        shell.connected(andCommand: "xcodebuild build \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(Platform(sdk).archs(.RealMachine))' -destination 'generic/platform=\(Platform(sdk).platform(.RealMachine))' -UseModernBuildSystem=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -derivedDataPath \(buildPath)")
        shell.fileExisted(at: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/lib\(scheme).a")
        
        if includedSimulators == true  {
            shell.connected(andCommand: "xcodebuild build \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) VALID_ARCHS='\(Platform(sdk).archs(.Simulator))' -destination 'generic/platform=\(Platform(sdk).platform(.Simulator))' -UseModernBuildSystem=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -derivedDataPath \(buildPath)")
            shell.fileExisted(at: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.Simulator))/lib\(scheme).a")
        }
        
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "lipo -create")
        shell.connected(spaceCommand: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/lib\(scheme).a")
        if includedSimulators == true  {
            shell.connected(spaceCommand: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.Simulator))/lib\(scheme).a")
        }
        shell.connected(spaceCommand: "-output \(buildPath)/Universal/\(verison)/lib\(scheme).a")
        
        shell.connected(ifCommand: "cp -R \(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/\(dstPath) \(buildPath)/Universal/\(verison)/", at: "\(buildPath)/Build/Products/\(configuration)-\(Platform(sdk).sdk(.RealMachine))/\(dstPath)")
        
        if let toStaticPath = toStaticPath {
            shell.connected(andCommand: "mkdir -p \(toStaticPath.convertRelativePath(absolutPath: projectPath))")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/lib\(scheme).a \(toStaticPath.convertRelativePath(absolutPath: projectPath))")
        }
        if let toHeaderPath = toHeaderPath {
            shell.connected(ifCommand: "mkdir -p \(toHeaderPath.convertRelativePath(absolutPath: projectPath))", at: "\(buildPath)/Universal/\(verison)/\(scheme)")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme) \(toHeaderPath.convertRelativePath(absolutPath: projectPath))")
        }
        return ShellOutCommand(string:shell)
    }
    
    static func staticWithCache(scheme:String,projectPath:String, derivedDataPath: String, verison: String, toStaticPath: String, toHeaderPath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "".fileExisting(at: "\(buildPath)/Universal/\(verison)/lib\(scheme).a")
        
        shell.connected(andCommand: "mkdir -p \(toStaticPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/lib\(scheme).a \(toStaticPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(ifCommand: "mkdir -p \(toHeaderPath.convertRelativePath(absolutPath: projectPath))", at: "\(buildPath)/Universal/\(verison)/\(scheme)")
        shell.connected(ifCommand: "cp -R \(buildPath)/Universal/\(verison)/\(scheme) \(toHeaderPath.convertRelativePath(absolutPath: projectPath))", at: "\(buildPath)/Universal/\(verison)/\(scheme)")
        return ShellOutCommand(string:shell)
    }
}

/// build Bundle commands
public extension ShellOutCommand {
    /// IOS build Bundle
    static func buildBundle(bundleName:String, isWorkspace:Bool,projectName: String, projectPath:String, derivedDataPath: String, sdk: String, codeSignAllowed:Bool, verison: String, toBundlePath: String?) -> ShellOutCommand {
        
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(bundleName) -configuration Release -quiet -UseModernBuildSystem=YES"
        
        shell.connected(andCommand: "xcodebuild build \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(bundleName) -configuration Release -destination 'generic/platform=\(Platform(sdk).platform(.RealMachine))' -derivedDataPath \(buildPath)\(codeSignAllowed == false ? " CODE_SIGNING_ALLOWED=NO" : "")")
            
        shell.folderExisted(at: "\(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.RealMachine))/\(bundleName).bundle")
        
        shell.connected(andCommand: "mkdir -p \(buildPath)/Universal/\(verison)/")
        shell.connected(andCommand: "cp -R \(buildPath)/Build/Products/Release-\(Platform(sdk).sdk(.RealMachine))/\(bundleName).bundle \(buildPath)/Universal/\(verison)/")
        if let toBundlePath = toBundlePath {
            shell.connected(andCommand: "mkdir -p \(toBundlePath.convertRelativePath(absolutPath: projectPath))")
            shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(bundleName).bundle \(toBundlePath.convertRelativePath(absolutPath: projectPath))")
        }

        return ShellOutCommand(string: shell)
    }
    static func bundleWithCache(bundleName:String,projectPath:String, derivedDataPath: String, verison: String, toBundlePath: String) -> ShellOutCommand {
        let buildPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        var shell = "".folderExisting(at: "\(buildPath)/Universal/\(verison)/\(bundleName).bundle")
        shell.connected(andCommand: "mkdir -p \(toBundlePath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(bundleName).bundle \(toBundlePath.convertRelativePath(absolutPath: projectPath))")
        return ShellOutCommand(string:shell)
    }
}

/// archive commands
public extension ShellOutCommand {
    
    /// IOS archive VALID_ARCHS=\("arm64")
    static func archive(scheme:String, isWorkspace:Bool,projectName: String, buildPath:String,configuration:String, sdk: String) -> ShellOutCommand {
        
        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme)"
        shell.connected(andCommand: "xcodebuild archive \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration)")
        shell.connected(spaceCommand: "-archivePath \(buildPath)/\(configuration)/\(scheme).xcarchive")
        return ShellOutCommand(string: shell)
    }
}

/// export commands
public extension ShellOutCommand {
    
    /// IOS archive VALID_ARCHS=\("arm64")
    static func export(scheme:String, buildPath:String,configuration:String, export:String, fileExtension: String,toSavePath:String?) -> ShellOutCommand {
        var shell = "".folderExisting(at: "\(buildPath)/\(configuration)/\(scheme).xcarchive")
        shell.connected(andCommand: "xcodebuild -exportArchive -archivePath \(buildPath)/\(configuration)/\(scheme).xcarchive -exportPath \(buildPath)/\(configuration) -exportOptionsPlist \(export)")
        if let toSavePath = toSavePath,!toSavePath.isEmpty {
            shell.connected(andCommand: "mkdir -p \(toSavePath)")
            shell.connected(andCommand: "rm -rf \(toSavePath)/\(scheme).\(fileExtension)")
            shell.connected(andCommand: "cp -R \(buildPath)/\(configuration)/\(scheme).\(fileExtension) \(toSavePath)")
        }
        return ShellOutCommand(string: shell)
    }
}

/// upload commands
public extension ShellOutCommand {
    
    /// IOS archive VALID_ARCHS=\("arm64")
    static func upload(scheme:String, buildPath:String,configuration:String, fileExtension: String, path:String?, username: String, password: String) -> ShellOutCommand {
        let path = path ?? "\(buildPath)/\(configuration)/\(scheme).\(fileExtension)"
        var shell = "".fileExisting(at: path)
        shell.connected(andCommand: "xcrun altool --validate-app -f \(path) -u \(username) -p \(password) --output-format xml")
        shell.connected(andCommand: "xcrun altool --upload-app -f \(path) -u \(username) -p \(password) --output-format xml")
        return ShellOutCommand(string: shell)
    }
    
    /// IOS archive VALID_ARCHS=\("arm64")
    static func upload(scheme:String, buildPath:String, configuration:String, fileExtension: String, path:String?, apiKey: String, apiIssuerID: String) -> ShellOutCommand {
        let path = path ?? "\(buildPath)/\(configuration)/\(scheme).\(fileExtension)"
        var shell = "".fileExisting(at: path)
        shell.connected(andCommand: "xcrun altool --validate-app -f \(path) --apiKey \(apiKey) --apiIssuer \(apiIssuerID) --output-format xml")
        shell.connected(andCommand: "xcrun altool --upload-app --apiKey \(apiKey) --apiIssuer \(apiIssuerID) --output-format xml")
        return ShellOutCommand(string: shell)
    }
    
    /// IOS archive VALID_ARCHS=\("arm64")
    static func upload(scheme:String, buildPath:String,configuration:String, export:String) -> ShellOutCommand {
        var shell = "".fileExisting(at: "\(buildPath)/\(configuration)/\(scheme).xcarchive")
        shell.fileExisted(at: export)
        shell.connected(andCommand: "xcodebuild -exportArchive -archivePath \(buildPath)/\(configuration)/\(scheme).xcarchive -exportOptionsPlist \(export)")
        
        return ShellOutCommand(string: shell)
    }
}

/// archive upload fir  commands
public extension ShellOutCommand {
    static func list(isWorkspace:Bool,projectName: String, projectPath:String) -> ShellOutCommand {
        let shell = "xcodebuild -list \(isWorkspace ? "-workspace" : "-project") \(projectPath)/\(projectName) -json"
        return ShellOutCommand(string: shell)
    }
    
    static func xcodeVersion() -> ShellOutCommand {
        let shell = "xcodebuild -version"
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
                    CC_SHA256(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
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
    
    // 解锁钥匙串
    static func installApiP8(apiKey: String,authKeyPath: String) -> ShellOutCommand {
        var shell = "mkdir -p ~/.private_keys"
        shell.connected(andCommand: "cp -R \(authKeyPath) ~/.private_keys/AuthKey_\(apiKey).p8")
        return ShellOutCommand(string: shell)
    }
    
}
