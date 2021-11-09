/**
 *  ShellOut
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
import Dispatch

// MARK: - API

/**
 *  Run a shell command using Bash
 *
 *  - parameter command: The command to run
 *  - parameter arguments: The arguments to pass to the command
 *  - parameter path: The path to execute the commands at (defaults to current folder)
 *  - parameter process: Which process to use to perform the command (default: A new one)
 *  - parameter outputHandle: Any `FileHandle` that any output (STDOUT) should be redirected to
 *              (at the moment this is only supported on macOS)
 *  - parameter errorHandle: Any `FileHandle` that any error output (STDERR) should be redirected to
 *              (at the moment this is only supported on macOS)
 *
 *  - returns: The output of running the command
 *  - throws: `ShellOutError` in case the command couldn't be performed, or it returned an error
 *
 *  Use this function to "shell out" in a Swift script or command line tool
 *  For example: `shellOut(to: "mkdir", arguments: ["NewFolder"], at: "~/CurrentFolder")`
 */
@discardableResult public func shellOut(
    to command: String,
    arguments: [String] = [],
    at path: String = ".",
    process: Process = .init(),
    outputHandle: FileHandle? = nil,
    errorHandle: FileHandle? = nil
) throws -> String {
    let command = "cd \(path.escapingSpaces) && \(command) \(arguments.joined(separator: " "))"

    return try process.launchBash(
        with: command,
        outputHandle: outputHandle,
        errorHandle: errorHandle
    )
}

/**
 *  Run a series of shell commands using Bash
 *
 *  - parameter commands: The commands to run
 *  - parameter path: The path to execute the commands at (defaults to current folder)
 *  - parameter process: Which process to use to perform the command (default: A new one)
 *  - parameter outputHandle: Any `FileHandle` that any output (STDOUT) should be redirected to
 *              (at the moment this is only supported on macOS)
 *  - parameter errorHandle: Any `FileHandle` that any error output (STDERR) should be redirected to
 *              (at the moment this is only supported on macOS)
 *
 *  - returns: The output of running the command
 *  - throws: `ShellOutError` in case the command couldn't be performed, or it returned an error
 *
 *  Use this function to "shell out" in a Swift script or command line tool
 *  For example: `shellOut(to: ["mkdir NewFolder", "cd NewFolder"], at: "~/CurrentFolder")`
 */
@discardableResult public func shellOut(
    to commands: [String],
    at path: String = ".",
    process: Process = .init(),
    outputHandle: FileHandle? = nil,
    errorHandle: FileHandle? = nil
) throws -> String {
    let command = commands.joined(separator: " && ")

    return try shellOut(
        to: command,
        at: path,
        process: process,
        outputHandle: outputHandle,
        errorHandle: errorHandle
    )
}

/**
 *  Run a pre-defined shell command using Bash
 *
 *  - parameter command: The command to run
 *  - parameter path: The path to execute the commands at (defaults to current folder)
 *  - parameter process: Which process to use to perform the command (default: A new one)
 *  - parameter outputHandle: Any `FileHandle` that any output (STDOUT) should be redirected to
 *  - parameter errorHandle: Any `FileHandle` that any error output (STDERR) should be redirected to
 *
 *  - returns: The output of running the command
 *  - throws: `ShellOutError` in case the command couldn't be performed, or it returned an error
 *
 *  Use this function to "shell out" in a Swift script or command line tool
 *  For example: `shellOut(to: .gitCommit(message: "Commit"), at: "~/CurrentFolder")`
 *
 *  See `ShellOutCommand` for more info.
 */
@discardableResult public func shellOut(
    to command: ShellOutCommand,
    at path: String = ".",
    process: Process = .init(),
    outputHandle: FileHandle? = nil,
    errorHandle: FileHandle? = nil
) throws -> String {
    return try shellOut(
        to: command.string,
        at: path,
        process: process,
        outputHandle: outputHandle,
        errorHandle: errorHandle
    )
}

/// Structure used to pre-define commands for use with ShellOut
public struct ShellOutCommand {
    /// The string that makes up the command that should be run on the command line
    public var string: String

