//
//  MenuView.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/23.
//

import Foundation
import Cocoa

public enum MenuItemOptions {
    case JKToolsRootProject
    case JKToolsSubProject
    case FinderSyncExtension

    func subScriptEnum() -> [MenuItem] {
        switch self {
        case .JKToolsRootProject:
            return [.help,.clone,.clone_project,.pull,.pull_all,.prune,.prune_all,.add_tag,.del_tag,.build,.archive,.upload,.one_key_upload]
        case .JKToolsSubProject:
            return [.help,.clone,.pull,.pull_all,.prune,.prune_all,.add_tag,.del_tag,.build]
        case .FinderSyncExtension:
            return [.help,.clone,.clone_project,.pull,.pull_all,.prune,.prune_all,.add_tag,.del_tag,.build,.archive,.upload,.one_key_upload]
    }
    }
}

public enum IntMenuItem: Int {
    case help = 1
    case clone
    case clone_project
    case pull
    case pull_all
    case prune
    case prune_all
    case add_tag
    case del_tag
    case build
    case archive
    case upload
    case one_key_upload
    case Xcode
    case Terminal
    case Finder
    case script
    
    
    func toString() -> MenuItem {
        switch self {
        case .help:return MenuItem.help
        case .clone:return MenuItem.clone
        case .clone_project:return MenuItem.clone_project
        case .pull:return MenuItem.pull
        case .pull_all:return MenuItem.pull_all
        case .prune:return MenuItem.prune
        case .prune_all:return MenuItem.prune_all
        case .add_tag:return MenuItem.add_tag
        case .del_tag:return MenuItem.del_tag
        case .build:return MenuItem.build
        case .archive:return MenuItem.archive
        case .upload:return MenuItem.upload
        case .one_key_upload:return MenuItem.one_key_upload
        case .Xcode:return MenuItem.Xcode
        case .Terminal:return MenuItem.Terminal
        case .Finder:return MenuItem.Finder
        case .script:return MenuItem.script
        }
    }
     
}
public enum MenuItem: String {
    case help
    case clone
    case clone_project
    case pull
    case pull_all
    case prune
    case prune_all
    case add_tag
    case del_tag
    case build
    case archive
    case upload
    case one_key_upload
    case Xcode
    case Terminal
    case Finder
    case script
    
    func run(consoleOptions:ConsoleOptions) -> AppleScriptCommand? {

        switch self {
        case .help:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .clone:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .clone_project:return .JKToolScript(needToPath:false,script:self.rawValue,options:consoleOptions)
        case .pull:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .pull_all:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .prune:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .prune_all:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .add_tag:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .del_tag:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .build:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .archive:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .upload:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .one_key_upload:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
        case .Xcode:return .AppleScript(script:self.rawValue,options:consoleOptions)
        case .Terminal:return .AppleScript(script:self.rawValue,options:consoleOptions)
        case .Finder:return .AppleScript(script:self.rawValue,options:consoleOptions)
        case .script:return nil
        }
    }
//    func run1(consoleOptions:ConsoleOptions, block:(AppleScriptCommand?) -> Void) {
//
//
//        switch self {
//        case .help: block(run(consoleOptions: consoleOptions))
//        case .clone: block(run(consoleOptions: consoleOptions))
//        case .clone_project:block(run(consoleOptions: consoleOptions))
//        case .pull: block(run(consoleOptions: consoleOptions))
//        case .pull_all: block(run(consoleOptions: consoleOptions))
//        case .prune: block(run(consoleOptions: consoleOptions))
//        case .prune_all: block(run(consoleOptions: consoleOptions))
//        case .add_tag: block(run(consoleOptions: consoleOptions))
//        case .del_tag: block(run(consoleOptions: consoleOptions))
//        case .build: block(run(consoleOptions: consoleOptions))
//        case .archive: block(run(consoleOptions: consoleOptions))
//        case .upload: block(run(consoleOptions: consoleOptions))
//        case .one_key_upload: block(run(consoleOptions: consoleOptions))
//        case .Xcode: block(run(consoleOptions: consoleOptions))
//        case .Terminal: block(run(consoleOptions: consoleOptions))
//        case .Finder: block(run(consoleOptions: consoleOptions))
//        case .script:block(run(consoleOptions: consoleOptions))
//        }
//    }
    
