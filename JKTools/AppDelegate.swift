//
//  AppDelegate.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/1.
//

import Cocoa
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if !Constants.hasShellScptPath(name: "JKTool") {
            Constants.resetShellScpt(name: "JKTool")
        }
        
        if !Constants.Id.LauncherApp.hasFileScriptPath() {
            Constants.resetScpt(id: .LauncherApp)
        }
        if !Constants.Id.FinderExtension.hasFileScriptPath() {
            Constants.resetScpt(id: .FinderExtension)
        }
        setStatusItemIcon()
        setStatusItemVisible()
        setStatusToggle()
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
    
    func resetScpt() {
        Constants.resetShellScpt(name: "JKTool")
        Constants.resetScpt(id: .LauncherApp)
        Constants.resetScpt(id: .FinderExtension)
    }

}

extension AppDelegate {
    
    // MARK: - Status Bar Item
    
    func setStatusItemIcon() {
        let icon = NSImage(named: "Image")
        icon?.isTemplate = true // Support Dark Mode
        DispatchQueue.main.async {
            self.statusItem.button?.image = icon
        }
    }
    
    func setStatusItemVisible() {
        statusItem.isVisible = true
    }
    
    func setStatusToggle() {
        statusItem.button?.action = #selector(action(_:))
    }
    @IBAction func action(_ item: NSMenuItem) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        for window in NSApplication.shared.windows {
            window.makeKeyAndOrderFront(self)
        }
   }
}