    /// Initialize a value using a string that makes up the underlying command
    public init(string: String) {
        self.string = string
    }
}

/// Git commands
public extension ShellOutCommand {
    /// Initialize a git repository
    static func gitInit() -> ShellOutCommand {
        return ShellOutCommand(string: "git init")
    }

    /// Clone a git repository at a given URL
    static func gitClone(url: URL, to path: String? = nil, branch: String? = nil, allowingPrompt: Bool = true) -> ShellOutCommand {
        return gitClone(url: url.absoluteString ,to: path, branch: branch, allowingPrompt: allowingPrompt)
    }
    
    /// Clone a git repository at a given URLString
    static func gitClone(url: String, to path: String? = nil, branch: String? = nil, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) clone \(url)"
        path.map { command.append(argument: $0) }
        command.append(" -b \(branch ?? "master")")
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }

    /// Create a git commit with a given message (also adds all untracked file to the index)
    static func gitCommit(message: String, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) add . && git commit -a -m"
        command.append(argument: message)
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }

    /// Perform a git push
    static func gitPush(remote: String? = nil, branch: String? = nil, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) push"
        remote.map { command.append(argument: $0) }
        branch.map { command.append(argument: $0) }
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }

    /// Perform a git pull
    static func gitPull(remote: String? = nil, branch: String? = nil, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) pull"
        remote.map { command.append(argument: $0) }
        branch.map { command.append(argument: $0) }
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }
    
    /// Perform a git pull
    static func gitPrune(remote: String? = nil, branch: String? = nil, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) remote prune origin"
        remote.map { command.append(argument: $0) }
        branch.map { command.append(argument: $0) }

        return ShellOutCommand(string: command)
    }
    
    /// Perform a git Rebase
    static func gitRebase(remote: String? = nil, masterBranch: String? = nil, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) rebase -i"
//        remote.map { command.append(argument: $0) }
        masterBranch.map { command.append(argument: $0) }
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }
    
    /// Perform a git tag
    static func gitAddTag(tag: String, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) tag \(tag)"
        command.append(" --quiet && ")
        command.append("\(git(allowingPrompt: allowingPrompt)) push origin \(tag)")
        return ShellOutCommand(string: command)
    }
    
    /// del a git tag
    static func gitDelTag(tag: String, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) tag -d \(tag)"
        command.append(" --quiet && ")
        command.append("\(git(allowingPrompt: allowingPrompt)) push origin :refs/tags/\(tag)")
        return ShellOutCommand(string: command)
    }

    /// Run a git submodule update
    static func gitSubmoduleUpdate(initializeIfNeeded: Bool = true, recursive: Bool = true, allowingPrompt: Bool = true) -> ShellOutCommand {
        var command = "\(git(allowingPrompt: allowingPrompt)) submodule update"

        if initializeIfNeeded {
            command.append(" --init")
        }

        if recursive {
            command.append(" --recursive")
        }

        command.append(" --quiet")
        return ShellOutCommand(string: command)
    }

    /// Checkout a given git branch
    static func gitCheckout(branch: String) -> ShellOutCommand {
        let command = "git checkout".appending(argument: branch)
                                    .appending(" --quiet")

        return ShellOutCommand(string: command)
    }
    
    /// Clone a git repository at a given URLString
    static func gitStatus() -> ShellOutCommand {
         let command = "git diff"
        return ShellOutCommand(string: command)
    }
    
    /// Clone a git repository at a given URLString
       static func gitCodeVerison() -> ShellOutCommand {
            let command = "git rev-parse HEAD"
           return ShellOutCommand(string: command)
       }

    private static func git(allowingPrompt: Bool) -> String {
        return allowingPrompt ? "git" : "env GIT_TERMINAL_PROMPT=0 git"
    }
}

/// File system commands
public extension ShellOutCommand {
    /// Create a folder with a given name
    static func createFolder(path: String) -> ShellOutCommand {
        let command = "mkdir -p".appending(argument: path)
        return ShellOutCommand(string: command)
    }

