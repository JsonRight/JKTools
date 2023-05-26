//
//  XcodeCommands.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

extension ShellOutCommand {
    
    static func clean(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, configuration: String, sdk: String, includedSimulators: Bool?) -> ShellOutCommand {
        let validArchs = Platform(sdk).archs(includedSimulators == true ? [.RealMachine,.Simulator]: [.RealMachine])
        let shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) -arch \(validArchs.joined(separator: " -arch ")) -parallelizeTargets -quiet -UseModernBuildSystem=YES"
        return ShellOutCommand(string:shell)
    }
    
    static func build(scheme:String, isWorkspace:Bool,projectName: String, projectPath:String, configuration: String, sdk: String, includedSimulators: Bool?) -> ShellOutCommand {
        
        let validArchs = Platform(sdk).archs(includedSimulators == true ? [.RealMachine,.Simulator]: [.RealMachine])
        let shell = "xcodebuild \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) -arch \(validArchs.joined(separator: " -arch ")) -UseModernBuildSystem=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -parallelizeTargets -jobs \(ProcessInfo.processInfo.activeProcessorCount) -verbose clean build"
        return ShellOutCommand(string:shell)
    }
    
    static func archive(scheme:String, isWorkspace:Bool,projectName: String, buildPath:String,configuration:String, sdk: String) -> ShellOutCommand {
        
        var shell = "xcodebuild clean \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme)"
        shell.connected(andCommand: "xcodebuild archive \(isWorkspace ? "-workspace" : "-project") \(projectName) -scheme \(scheme) -configuration \(configuration) -parallelizeTargets -jobs \(ProcessInfo.processInfo.activeProcessorCount)")
        shell.connected(spaceCommand: "-archivePath \(buildPath)/\(configuration)/\(scheme).xcarchive")
        return ShellOutCommand(string: shell)
    }
    
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
    
    static func upload(scheme:String, buildPath:String,configuration:String, fileExtension: String, path:String?, username: String, password: String) -> ShellOutCommand {
        let path = path ?? "\(buildPath)/\(configuration)/\(scheme).\(fileExtension)"
        var shell = "".fileExisting(at: path)
        shell.connected(andCommand: "xcrun altool --validate-app -f \(path) -u \(username) -p \(password) --output-format xml")
        shell.connected(andCommand: "xcrun altool --upload-app -f \(path) -u \(username) -p \(password) --output-format xml")
        return ShellOutCommand(string: shell)
    }
    
    static func upload(scheme:String, buildPath:String, configuration:String, fileExtension: String, path:String?, apiKey: String, apiIssuerID: String) -> ShellOutCommand {
        let path = path ?? "\(buildPath)/\(configuration)/\(scheme).\(fileExtension)"
        var shell = "".fileExisting(at: path)
        shell.connected(andCommand: "xcrun altool --validate-app -f \(path) --apiKey \(apiKey) --apiIssuer \(apiIssuerID) --output-format xml")
        shell.connected(andCommand: "xcrun altool --upload-app --apiKey \(apiKey) --apiIssuer \(apiIssuerID) --output-format xml")
        return ShellOutCommand(string: shell)
    }
    
    static func upload(scheme:String, buildPath:String,configuration:String, export:String) -> ShellOutCommand {
        var shell = "".fileExisting(at: "\(buildPath)/\(configuration)/\(scheme).xcarchive")
        shell.fileExisted(at: export)
        shell.connected(andCommand: "xcodebuild -exportArchive -archivePath \(buildPath)/\(configuration)/\(scheme).xcarchive -exportOptionsPlist \(export)")
        
        return ShellOutCommand(string: shell)
    }
    
    static func list() -> ShellOutCommand {
        let shell = "xcodebuild -list -json"
        return ShellOutCommand(string: shell)
    }
    
    static func xcodeVersion() -> ShellOutCommand {
        let shell = "xcodebuild -version"
        return ShellOutCommand(string: shell)
    }
    
    static func buildSettings(isWorkspace:Bool,projectName: String, projectPath:String, configuration: String, sdk: String) -> ShellOutCommand {
        let shell = "xcodebuild -showBuildSettings \(isWorkspace ? "-workspace" : "-project") \(projectPath)/\(projectName) VALID_ARCHS='\(Platform(sdk).arch(.RealMachine))' -destination 'generic/platform=\(Platform(sdk).platform(.RealMachine))' -json"
        return ShellOutCommand(string: shell)
    }
}

