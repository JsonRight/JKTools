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
    static func gitClone(url: URL, to path: String? = nil, branch: String? = nil) -> ShellOutCommand {
        return gitClone(url: url.absoluteString ,to: path, branch: branch)
    }
    
    /// Clone a git repository at a given URLString
    static func gitClone(url: String, to path: String? = nil, branch: String? = nil) -> ShellOutCommand {
        var command = "git clone \(url)"
        path.map { command.append(argument: $0) }
        command.append(" -b \(branch ?? "master")")

        return ShellOutCommand(string: command)
    }

    /// Create a git commit with a given message (also adds all untracked file to the index)
    static func gitCommit(message: String) -> ShellOutCommand {
        var command = "git add -A && git commit -a -m"
        command.append(argument: message)

        return ShellOutCommand(string: command)
    }

    /// Perform a git push
    static func gitPush(branch: String? = nil) -> ShellOutCommand {
        var command = "git push --set-upstream origin"
        branch.map { command.append(argument: $0) }

        return ShellOutCommand(string: command)
    }

    /// Perform a git pull
    static func gitPull() -> ShellOutCommand {
        let command = "git pull origin"

        return ShellOutCommand(string: command)
    }
    
    /// Perform a git pull
    static func gitPrune() -> ShellOutCommand {
        let command = "git remote prune origin"
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git Rebase
    static func gitRebase(branch: String? = nil) -> ShellOutCommand {
        var command = "git rebase -i"
        branch.map { command.append(argument: $0) }

        return ShellOutCommand(string: command)
    }
    
    /// Perform a git merge
    static func gitMerge(branch: String, squash: Bool?, commit: Bool?) -> ShellOutCommand {
        var command = "git merge \(branch)"
        
        if squash == true  {
            command.append(" --squash")
        } else if commit == false {
            command.append(" --no-commit --no-ff")
        }
        
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git get current branch name
    static func gitCurrentBranch() -> ShellOutCommand {
        let command = "git branch --show-current"
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git create branch
    static func gitCreateBranch(branch: String) -> ShellOutCommand {
        let command = "git checkout -b \(branch)"
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git delete branch
    static func gitDelLocalBranch(branch: String? = nil) -> ShellOutCommand {
        var command = "git branch -d"
        branch.map { command.append(argument: $0) }
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git delete branch
    static func gitDelOriginBranch(branch: String? = nil) -> ShellOutCommand {
        var command = "git push origin -d"
        branch.map { command.append(argument: $0) }
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git tag
    static func gitAddTag(tag: String) -> ShellOutCommand {
        var command = "git tag \(tag)"
        command.append(" && ")
        command.append("git push origin \(tag)")
        return ShellOutCommand(string: command)
    }
    
    /// del a git tag
    static func gitDelTag(tag: String) -> ShellOutCommand {
        var command = "git tag -d \(tag)"
        command.append(" && ")
        command.append("git push origin :refs/tags/\(tag)")
        return ShellOutCommand(string: command)
    }
    
    /// Run a git submodule update
    static func gitSubmoduleStatus() -> ShellOutCommand {
        let command = "git submodule status"
        return ShellOutCommand(string: command)
    }

    /// Run a git submodule update
    static func gitSubmoduleUpdate(remote: Bool, path: String) -> ShellOutCommand {
        var command = "git submodule update"
        if remote {
            command.append(" --remote")
        }
        command.append(argument: path)
        return ShellOutCommand(string: command)
    }
    
    /// Run a git submodule add
    static func gitSubmoduleAdd(name: String, url: String, path: String, branch: String? = nil) -> ShellOutCommand {
        var command = "git submodule add --name \(name) \(url) \(path) --force"
        command.append(" -b \(branch ?? "master")")
        return ShellOutCommand(string: command)
    }
    
    /// Run a git submodule add
    static func gitSubmoduleRemove(path: String) -> ShellOutCommand {
        let command = "git submodule deinit -f \(path) | rm -rf .git/modules/\(path) | git rm -f \(path)"
        return ShellOutCommand(string: command)
    }

    /// Checkout a given git branch
    static func gitCheckout(branch: String, force: Bool = false) -> ShellOutCommand {
        var command = "git checkout"
        command.append(argument: branch)
        if force {
            command.append(" --force")
        }

        return ShellOutCommand(string: command)
    }
    
    
    static func gitStatus() -> ShellOutCommand {
        let command = "git status"
       return ShellOutCommand(string: command)
    }
    static func gitCurrentCommitId() -> ShellOutCommand {
        let command = "git rev-parse HEAD"
       return ShellOutCommand(string: command)
    }
    
    static func gitShortCurrentCommitId() -> ShellOutCommand {
        let command = "git rev-parse --short HEAD"
       return ShellOutCommand(string: command)
    }
    
    static func gitDiffHEAD() -> ShellOutCommand {
        let command = "git diff HEAD"
       return ShellOutCommand(string: command)
    }
    
    static func gitCodeReset() -> ShellOutCommand {
        let command = "git reset --hard HEAD"
       return ShellOutCommand(string: command)
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
    
    /// Copy a folderd from one path to another
    static func copyFolder(from originPath: String, to targetPath: String) -> ShellOutCommand {
        let command = "cp -R".appending(argument: originPath)
                          .appending(argument: targetPath)
        
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

///
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
    
    static func safeString(string: String?,safeString: String = "null") -> String{
        guard let string = string,string != "" else {
            return safeString
        }
        return string
    }
    
    func appendingBySeparator(_ argument: String,separator:String = "-") -> String {
        return "\(self)\(separator)\(argument)"
    }

}

public extension String {
    
    func connecting(andCommand: String?) -> String {
        if let andCommand = andCommand {
            return "\(self) && \(andCommand)"
        }
        return self
    }
    
    mutating func connected(andCommand: String?) {
        self = connecting(andCommand: andCommand)
    }
    
    func connecting(spaceCommand: String?) -> String {
        if let spaceCommand = spaceCommand {
            return "\(self) \(spaceCommand)"
        }
        return self
    }
    
    mutating func connected(spaceCommand: String?) {
        self = connecting(spaceCommand: spaceCommand)
    }
    
    func connecting(orCommand: String?) -> String {
        if let orCommand = orCommand {
            return "\(self) || \(orCommand)"
        }
        return self
    }
    
    mutating func connected(orCommand: String?) {
        self = connecting(orCommand: orCommand)
    }
    
    func connecting(ifCommand: String? ,at path:String) -> String {
        if let ifCommand = ifCommand {
            return  """
                    \(self)
                      if [ -d \(path) ]
                    then
                             \(ifCommand)
                        else
                          echo "【\(path)】不存在，无需 cp"
                        fi
                    """
        }
        return self
    }
    
    mutating func connected(ifCommand: String?, at path:String) {
        self = connecting(ifCommand: ifCommand ,at: path)
    }
    
    func connecting(ifCommand: String? ,file:String) -> String {
        if let ifCommand = ifCommand {
            return  """
                    \(self)
                    if [ -f \(file) ]
                    then
                    \(ifCommand)
                    else
                    echo "【\(file)】不存在，无需 cp"
                    fi
                    """
        }
        return self
    }
    
    mutating func connected(ifCommand: String?, file:String) {
        self = connecting(ifCommand: ifCommand ,file: file)
    }
    
    func fileExisting(at path:String) -> String {
        return  """
                \(self)
                if [ ! -f \(path) ]
                then
                echo "【\(path)】不存在！"
                exit 1
                fi
                """
    }
    
    mutating func fileExisted(at path:String) {
        self = fileExisting(at: path)
    }
    
    func folderExisting(at path:String) -> String {
        return  """
                \(self)
                if [ ! -d \(path) ]
                then
                echo "【\(path)】不存在！"
                exit 1
                fi
                """
    }
    
    mutating func folderExisted(at path:String) {
        self = folderExisting(at: path)
    }
   
}


public extension String {
    func convertRelativePath(absolutPath: String = FileManager.default.currentDirectoryPath) -> String {
        
        if self.hasPrefix("/") {
            return self
        }
        
        guard var path = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let urlStr = absolutPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), var url = URL(string: urlStr) else {
            return self
        }
        
        while path.hasPrefix("../") {
            let index = path.index(path.startIndex, offsetBy: 3)
            path = String(path[index...])
            url.deleteLastPathComponent()
        }
        
        while path.hasPrefix("./") {
            let index = path.index(path.startIndex, offsetBy: 2)
            path = String(path[index...])
            url.deleteLastPathComponent()
        }
        
        return url.appendingPathComponent(path).absoluteString.removingPercentEncoding ?? ""
        
    }
}


public extension FileManager {
    
    struct FileModel {
        var name:String
        var path:String
        var isDirectory: Bool
        lazy var suffix: String = {
            guard let index = name.lastIndex(of: ".") else {
                return ""
            }
            return String(name[index...])
        }()
    }
    
    func getFileList(directoryPath: String = FileManager.default.currentDirectoryPath) -> [FileModel]? {
        guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: directoryPath) else {
            return nil
        }
        
        return fileList.compactMap { file in
            let path = file.convertRelativePath(absolutPath: directoryPath)
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                
                return FileModel(name: file, path: path, isDirectory: attributes[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeDirectory)
            } catch _ {
                return nil
            }
        }
    }
}
