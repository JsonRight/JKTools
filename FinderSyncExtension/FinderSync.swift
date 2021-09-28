//
//  FinderSync.swift
//  FinderSyncExtension
//
//  Created by 姜奎 on 2021/4/27.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [.skipHiddenVolumes]) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
//        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }

    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "JKTools"
    }
    
    override var toolbarItemToolTip: String {
        return "JKTools: Click the toolbar item for a menu."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: NSImage.computerName)!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        
        let menus = MenuItem.subScriptEnum(isRootProject:false)

        let menu = menuView(menus: menus,target: self, action: #selector(action(_:)))
        
        return menu
    }
    
    @IBAction func action(_ item: NSMenuItem) {
        
        guard let menu = IntMenuItem(rawValue: item.tag) else {
            return
        }
        
        if let selectedURLs = FIFinderSyncController.default().selectedItemURLs() {
            for selectedURL in selectedURLs {
                runUserScript(appleScript: menu.toString().run(consoleOptions: ConsoleOptions(url: nil, path: selectedURL.path)))
            }
        } else if let path = FIFinderSyncController.default().targetedURL()?.path {
            
            runUserScript(appleScript: menu.toString().run(consoleOptions: ConsoleOptions(url: nil, path: path)))
        }
        
   }
}

