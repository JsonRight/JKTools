/**
 *  ShellOut
 *  Copyright (c) John Sundell 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
//import Dispatch
import CommonCrypto

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
@discardableResult func shellOut(
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
@discardableResult func shellOut(
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
@discardableResult func shellOut(
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
struct ShellOutCommand {
    /// The string that makes up the command that should be run on the command line
    var string: String

    /// Initialize a value using a string that makes up the underlying command
    init(string: String) {
        self.string = string
    }
}

/// Error type thrown by the `shellOut()` function, in case the given command failed
struct ShellOutError: Swift.Error {
    /// The termination status of the command that was run
    let terminationStatus: Int32
    /// The error message as a UTF8 string, as returned through `STDERR`
    var message: String { return errorData.shellOutput() }
    /// The raw error buffer data, as returned through `STDERR`
    let errorData: Data
    /// The raw output buffer data, as retuned through `STDOUT`
    let outputData: Data
    /// The output of the command as a UTF8 string, as returned through `STDOUT`
    var output: String { return outputData.shellOutput() }
}

extension ShellOutError: CustomStringConvertible {
    var description: String {
        return """
               ShellOut encountered an error
               Status code: \(terminationStatus)
               Message: "\(message)"
               Output: "\(output)"
               """
    }
}

extension ShellOutError: LocalizedError {
    var errorDescription: String? {
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

extension String {
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
    
    static func safe(_ string: String?,safeString: String = "null") -> String{
        guard let string = string,string != "" else {
            return safeString
        }
        return string
    }
    
    func appendingBySeparator(_ argument: String,separator:String = "-") -> String {
        return "\(self)\(separator)\(argument)"
    }
    /// 匹配到的完整内容
    func regular(_ pattern: String) -> String? {
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: self, options: [], range: range),
              let ra = Range(match.range, in: self)
        else { return nil }
        return String(self[ra])
    }
    
    /// 匹配到的第一个.*内容
    func regular1(_ pattern: String) -> String? {
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: self, options: [], range: range),
              let ra = Range(match.range(at: 1), in: self)
        else { return nil }
        return String(self[ra])
    }
}

extension String {
    
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


extension String {
    func convertRelativePath(absolutPath: String = FileManager.default.currentDirectoryPath) -> String {
        
        if self.hasPrefix("/") {
            return self
        }
        
        if self.hasPrefix("~") {
            return (self as NSString).expandingTildeInPath
        }
        
        var url = URL(fileURLWithPath: absolutPath)
        
        var path = self
        
        while path.hasPrefix("./") {
            let index = path.index(path.startIndex, offsetBy: 2)
            path = String(path[index...])
        }
        
        while path.hasPrefix("../") {
            let index = path.index(path.startIndex, offsetBy: 3)
            path = String(path[index...])
            url.deleteLastPathComponent()
        }
        
        return url.appendingPathComponent(path).path
        
    }
}

extension String {
    var MD5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using:.utf8)!
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


extension FileManager {
    
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
    
    func isDirectory(path: String) -> Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path),attributes[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeDirectory else {
            return false
        }
        return true
    }
}