    /// Create a file with a given name and contents (will overwrite any existing file with the same name)
    static func createFile(named name: String, contents: String) -> ShellOutCommand {
        var command = "echo"
        command.append(argument: contents)
        command.append(" > ")
        command.append(argument: name)

        return ShellOutCommand(string: command)
    }

    /// Move a file from one path to another
    static func moveFile(from originPath: String, to targetPath: String) -> ShellOutCommand {
        let command = "mv".appending(argument: originPath)
                          .appending(argument: targetPath)

        return ShellOutCommand(string: command)
    }
    
    /// Copy a file from one path to another
    static func copyFile(from originPath: String, to targetPath: String) -> ShellOutCommand {
        let command = "cp".appending(argument: originPath)
                          .appending(argument: targetPath)
        
        return ShellOutCommand(string: command)
    }
    
    /// Remove a file
    static func removeFile(from path: String, arguments: [String] = ["-f"]) -> ShellOutCommand {
        let command = "rm".appending(arguments: arguments)
                          .appending(argument: path)
        
        return ShellOutCommand(string: command)
    }

    /// Remove a folderd
    static func removeFolder(from path: String, arguments: [String] = ["-rf"]) -> ShellOutCommand {
        let command = "rm".appending(arguments: arguments)
                          .appending(argument: path)
        
        return ShellOutCommand(string: command)
    }
    
    /// Open a file using its designated application
    static func openFile(at path: String) -> ShellOutCommand {
        let command = "open".appending(argument: path)
        return ShellOutCommand(string: command)
    }

    /// Read a file as a string
    static func readFile(at path: String) -> ShellOutCommand {
        let command = "cat".appending(argument: path)
        return ShellOutCommand(string: command)
    }

    /// Create a symlink at a given path, to a given target
    static func createSymlink(to targetPath: String, at linkPath: String) -> ShellOutCommand {
        let command = "ln -s".appending(argument: targetPath)
                             .appending(argument: linkPath)

        return ShellOutCommand(string: command)
    }

    /// Expand a symlink at a given path, returning its target path
    static func expandSymlink(at path: String) -> ShellOutCommand {
        let command = "readlink".appending(argument: path)
        return ShellOutCommand(string: command)
    }
}

/// Marathon commands
public extension ShellOutCommand {
    /// Run a Marathon Swift script
    static func runMarathonScript(at path: String, arguments: [String] = []) -> ShellOutCommand {
        let command = "marathon run".appending(argument: path)
                                    .appending(arguments: arguments)

        return ShellOutCommand(string: command)
    }

    /// Update all Swift packages managed by Marathon
    static func updateMarathonPackages() -> ShellOutCommand {
        return ShellOutCommand(string: "marathon update")
    }
}

/// Swift Package Manager commands
public extension ShellOutCommand {
    /// Enum defining available package types when using the Swift Package Manager
    enum SwiftPackageType: String {
        case library
        case executable
    }

    /// Enum defining available build configurations when using the Swift Package Manager
    enum SwiftBuildConfiguration: String {
        case debug
        case release
    }

    /// Create a Swift package with a given type (see SwiftPackageType for options)
    static func createSwiftPackage(withType type: SwiftPackageType = .library) -> ShellOutCommand {
        let command = "swift package init --type \(type.rawValue)"
        return ShellOutCommand(string: command)
    }

    /// Update all Swift package dependencies
    static func updateSwiftPackages() -> ShellOutCommand {
        return ShellOutCommand(string: "swift package update")
    }

    /// Generate an Xcode project for a Swift package
    static func generateSwiftPackageXcodeProject() -> ShellOutCommand {
        return ShellOutCommand(string: "swift package generate-xcodeproj")
    }

    /// Build a Swift package using a given configuration (see SwiftBuildConfiguration for options)
    static func buildSwiftPackage(withConfiguration configuration: SwiftBuildConfiguration = .debug) -> ShellOutCommand {
        return ShellOutCommand(string: "swift build -c \(configuration.rawValue)")
    }

    /// Test a Swift package using a given configuration (see SwiftBuildConfiguration for options)
    static func testSwiftPackage(withConfiguration configuration: SwiftBuildConfiguration = .debug) -> ShellOutCommand {
        return ShellOutCommand(string: "swift test -c \(configuration.rawValue)")
    }
}

