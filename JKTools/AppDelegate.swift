//
//  AppDelegate.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/1.
//

import Cocoa
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menus: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadStatusItem()
        uploadScript()
        
        
//        if let bookmarkData = UserDefaults.standard.data(forKey: "DesktopBookmarkData"){
//
//            var isStale = false
//
//            if let desktopDirectory = try? URL(resolvingBookmarkData: bookmarkData, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
//                desktopDirectory.startAccessingSecurityScopedResource()
//                do {
//                    let json = try shellOut(to: "xcodebuild -list -project /Users/jiangkui/Desktop/JKProject/Notebook/Module/checkouts/JKFoundation/JKFoundation.xcodeproj -json")
//                    print(json)
//                } catch {
//                    let error = error as! ShellOutError
//                    print("message:" + error.message + "---------")
//                    print("output:" + error.output)
//                }
//                desktopDirectory.stopAccessingSecurityScopedResource()
//                Alert.alert(message: "Done")
//                return
//            }
//        }
        

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            sender.activate(ignoringOtherApps: true)
            let window = sender.windows.first
            window?.makeKeyAndOrderFront(self)
            return true
        }
        return false
    }
    

    @IBAction func clean(_ sender: AnyObject?) {
        resetScpt()
    }
    
    @IBAction func install(_ sender: NSMenuItem) {
        sender.isEnabled = false
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: URL(fileURLWithPath: ""), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let downloadTask = session.downloadTask(with: request) { location, response, error in
            guard let locationPath = location?.path else {
                return
            }
            print("location:\(location?.description)[\(locationPath)]")
            let document = FileManager.DocumnetsDirectory() + "/JKTool"
            
            try? FileManager.default.moveItem(atPath: locationPath, toPath: document)
            Constants.resetShellScpt(name: "JKTool")
            sender.isEnabled = true
        }
        downloadTask.resume()
        
    }
    
    
    @IBAction func exit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func resetScpt() {
        Constants.resetShellScpt(name: "JKTool")
        Constants.resetScpt(id: .LauncherApp)
        Constants.resetScpt(id: .FinderExtension)
    }

}

extension AppDelegate {
    
    func loadStatusItem() {
        
        guard let button = statusItem.button else {
            return
        }
        let icon = NSImage(named: "Image")
        icon?.isTemplate = true // Support Dark Mode
        button.image = icon
        button.action = #selector(self.action(_:))
        self.statusItem.menu = self.menus
        self.statusItem.isVisible = true
    }
    
    @IBAction func action(_ item: NSMenuItem) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        for window in NSApplication.shared.windows {
            window.makeKeyAndOrderFront(self)
        }
    }
    
}

extension AppDelegate {
    
    func uploadScript() {
        
        if !Constants.hasShellScptPath(name: "JKTool") {
            Constants.resetShellScpt(name: "JKTool")
        }

//        if !Constants.Id.LauncherApp.hasFileScriptPath() {
//            Constants.resetScpt(id: .LauncherApp)
//        }
//        if !Constants.Id.FinderExtension.hasFileScriptPath() {
//            Constants.resetScpt(id: .FinderExtension)
//        }
    }
}


