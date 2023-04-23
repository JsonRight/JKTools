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
        
        try? FileManager.default.removeItem(at: destinationPath)

        do {
          try FileManager.default.copyItem(at: scriptUrl, to: destinationPath)
        } catch {
          return false
        }
        
        return true
    }

}

public extension Constants {
    
    static func panelDirectoryKey() -> String {
        return "panelDirectory"
    }
    
    static func panelDirectoryBookmarkDataKey() -> String {
        return "panelDirectoryBookmarkData"
    }
    
    static func hasShellScptPath(name: String) -> Bool {
        return FileManager.default.fileExists(atPath: "/usr/local/bin/\(name)")
    }
    
    static func ShellScptPath() -> URL {
        return URL(fileURLWithPath: "/usr/local/bin")
    }
    
    static func resetShellScptByBookmarkData(name: String) -> Bool{
        guard let bookmarkData = UserDefaults.standard.data(forKey:panelDirectoryBookmarkDataKey() ) else {
            return false
        }
        var isStale = false
        guard let binDirectory = try? URL(resolvingBookmarkData: bookmarkData, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) else {
            return false
        }
        
        _ = binDirectory.startAccessingSecurityScopedResource()
        copyShellScript(name: name, url: binDirectory)
        binDirectory.stopAccessingSecurityScopedResource()
        
        return true
    }
    
    static func resetShellScptByPanel(name: String){
        DispatchQueue.main.async{
            let panel = NSOpenPanel()

            panel.directoryURL = self.ShellScptPath()
            panel.canChooseDirectories = true
            panel.canCreateDirectories = true
            panel.canChooseFiles = false
            panel.prompt = "脚本安装目录"
            panel.message = "请选择 usr > local > bin folder, 不存在时请手动创建"

            panel.begin { result in
                guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                      self.ShellScptPath().path == panel.url?.path else {
                          Alert.alert(message: "Shell folder was not selected")
                    return
                }
                
                guard let binDirectory = panel.url else {
                    return
                }
                
                guard let bookmarkData = try? binDirectory.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else {
                    return
                }
                UserDefaults.standard.set(binDirectory, forKey: panelDirectoryKey())
                UserDefaults.standard.setValue(bookmarkData, forKey: panelDirectoryBookmarkDataKey())
                copyShellScript(name: name, url: binDirectory)

            }
        }
    }

    static func resetShellScpt(name: String) {
        
        guard resetShellScptByBookmarkData(name: name) == false else {
            if !Constants.hasShellScptPath(name: name) {
                resetShellScptByPanel(name: name)
            }
            return
        }
        resetShellScptByPanel(name: name)
    }

    static func copyShellScript(name: String, url: URL) {
        let manager = FileManager.default
        
        let filePath: String
        
        let document = FileManager.DocumnetsDirectory() + "/\(name)"
        
        if manager.fileExists(atPath: document) {
            filePath = document
        } else {
            guard let path = Bundle.main.path(forResource: name, ofType: "") else {
                Alert.alert(message: "Fail")
                return
            }
            filePath = path
        }

        guard let JKTool = try? Data(contentsOf:URL(fileURLWithPath: filePath)) else {
            Alert.alert(message: "Fail")
            return
        }
        
        
        try? manager.createDirectory(at: url, withIntermediateDirectories: true)
        
        let binPathURL = url.appendingPathComponent(name, isDirectory: false)
        try? manager.removeItem(at: binPathURL)
        
        /// 绝对路径注意： 不能带file://，否则会调用失败；
        /// 设置文件权限： [FileAttributeKey.posixPermissions: 0o777]
        manager.createFile(atPath: binPathURL.path, contents: JKTool, attributes: [FileAttributeKey.posixPermissions: 0o777])

        Alert.alert(message: "Done")
        
        DispatchQueue.main.async{
            resetTip(name: "JKTool-completion")
        }
    }
    
}

public extension Constants{
    
    static func tipPanelDirectoryKey() -> String {
        return "tipPanelDirectory"
    }
    
    static func tipPanelDirectoryBookmarkDataKey() -> String {
        return "tipPanelDirectoryBookmarkData"
    }
    
    static func hasTipPath(name: String) -> Bool {
        return FileManager.default.fileExists(atPath: "/usr/local/etc/bash_completion.d")
    }
    
    static func TipPath() -> URL {
        return URL(fileURLWithPath: "/usr/local/etc/bash_completion.d")
    }
    
    static func resetTipByBookmarkData(name: String) -> Bool{
        guard let bookmarkData = UserDefaults.standard.data(forKey:tipPanelDirectoryBookmarkDataKey() ) else {
            return false
        }
        var isStale = false
        guard let binDirectory = try? URL(resolvingBookmarkData: bookmarkData, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) else {
            return false
        }
        
        _ = binDirectory.startAccessingSecurityScopedResource()
        copyTip(name: name, url: binDirectory)
        binDirectory.stopAccessingSecurityScopedResource()
        
        return true
    }
    
