//
//  FileCommands.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

/// File system commands
extension ShellOutCommand {
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
    
    /// 读取Plist文件的某个Key
    static func readPlist(plistPath:String,plistName:String,key:String) -> ShellOutCommand {
        let read = "/usr/libexec/PlistBuddy -c 'Print \(key)' \(plistPath)/\(plistName).plist"
        return ShellOutCommand(string: read)
    }
    
    /// 写入Plist某个新字段
    static func addPlist(plistPath:String,plistName:String,key:String,value: String, valueType: String) -> ShellOutCommand {
        let add = "/usr/libexec/PlistBuddy -c 'Add \(key) \(valueType) \(value)' \(plistPath)/\(plistName).plist"
        return ShellOutCommand(string: add)
    }
}
