//
//  MenuView.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/23.
//

import Foundation
import Cocoa
public enum IntMenuItem: Int {
    case help = 1
    case clone
    case clone_project
    case pull
    case pull_all
    case prune_branch
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
        case .prune_branch:return MenuItem.prune_branch
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
    case prune_branch
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
        case .prune_branch:return .JKToolScript(needToPath:true,script:self.rawValue,options:consoleOptions)
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
    
    func toInt() -> IntMenuItem {
        switch self {
        case .help:return IntMenuItem.help
        case .clone:return IntMenuItem.clone
        case .clone_project:return IntMenuItem.clone_project
        case .pull:return IntMenuItem.pull
        case .pull_all:return IntMenuItem.pull_all
        case .prune_branch:return IntMenuItem.prune_branch
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
        if isRootProject {
            return [.help,.clone,.clone_project,.pull,.pull_all,.prune_branch,.add_tag,.del_tag,.build,.archive,.upload,.one_key_upload]
        }
        return [.help,.clone,.pull,.pull_all,.prune_branch,.add_tag,.del_tag,.build]
    }
     
}

public func menuView(consoleOptions:ConsoleOptions, menus:[MenuItem], target: AnyObject?, action: Selector?) -> NSMenu {
    
    let menuView = NSMenu.init()
    menuView.autoenablesItems = false
    let Xcode = NSMenuItem(title: MenuItem.Xcode.rawValue, action: action, keyEquivalent: "")
    menuView.addItem(Xcode)
    Xcode.target = target
    Xcode.tag = IntMenuItem.Xcode.rawValue
    
    let Terminal = NSMenuItem(title: MenuItem.Terminal.rawValue, action: action, keyEquivalent: "")
    menuView.addItem(Terminal)
    Terminal.target = target
    Terminal.tag = IntMenuItem.Terminal.rawValue
    
    let Finder = NSMenuItem(title: MenuItem.Finder.rawValue, action: action, keyEquivalent: "")
    menuView.addItem(Finder)
    Finder.target = target
    Finder.tag = IntMenuItem.Finder.rawValue
    
    let script = NSMenuItem(title: MenuItem.script.rawValue, action: action, keyEquivalent: "")
    menuView.addItem(script)
    script.target = target
    script.tag = IntMenuItem.script.rawValue
    
    let scriptItem = NSMenu.init(title: MenuItem.script.rawValue)
    menuView.setSubmenu(scriptItem, for: script)
    scriptItem.autoenablesItems = false
    
    for menuItem in menus {
        let menu = NSMenuItem(title: menuItem.rawValue, action: action, keyEquivalent: "")
        scriptItem.addItem(menu)
        menu.target = target
        menu.tag = menuItem.toInt().rawValue
    }
    
    return menuView
}