/// Fastlane
public extension ShellOutCommand {
    /// Run Fastlane using a given lane
    static func runFastlane(usingLane lane: String) -> ShellOutCommand {
        let command = "fastlane".appending(argument: lane)
        return ShellOutCommand(string: command)
    }
}

/// IOS build Framework commands
public extension ShellOutCommand {
    /// IOS build Framework
//    static func buildFrameworkIOS(projectName:String,projectFilePath:String, derivedDataPath: String,toPath: String?) -> ShellOutCommand {
//        var release = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Release -sdk iphoneos ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES"
//        var debug = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Debug -arch x86_64 -sdk iphonesimulator  ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES"
////        var lipoArm64 = ""
//        var mkdirUniversal = ""
//        var cpUniversal = ""
//        var lipo = ""
//        var mkdir = ""
//        var cp = ""
//        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
//        release += " -derivedDataPath \(standarizedPath)"
//        debug += " -derivedDataPath \(standarizedPath)"
//        mkdirUniversal = "mkdir " + standarizedPath + "/Build/Products/\(projectName)-Universal/"
//        cpUniversal = "cp -R \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName).framework \(standarizedPath)/Build/Products/\(projectName)-Universal/"
//        lipo = "lipo -create \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName).framework/\(projectName) \(standarizedPath)/Build/Products/Debug-iphonesimulator/\(projectName).framework/\(projectName) -output \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).framework/\(projectName)"
//        if let toPath = toPath {
//            mkdir = "mkdir -p " + toPath
//            cp = "cp -R \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).framework \(toPath)"
//        }
//
//        return ShellOutCommand(string:release + " && " + debug + " && " + mkdirUniversal + " && " + cpUniversal + " && " + lipo + " && " + mkdir + " && " + cp)
//    }

    static func buildDebugFrameworkIOS(projectName:String,projectFilePath:String, derivedDataPath: String) -> ShellOutCommand {
        var debug = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Debug -arch x86_64 -sdk iphonesimulator  ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        debug += " -derivedDataPath \(standarizedPath)"
        
        return ShellOutCommand(string:debug)
    }
    
    static func buildReleaseFrameworkIOS(projectName:String,projectFilePath:String, derivedDataPath: String) -> ShellOutCommand {
        var release = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Release -sdk iphoneos ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        release += " -derivedDataPath \(standarizedPath)"
        
        return ShellOutCommand(string:release)
    }
    
  
}


public extension ShellOutCommand {
    static func createXCFrameworkIOS(projectName:String, derivedDataPath: String,toPath: String?) -> ShellOutCommand {
        var mkdirUniversal = ""
        var lipo = ""
        var mkdir = ""
        var cp = ""
        
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        
        mkdirUniversal = "mkdir " + standarizedPath + "/Build/Products/\(projectName)-Universal/"
        
        lipo = " && xcodebuild -create-xcframework -framework \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName).framework -framework \(standarizedPath)/Build/Products/Debug-iphonesimulator/\(projectName).framework -output \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).xcframework"
        
        if let toPath = toPath {
            mkdir = " && mkdir -p " + toPath
            cp = " && cp -R \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).xcframework \(toPath)"
        }
        
        return ShellOutCommand(string:mkdirUniversal + lipo + mkdir + cp)
    }
}

public extension ShellOutCommand {
    static func lipoCreateFrameworkIOS(projectName:String, derivedDataPath: String,toPath: String?, needMerge: Bool) -> ShellOutCommand {
        var mkdirUniversal = ""
        var cpUniversal = ""
        var lipo = ""
        var mkdir = ""
        var cp = ""
        
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        
        mkdirUniversal = "mkdir " + standarizedPath + "/Build/Products/\(projectName)-Universal/"
        cpUniversal = " && cp -R \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName).framework \(standarizedPath)/Build/Products/\(projectName)-Universal/"
        
        
        if needMerge {
            lipo = " && lipo -create \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName).framework/\(projectName) \(standarizedPath)/Build/Products/Debug-iphonesimulator/\(projectName).framework/\(projectName) -output \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).framework/\(projectName)"
        }
        
        if let toPath = toPath {
            mkdir = " && mkdir -p " + toPath
            cp = " && cp -R \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).framework \(toPath)"
        }
        
        return ShellOutCommand(string:mkdirUniversal + cpUniversal + lipo + mkdir + cp)
    }
}