    func toInt() -> IntMenuItem {
        switch self {
        case .help:return IntMenuItem.help
        case .clone:return IntMenuItem.clone
        case .clone_project:return IntMenuItem.clone_project
        case .pull:return IntMenuItem.pull
        case .pull_all:return IntMenuItem.pull_all
        case .prune:return IntMenuItem.prune
        case .prune_all:return IntMenuItem.prune_all
        case .add_tag:return IntMenuItem.add_tag
        case .del_tag:return IntMenuItem.del_tag
        case .build:return IntMenuItem.build
        case .archive:return IntMenuItem.archive
        case .upload:return IntMenuItem.upload
        case .one_key_upload:return IntMenuItem.one_key_upload
        case .Xcode:return IntMenuItem.Xcode
        case .Terminal:return IntMenuItem.Terminal
        case .Finder:return IntMenuItem.Finder
        case .script:return IntMenuItem.script
        }
    }
    
    static func subScriptEnum(isRootProject:Bool) -> [MenuItem] {
//        let con = ConsoleOptions(url: nil, path: nil)
        
//        MenuItem.Finder.run1(consoleOptions: con) { com in
//
//        }
        if isRootProject {
            return [.help,.clone,.clone_project,.pull,.pull_all,.prune,.prune_all,.add_tag,.del_tag,.build,.archive,.upload,.one_key_upload]
        }
        return [.help,.clone,.pull,.pull_all,.prune,.prune_all,.add_tag,.del_tag,.build]
    }
     
}

public func menuView(menus:[MenuItem], target: AnyObject?, action: Selector?) -> NSMenu {
    
    let menuView = NSMenu.init()
    menuView.autoenablesItems = false
    let Xcode = NSMenuItem(title: MenuItem.Xcode.rawValue, action: action, keyEquivalent: "")
    menuView.addItem(Xcode)
    Xcode.target = target
    Xcode.tag = IntMenuItem.Xcode.rawValue
    Xcode.image =  NSImage(named: NSImage.computerName)!
    
    let Terminal = NSMenuItem(title: MenuItem.Terminal.rawValue, action: action, keyEquivalent: "")
    menuView.addItem(Terminal)
    Terminal.target = target
    Terminal.tag = IntMenuItem.Terminal.rawValue
    Terminal.image =  NSImage(named: NSImage.computerName)!
    
    if !Constants.isFinderExtension() {
        let Finder = NSMenuItem(title: MenuItem.Finder.rawValue, action: action, keyEquivalent: "")
        menuView.addItem(Finder)
        Finder.target = target
        Finder.tag = IntMenuItem.Finder.rawValue
        Finder.image =  NSImage(named: NSImage.computerName)!
    }
    
    let script = NSMenuItem(title: MenuItem.script.rawValue, action: action, keyEquivalent: "")
    menuView.addItem(script)
    script.target = target
    script.tag = IntMenuItem.script.rawValue
    script.image =  NSImage(named: NSImage.computerName)!
    
    let scriptItem = NSMenu.init(title: MenuItem.script.rawValue)
    menuView.setSubmenu(scriptItem, for: script)
    scriptItem.autoenablesItems = false
    
    for menuItem in menus {
        let menu = NSMenuItem(title: menuItem.rawValue, action: action, keyEquivalent: "")
        scriptItem.addItem(menu)
        menu.target = target
        menu.tag = menuItem.toInt().rawValue
        menu.image =  NSImage(named: NSImage.computerName)!
    }
    
    return menuView
}
