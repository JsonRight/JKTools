//
//  PreferencesCellView.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/9.
//

import Cocoa

class PreferencesCellView: NSTableCellView {

    var projectInfo: ProjectInfoBean? {
        didSet{
            if let projectName = self.projectInfo?.projectName  {
                self.projectNameLab.stringValue = projectName
            }
            if let projectPath = self.projectInfo?.projectPath  {
                self.projectPathLab.stringValue = projectPath
            }
            if let sourcePath = self.projectInfo?.sourcePath  {
                self.sourcePathLab.stringValue = sourcePath
            }
        }
    }
    
    @IBOutlet weak var projectNameLab: NSTextField!
    
    @IBOutlet weak var projectPathLab: NSTextField!
    
    @IBOutlet weak var sourcePathLab: NSTextField!
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            projectNameLab.isSelectable = true
            projectPathLab.isSelectable = true
            sourcePathLab.isSelectable = true
            projectNameLab.isEditable = true
            self.layer?.backgroundColor = NSColor.systemGray.cgColor
    }
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            if backgroundStyle == .normal {
                self.layer?.backgroundColor = NSColor.systemGray.cgColor
            }else {
                self.layer?.backgroundColor = NSColor.blue.cgColor
            }
        }
    }
    
}

extension NSTextField {
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        
        switch event.charactersIgnoringModifiers {
            case "a":
                return NSApp.sendAction(#selector(NSText.selectAll(_:)), to: self.window?.firstResponder, from: self)
            case "c":
                return NSApp.sendAction(#selector(NSText.copy(_:)), to: self.window?.firstResponder, from: self)
            case "v":
                return NSApp.sendAction(#selector(NSText.paste(_:)), to: self.window?.firstResponder, from: self)
            case "x":
                return NSApp.sendAction(#selector(NSText.cut(_:)), to: self.window?.firstResponder, from: self)
            default:
                return super.performKeyEquivalent(with: event)
        }
    }
}

extension PreferencesCellView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        projectInfo?.projectName = projectNameLab.stringValue
    }
}

extension PreferencesCellView {
    override func rightMouseDown(with event: NSEvent) {
        let menus = MenuItem.subScriptEnum(isRootProject:true)

        let menu = menuView(menus: menus,target: self, action: #selector(self.action(item:)))
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    @objc func action(item: NSMenuItem) {
        guard let menu = IntMenuItem(rawValue: item.tag) else {
            return
        }
        
        runScript(appleScript: menu.toString().run(consoleOptions: ConsoleOptions(url: self.projectInfo?.sourcePath, path: self.projectInfo?.projectPath)))
        
   }
}