/// build Framework commands
extension ShellOutCommand {
    /// IOS build Framework Debug x86_64 iphonesimulator
    /// IOS build Framework Release arm64 iphoneos
    static func frameworkMerge(source path:String, otherSourcePath:[String] = [String]()) -> ShellOutCommand {
        let paths = [path] + otherSourcePath
        let shell = "lipo -create ".connecting(spaceCommand: paths.joined(separator: " ")).connecting(spaceCommand: " -output \(path)")
        return ShellOutCommand(string:shell)
    }
    
    static func frameworkWithCache(target:String,projectPath:String,buildPath: String, verison: String, toPath: String) -> ShellOutCommand {
        var shell = "".fileExisting(at: "\(buildPath)/Universal/\(verison)/\(target).framework/\(target)")
        shell.connected(andCommand: "mkdir -p \(toPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(target).framework \(toPath.convertRelativePath(absolutPath: projectPath))")
        return ShellOutCommand(string:shell)
    }
}


/// build XCFramework commands
extension ShellOutCommand {
    /// IOS build Framework Debug x86_64 iphonesimulator
    /// IOS build Framework Release arm64 iphoneos
    static func xcframeworkMerge(to path:String, otherSourcePath:[String] = [String]()) -> ShellOutCommand {
        // 可能需要使用--framework
        let shell = "xcodebuild -create-xcframework -framework ".connecting(spaceCommand: otherSourcePath.joined(separator: " -framework ")).connecting(spaceCommand: " -output \(path)")
        return ShellOutCommand(string:shell)
    }
    
    static func xcframeworkWithCache(target:String,projectPath:String,buildPath: String, verison: String, toPath: String) -> ShellOutCommand {
        var shell = "".folderExisting(at: "\(buildPath)/Universal/\(verison)/\(target).xcframework")
        shell.connected(andCommand: "mkdir -p \(toPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(target).xcframework \(toPath.convertRelativePath(absolutPath: projectPath))")
        return ShellOutCommand(string:shell)
    }
}

/// build .a commands
extension ShellOutCommand {
    
    static func staticMerge(source path:String, otherSourcePath:[String] = [String]()) -> ShellOutCommand {
        let paths = [path] + otherSourcePath
        let shell = "lipo -create ".connecting(spaceCommand: paths.joined(separator: " ")).connecting(spaceCommand: " -output \(path)")
        return ShellOutCommand(string:shell)
    }
    
    static func staticWithCache(target:String,projectPath:String,buildPath: String, verison: String, toStaticPath: String, toHeaderPath: String) -> ShellOutCommand {
        var shell = "".fileExisting(at: "\(buildPath)/Universal/\(verison)/lib\(target).a")
        
        shell.connected(andCommand: "mkdir -p \(toStaticPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/lib\(target).a \(toStaticPath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(ifCommand: "mkdir -p \(toHeaderPath.convertRelativePath(absolutPath: projectPath))", at: "\(buildPath)/Universal/\(verison)/\(target)")
        shell.connected(ifCommand: "cp -R \(buildPath)/Universal/\(verison)/\(target) \(toHeaderPath.convertRelativePath(absolutPath: projectPath))", at: "\(buildPath)/Universal/\(verison)/\(target)")
        return ShellOutCommand(string:shell)
    }
}

/// build Bundle commands
extension ShellOutCommand {
    
    static func bundleWithCache(bundleName:String,projectPath:String,buildPath: String, verison: String, toBundlePath: String) -> ShellOutCommand {
        var shell = "".folderExisting(at: "\(buildPath)/Universal/\(verison)/\(bundleName).bundle")
        shell.connected(andCommand: "mkdir -p \(toBundlePath.convertRelativePath(absolutPath: projectPath))")
        shell.connected(andCommand: "cp -R \(buildPath)/Universal/\(verison)/\(bundleName).bundle \(toBundlePath.convertRelativePath(absolutPath: projectPath))")
        return ShellOutCommand(string:shell)
    }
}

/// 通过Universal目录下文件夹名称获取verison
extension ShellOutCommand {
    /// IOS framework cache
    static func readVerison(path:String) -> ShellOutCommand {
        let shell = "ls '\(path)'"
        return ShellOutCommand(string: shell)
    }
}

/// 证书管理
extension ShellOutCommand {
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