public extension ShellOutCommand {
    
//    static func buildStaticIOS(projectName:String,projectFilePath:String, derivedDataPath: String,toStaticPath: String?) -> ShellOutCommand {
//        var release = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Release -sdk iphoneos ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES"
//        var debug = " &&  xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Debug -arch x86_64 -sdk iphonesimulator  ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES"
//        var mkdirUniversal = ""
//        var lipo = ""
//        var mkdir = ""
//        var cpStatic = ""
//        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
//        release += " -derivedDataPath \(standarizedPath)"
//        debug += " -derivedDataPath \(standarizedPath)"
//        mkdirUniversal = " && mkdir " + standarizedPath + "/Build/Products/\(projectName)-Universal/"
//        lipo = " && lipo -create \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName).a \(standarizedPath)/Build/Products/Debug-iphonesimulator/\(projectName).a -output \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).a"
//        if let toStaticPath = toStaticPath {
//            mkdir = " && mkdir -p " + toStaticPath
//            cpStatic = " && cp -R \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).a \(toStaticPath)"
//        }
//
//        return ShellOutCommand(string:release + debug + mkdirUniversal + lipo + mkdir + cpStatic)
//    }
    
    /// IOS build Static.a
    static func buildDebugStaticIOS(projectName:String,projectFilePath:String, derivedDataPath: String) -> ShellOutCommand {
        var debug = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Debug -arch x86_64 -sdk iphonesimulator  ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES"
        
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        debug += " -derivedDataPath \(standarizedPath)"
        return ShellOutCommand(string:debug)
    }
    
    static func buildReleaseStaticIOS(projectName:String,projectFilePath:String, derivedDataPath: String) -> ShellOutCommand {
        var release = "xcodebuild -project \(projectFilePath) -scheme \(projectName) -configuration Release -sdk iphoneos ONLY_ACTIVE_ARCH=NO ODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY= CARTHAGE=YES"
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        release += " -derivedDataPath \(standarizedPath)"
        return ShellOutCommand(string:release)
    }
    
    static func lipoCreateStaticIOS(projectName:String, derivedDataPath: String,toStaticPath: String?, needMerge: Bool) -> ShellOutCommand {
        var mkdirUniversal = ""
        var lipo = ""
        var mkdir = ""
        var cpStatic = ""
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        mkdirUniversal = "mkdir " + standarizedPath + "/Build/Products/\(projectName)-Universal/"
        lipo = " && lipo -create \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName).a \(standarizedPath)/Build/Products/Debug-iphonesimulator/\(projectName).a -output \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).a"
        if let toStaticPath = toStaticPath {
            mkdir = " && mkdir -p " + toStaticPath
            cpStatic = " && cp -R \(standarizedPath)/Build/Products/\(projectName)-Universal/\(projectName).a \(toStaticPath)"
        }
        
        return ShellOutCommand(string:mkdirUniversal + lipo + mkdir + cpStatic)
    }
    
    /// IOS copy Header
    static func copyStaticHeaderIOS(projectName:String,projectFilePath:String, derivedDataPath: String,toHeaderPath: String?) -> ShellOutCommand {
        var mkdir = ""
        var cpHeader = ""
        let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
        if let toHeaderPath = toHeaderPath {
            mkdir = "mkdir -p " + toHeaderPath
            cpHeader = "cp -R \(standarizedPath)/Build/Products/Release-iphoneos/include/\(projectName) \(toHeaderPath)"
        }
        return ShellOutCommand(string: mkdir + " && " + cpHeader)
    }
}

