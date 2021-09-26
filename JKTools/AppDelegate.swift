//
//  AppDelegate.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/1.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
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
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            let window = sender.windows.first
            window?.makeKeyAndOrderFront(nil)
        }
        return true
    }
    

    @IBAction func clean(_ sender: AnyObject?) {
        resetScpt()
    }
    
    func resetScpt() {
        Constants.resetScpt(id: .LauncherApp)
        Constants.resetScpt(id: .FinderExtension)
    }

}

