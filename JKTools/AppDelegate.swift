//
//  AppDelegate.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/1.
//

import Cocoa
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var download = false
    
    @IBOutlet weak var menus: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadStatusItem(download: false)
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
        if self.download {
            return
        }
        self.download = true
        loadStatusItem(download: true)
        guard let urlStr = JKToolConfig.read().toolUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let url = URL(string: urlStr) else {
            Alert.alert(message: "转换JKTool下载路径失败，请检查路径是否有效")
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringCacheData,
            timeoutInterval: 10)
        let downloadTask = session.downloadTask(with: request) { location, response, error in
            guard let locationPath = location?.path,error == nil else {
                self.download = false
                self.loadStatusItem(download: false)
                return
            }
            
            print("locationPath:\(locationPath)")
            let document = FileManager.DocumnetsDirectory() + "/JKTool"
            print("document:\(document)")
            try? FileManager.default.removeItem(atPath: document)
            try? FileManager.default.moveItem(atPath: locationPath, toPath: document)
            
            Constants.resetShellScpt(name: "JKTool")
            self.loadStatusItem(download: false)
            self.download = false
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
    
    func loadStatusItem(download: Bool) {
        
        guard let button = statusItem.button else {
            return
        }
        DispatchQueue.main.async{
            if !download {
                let icon = NSImage(named: "Image")
                button.image = icon
            } else{//square.and.arrow.down
                let icon = NSImage(systemSymbolName: "square.and.arrow.down.on.square", accessibilityDescription: nil)
                button.image = icon
            }
            button.action = #selector(self.action(_:))
            self.statusItem.menu = self.menus
            self.statusItem.isVisible = true
        }
       
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