/// IOS build Bundle commands
public extension ShellOutCommand {
    /// IOS build Bundle
    static func buildBundleIOS(projectName:String,projectFilePath:String, derivedDataPath: String?,toBundlePath: String?) -> ShellOutCommand {
        var bundle = "xcodebuild -project \(projectFilePath) -scheme \(projectName)Bundle -configuration Release -sdk iphoneos"
        var mkdir = ""
        var cpBundle = ""
        if let derivedDataPath = derivedDataPath {
            let standarizedPath = URL(fileURLWithPath: (derivedDataPath as NSString).expandingTildeInPath).standardizedFileURL.path
            if !derivedDataPath.isEmpty && !standarizedPath.isEmpty {
                bundle +=  " -derivedDataPath \(standarizedPath)"
                if let toBundlePath = toBundlePath {
                    mkdir = "mkdir -p " + toBundlePath
                    cpBundle = "cp -R \(standarizedPath)/Build/Products/Release-iphoneos/\(projectName)Bundle.bundle \(toBundlePath)"
                }
            }
        }
        return ShellOutCommand(string: bundle + " && " + mkdir + " && " + cpBundle)
    }
}

/// IOS archive upload fir  commands
public extension ShellOutCommand {
    /// IOS archive
    static func archiveIOS(scheme:String,projectPath:String,config:String, exportName:String) -> ShellOutCommand {
        let clean = "xcodebuild clean -workspace \(scheme).xcworkspace -scheme \(scheme) -configuration \(config)"
        let archive = "xcodebuild archive -workspace \(scheme).xcworkspace -scheme \(scheme) -configuration \(config) -destination generic/platform=iOS -archivePath \(projectPath)/Build/\(config)/\(scheme).xcarchive"
        let export = "xcodebuild -exportArchive -archivePath \(projectPath)/Build/\(config)/\(scheme).xcarchive -exportPath \(projectPath)/Build/\(config) -exportOptionsPlist \(projectPath)/\(exportName)"
        return ShellOutCommand(string:clean + " && " + archive + " && " + export)
    }
    
    /// IOS upload
    static func uploadIOS(scheme:String,projectPath:String,config:String,desc:String?) -> ShellOutCommand {
        let upload = "fir publish \(projectPath)/Build/\(config)/\(scheme).ipa \(String(describing: desc))"
        return ShellOutCommand(string:upload)
    }

}

/// IOS build Bundle commands
public extension ShellOutCommand {
    /// IOS framework cache
    static func readVerisonIOS(plistPath:String,plistName:String) -> ShellOutCommand {
        let read = "/usr/libexec/PlistBuddy -c 'Print BuildCodeVersion' \(plistPath)/\(plistName).plist"
        return ShellOutCommand(string: read)
    }
    
    /// IOS framework cache
    static func writeVerisonIOS(plistPath:String,plistName:String,verison:String) -> ShellOutCommand {
        let write = "/usr/libexec/PlistBuddy -c 'Add BuildCodeVersion string \(verison)' \(plistPath)/\(plistName).plist"
        return ShellOutCommand(string: write)
    }
}

/// CocoaPods commands
public extension ShellOutCommand {
    /// Update all CocoaPods dependencies
    static func updateCocoaPods() -> ShellOutCommand {
        return ShellOutCommand(string: "pod update")
    }

    /// Install all CocoaPods dependencies
    static func installCocoaPods() -> ShellOutCommand {
        return ShellOutCommand(string: "pod install")
    }
}

/// Error type thrown by the `shellOut()` function, in case the given command failed
public struct ShellOutError: Swift.Error {
    /// The termination status of the command that was run
    public let terminationStatus: Int32
    /// The error message as a UTF8 string, as returned through `STDERR`
    public var message: String { return errorData.shellOutput() }
    /// The raw error buffer data, as returned through `STDERR`
    public let errorData: Data
    /// The raw output buffer data, as retuned through `STDOUT`
    public let outputData: Data
    /// The output of the command as a UTF8 string, as returned through `STDOUT`
    public var output: String { return outputData.shellOutput() }
}

extension ShellOutError: CustomStringConvertible {
    public var description: String {
        return """
               ShellOut encountered an error
               Status code: \(terminationStatus)
               Message: "\(message)"
               Output: "\(output)"
               """
    }
}

extension ShellOutError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}

// MARK: - Private

