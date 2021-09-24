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
        
    }
    
    // MARK: - Primary Finder Sync protocol methods
    
    override func beginObservingDirectory(at url: URL) {
        // The user is now seeing the container's contents.
        // If they see it in more than one view at a time, we're only told once.
        NSLog("beginObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    
    override func endObservingDirectory(at url: URL) {
        // The user is no longer seeing the container's contents.
        NSLog("endObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    override func requestBadgeIdentifier(for url: URL) {
        NSLog("requestBadgeIdentifierForURL: %@", url.path as NSString)
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
        
        guard let path = FIFinderSyncController.default().targetedURL()?.path else {
            return
        }
        
        guard let paths = FIFinderSyncController.default().selectedItemURLs() else {
            return
        }
    
        runUserScript(appleScript: menu.toString().run(consoleOptions: ConsoleOptions(url: nil, path: path)))
//        runScript(appleScript: menu.toString().run(consoleOptions: ConsoleOptions(url: nil, path: path)))
        
   }

}

