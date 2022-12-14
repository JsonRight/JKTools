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
    
    @IBAction func installScript(_ sender: Any) {
        Constants.resetShellScpt(name: "JKTool")
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