private extension Process {
    @discardableResult func launchBash(with command: String, outputHandle: FileHandle? = nil, errorHandle: FileHandle? = nil) throws -> String {
        launchPath = "/bin/bash"
        arguments = ["-c", command]

        // Because FileHandle's readabilityHandler might be called from a
        // different queue from the calling queue, avoid a data race by
        // protecting reads and writes to outputData and errorData on
        // a single dispatch queue.
        let outputQueue = DispatchQueue(label: "bash-output-queue")

        var outputData = Data()
        var errorData = Data()

        let outputPipe = Pipe()
        standardOutput = outputPipe

        let errorPipe = Pipe()
        standardError = errorPipe

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                outputData.append(data)
                outputHandle?.write(data)
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                errorData.append(data)
                errorHandle?.write(data)
            }
        }
        #endif

        launch()

        #if os(Linux)
        outputQueue.sync {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        }
        #endif

        waitUntilExit()

        if let handle = outputHandle, !handle.isStandard {
            handle.closeFile()
        }

        if let handle = errorHandle, !handle.isStandard {
            handle.closeFile()
        }

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        #endif

        // Block until all writes have occurred to outputData and errorData,
        // and then read the data back out.
        return try outputQueue.sync {
            if terminationStatus != 0 {
                throw ShellOutError(
                    terminationStatus: terminationStatus,
                    errorData: errorData,
                    outputData: outputData
                )
            }

            return outputData.shellOutput()
        }
    }
}

private extension FileHandle {
    var isStandard: Bool {
        return self === FileHandle.standardOutput ||
            self === FileHandle.standardError ||
            self === FileHandle.standardInput
    }
}

private extension Data {
    func shellOutput() -> String {
        guard let output = String(data: self, encoding: .utf8) else {
            return ""
        }

        guard !output.hasSuffix("\n") else {
            let endIndex = output.index(before: output.endIndex)
            return String(output[..<endIndex])
        }

        return output

    }
}

private extension String {
    var escapingSpaces: String {
        return replacingOccurrences(of: " ", with: "\\ ")
    }

    func appending(argument: String) -> String {
        return "\(self) \"\(argument)\""
    }

    func appending(arguments: [String]) -> String {
        return appending(argument: arguments.joined(separator: "\" \""))
    }

    mutating func append(argument: String) {
        self = appending(argument: argument)
    }

    mutating func append(arguments: [String]) {
        self = appending(arguments: arguments)
    }
}

extension String {

    /// Returns self without any potential trailing Cartfile comment. A Cartfile
    /// comment starts with the first `commentIndicator` that is not embedded in any quote
    var strippingTrailingCartfileComment: String {

        // Since the Cartfile syntax doesn't support nested quotes, such as `"version-\"alpha\""`,
        // simply consider any odd-number occurence of a quote as a quote-start, and any
        // even-numbered occurrence of a quote as quote-end.
        // The comment indicator (e.g. `#`) is the start of a comment if it's not nested in quotes.
        // The following code works also for comment indicators that are are more than one character
        // long (e.g. double slashes).

        let quote = "\""

        // Splitting the string by quote will make odd-numbered chunks outside of quotes, and
        // even-numbered chunks inside of quotes.
        // `omittingEmptySubsequences` is needed to maintain this property even in case of empty quotes.
        let quoteDelimitedChunks = self.split(
            separator: quote.first!,
            maxSplits: Int.max,
            omittingEmptySubsequences: false
        )

        for (offset, chunk) in quoteDelimitedChunks.enumerated() {
            let isInQuote = offset % 2 == 1 // even chunks are not in quotes, see comment above
            if isInQuote {
                continue // don't consider comment indicators inside quotes
            }
            if let range = chunk.range(of: "#") {
                // there is a comment, return everything before its position
                let advancedOffset = (..<offset).relative(to: quoteDelimitedChunks)
                let previousChunks = quoteDelimitedChunks[advancedOffset]
                let chunkBeforeComment = chunk[..<range.lowerBound]
                return (previousChunks + [chunkBeforeComment])
                    .joined(separator: quote) // readd the quotes that were removed in the initial split
            }
        }
        return self
    }
}