    static func resetTipByPanel(name: String){
        DispatchQueue.main.async{
            let panel = NSOpenPanel()

            panel.directoryURL = self.TipPath()
            panel.canChooseDirectories = true
            panel.canCreateDirectories = true
            panel.canChooseFiles = false
            panel.prompt = "脚本安装目录"
            panel.message = "请选择 /usr/local/etc/bash_completion.d, 不存在时请手动创建"

            panel.begin { result in
                guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                      self.TipPath().path == panel.url?.path else {
                          Alert.alert(message: "Shell folder was not selected")
                    return
                }
                
                guard let binDirectory = panel.url else {
                    return
                }
                
                guard let bookmarkData = try? binDirectory.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else {
                    return
                }
                UserDefaults.standard.set(binDirectory, forKey: tipPanelDirectoryKey())
                UserDefaults.standard.setValue(bookmarkData, forKey: tipPanelDirectoryBookmarkDataKey())
                copyTip(name: name, url: binDirectory)

            }
        }
    }

    static func resetTip(name: String) {
        
        guard resetTipByBookmarkData(name: name) == false else {
            if !Constants.hasTipPath(name: name) {
                resetTipByPanel(name: name)
            }
            return
        }
        resetTipByPanel(name: name)
    }

    static func copyTip(name: String, url: URL) {
        let manager = FileManager.default
        
        let document = FileManager.DocumnetsDirectory() + "/\(name)"
        
        if !manager.fileExists(atPath: document) {
            guard let path = Bundle.main.path(forResource: name, ofType: "") else {
                Alert.alert(message: "Fail")
                return
            }
            try? manager.removeItem(atPath: document)
            do {
                try manager.copyItem(atPath: path, toPath: document)
            } catch {
                print("\(error.localizedDescription)")
            }
            
        }
        
        try? manager.createDirectory(at: url, withIntermediateDirectories: true)
        
        let binPathURL = url.appendingPathComponent(name, isDirectory: false)
        try? manager.removeItem(at: binPathURL)
        
        do {
            try manager.copyItem(atPath: document, toPath: binPathURL.path)
            try manager.setAttributes([FileAttributeKey.posixPermissions: 0o777], ofItemAtPath: binPathURL.path)
        } catch {
            Alert.alert(message: "自动补全功能代码写入失败")
            return
        }

        Alert.alert(message: "自动补全功能代码写入成功")
        
        DispatchQueue.main.async{
            resetProfile()
        }
        
    }
}

public extension Constants{
    
    static func ProfilePanelDirectoryKey() -> String {
        return "ProfilePanelDirectory"
    }
    
    static func ProfilePanelDirectoryBookmarkDataKey() -> String {
        return "ProfilePanelDirectoryBookmarkData"
    }
    
    static func hasProfile() -> Bool {
        return FileManager.default.fileExists(atPath: ProfilePath().path)
    }
    
    static func ProfilePath() -> URL {
        let profile = FileManager.DocumnetsDirectory().replacingOccurrences(of: "/Library/Containers/com.jk.JKTool/Data/Documents", with: "/.bash_profile")
        return URL(fileURLWithPath: profile)
    }
    
    static func resetProfileByBookmarkData() -> Bool{
        guard let bookmarkData = UserDefaults.standard.data(forKey:ProfilePanelDirectoryBookmarkDataKey() ) else {
            return false
        }
        var isStale = false
        guard let binDirectory = try? URL(resolvingBookmarkData: bookmarkData, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) else {
            return false
        }
        
        _ = binDirectory.startAccessingSecurityScopedResource()
        modifyProfile()
        binDirectory.stopAccessingSecurityScopedResource()
        
        return true
    }
    
    static func resetProfileByPanel(){
        DispatchQueue.main.async{
            
            let path = self.ProfilePath().deletingLastPathComponent()
            let panel = NSOpenPanel()

            panel.directoryURL = path
            panel.canChooseDirectories = true
            panel.canCreateDirectories = true
            panel.canChooseFiles = false
            panel.prompt = "脚本安装目录"
            panel.message = "请选择 \(path), 不存在时请手动创建"

            panel.begin { result in
                guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                      path.path == panel.url?.path else {
                          Alert.alert(message: "Shell folder was not selected")
                    return
                }
                
                guard let binDirectory = panel.url else {
                    return
                }
                
                guard let bookmarkData = try? binDirectory.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else {
                    return
                }
                UserDefaults.standard.set(binDirectory, forKey: ProfilePanelDirectoryKey())
                UserDefaults.standard.setValue(bookmarkData, forKey: ProfilePanelDirectoryBookmarkDataKey())
                modifyProfile()

            }
        }
    }

    static func resetProfile() {
        
        guard resetProfileByBookmarkData() == false else {
            if !Constants.hasProfile() {
                resetProfileByPanel()
            }
            return
        }
        resetProfileByPanel()
    }

    static func modifyProfile() {
        
        let data = try? Data(contentsOf: ProfilePath())
        
        
        var profile = String(data: data ?? Data(), encoding: .utf8) ?? ""
        
        if !profile.contains("/usr/local/etc/bash_completion.d/JKTool-completion") {
            profile = profile + """
            \n
            if [ -f /usr/local/etc/bash_completion.d/JKTool-completion ]; then
                . /usr/local/etc/bash_completion.d/JKTool-completion
            fi
            """
            do {
                try profile.write(to: ProfilePath(), atomically: true, encoding: .utf8)
            } catch {
                Alert.alert(message: "写入自动补全功能失败")
                return
            }
        }

        Alert.alert(message: "写入自动补全功能成功")
    }
}
