//
//  Constants.swift
//  JKTools
//
//  Created by 姜奎 on 2021/9/26.
//

import Foundation
import Cocoa

public struct Constants {
    
    static func bundle() -> String {
        return Bundle.main.bundleIdentifier!
    }
    
    static func isFinderExtension() -> Bool{
        return bundle() == Id.FinderExtension.rawValue
    }
    
    static func applicationScriptsPath() -> URL? {
        guard let path = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask).first else {
            return nil
        }
        return path.deletingLastPathComponent()
    }
    
    enum Id: String {
        case LauncherApp = "com.jk.JKTools"
        case FinderExtension = "com.jk.JKTools.FinderSyncExtension"
        
        static func id(string: String) -> Id {
            if string == LauncherApp.rawValue {
                return Id.LauncherApp
            }
            return Id.FinderExtension
        }
        
        var JKToolsScriptsPath: URL? {
            guard let path = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
                return nil
            }
            return path
        }

        var JKToolsFnderExtensionScriptsPath: URL? {
            guard var path = JKToolsScriptsPath else {
                return nil
            }
            
            path.deleteLastPathComponent()
            path = path.appendingPathComponent(Id.FinderExtension.rawValue)
            if !FileManager.default.fileExists(atPath: path.path) {
                do {
                    try FileManager.default.createDirectory(atPath: path.path,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                } catch {
                    print(error)
                }
                
            }
            return path
        }
        func appScriptsPath() -> URL? {
            switch self {
                case .LauncherApp:
                    return JKToolsScriptsPath
                case .FinderExtension:
                    return JKToolsFnderExtensionScriptsPath
            }
        }
        
        
        func fileScriptPath(fileName: String) -> URL? {
            return self.appScriptsPath()?
            .appendingPathComponent(fileName)
            .appendingPathExtension("scpt")
        }
        func hasFileScriptPath() -> Bool {
            guard let path = self.fileScriptPath(fileName: "JKToolScript") else {
                return false
            }
            return FileManager.default.fileExists(atPath: path.path)
        }
    }
    
    static func resetScpt(id: Id) {
        let panel = NSOpenPanel()

        panel.directoryURL = self.applicationScriptsPath()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.prompt = "Select Script Folder"
        panel.message = "Please select the User > Library > Application Scripts"

        panel.begin { result in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                  self.applicationScriptsPath()?.path == panel.url?.path else {
                      Alert.alert(message: "Application Scripts folder was not selected")
                return
            }
            let result = copyAppleScript(url: id.fileScriptPath(fileName: "JKToolScript"))
            if result {
                Alert.alert(message: "Done")
            } else {
                Alert.alert(message: "Fail")
            }
        }
    }
    
    static func copyAppleScript(url:URL?) -> Bool {
      
        guard let scriptUrl = Bundle.main.url(forResource: "JKToolScript", withExtension: "scpt") else {
            return false
        }
        guard let destinationPath = url else {
          return false
        }
        
        do {
          try FileManager.default.removeItem(at: destinationPath)
        } catch {
          
        }

        do {
          try FileManager.default.copyItem(at: scriptUrl, to: destinationPath)
        } catch {
          return false
        }
        
        return true
    }
    
    static func hasShellScptPath(name: String) -> Bool {
        return FileManager.default.fileExists(atPath: "/usr/local/bin/\(name)")
    }
    
    static func ShellScptPath() -> URL {
        return URL(fileURLWithPath: "/usr/local/bin")
    }
    
    static func resetShellScpt(name: String) {
        let panel = NSOpenPanel()

        panel.directoryURL = self.ShellScptPath()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.prompt = "Select Script Folder"
        panel.message = "Please select the usr > local > bin folder"

        panel.begin { result in
            guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                  self.ShellScptPath().path == panel.url?.path else {
                      Alert.alert(message: "Shell folder was not selected")
                return
            }
            let result = copyShellScript(name: name)
            if result {
                Alert.alert(message: "Done")
            } else {
                Alert.alert(message: "Fail")
            }
        }
    }
    static func copyShellScript(name: String) -> Bool {
      
        guard let path = Bundle.main.path(forResource: name, ofType: "") else {
            return false
        }
        let manager = FileManager.default
        do {
            try manager.removeItem(at: URL(fileURLWithPath: "/usr/local/bin/\(name)"))
        } catch {
            return false
        }
        
        do {
            
            /// 绝对路径注意： 不能带file://，否则会调用失败；
            /// 设置文件权限： [FileAttributeKey.posixPermissions: 0o777]
    //            manager.createFile(atPath: "/usr/local/bin/JKTool", contents: tool, attributes: [FileAttributeKey.posixPermissions: 0o777])
            /// 构建快捷方式，权限将和原文件权限一致
            
            try manager.createSymbolicLink(atPath: "/usr/local/bin/JKTool", withDestinationPath: path)
        } catch {
            return false
        }
        return true
    }
}

