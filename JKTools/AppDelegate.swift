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
        guard let path = Bundle.main.path(forResource: "JKTool", ofType: "") else {
            return
        }
        
        do {
            let manager = FileManager.default
            /// 绝对路径注意： 不能带file://，否则会调用失败；
            /// 设置文件权限： [FileAttributeKey.posixPermissions: 0o777]
//            manager.createFile(atPath: "/usr/local/bin/JKTool", contents: tool, attributes: [FileAttributeKey.posixPermissions: 0o777])
            /// 构建快捷方式，权限将和原文件权限一致
            try manager.createSymbolicLink(atPath: "/usr/local/bin/JKTool", withDestinationPath: path)
        } catch {}
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


}

