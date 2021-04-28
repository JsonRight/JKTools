//
//  AppleScriptCommand.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/22.
//

import Foundation
import Cocoa

func fourCharCode(from string : String) -> FourCharCode
{
  return string.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
}

var scriptPath: URL? {
  return try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

var bundle: String {
    return Bundle(for: AppleScriptCommand.self).bundleIdentifier!
}

func fileScriptPath(fileName: String) -> URL? {
  return scriptPath?
    .appendingPathComponent(fileName)
    .appendingPathExtension("scpt")
}

public func openPanel() {
    let panel = NSOpenPanel()
    panel.directoryURL = scriptPath
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.prompt = "Select Script Folder"
    panel.message = "Please select the User > Library > Application Scripts > \(bundle) folder"

    panel.begin { result in
        guard result.rawValue == NSApplication.ModalResponse.OK.rawValue,
              panel.url == scriptPath else {
            alert(message: "Script folder was not selected")
            return
        }
    
        let result = copy()
        if result {
            alert(message: "Done")
        } else {
            alert(message: "Fail")
        }
    }
}

public func alert(message: String) {
  let alert = NSAlert()
  alert.messageText = "🐢 JKTool"
  alert.informativeText = message
  alert.addButton(withTitle: "OK")

  alert.runModal()
}

func copy() -> Bool {
  
    guard let scriptUrl = Bundle.main.url(forResource: "JKToolScript", withExtension: "scpt") else {
        return false
    }
    guard let destinationPath = fileScriptPath(fileName: "JKToolScript") else {
      return false
    }
    
    do {
      try FileManager.default.removeItem(at: destinationPath)
    } catch {
      
    }

    do {
      try FileManager.default.copyItem(at: scriptUrl, to: destinationPath)
    } catch {
      return false
    }
    
    return true
}

public func runScript(appleScript: AppleScriptCommand?) {
    
    let (event, filePath) = tryRunUserScript(appleScript: appleScript)
    
    guard let event1 = event else {
        return
    }
    guard let filePath1 = filePath else {
        return
    }
    
    let script: NSAppleScript = {
        var error: NSDictionary? = nil
        let script = NSAppleScript(contentsOf: filePath1, error: &error)
        return script!
    }()
    var error: NSDictionary? = nil
    _ = script.executeAppleEvent(event1, error: &error)
    _ = script.executeAndReturnError(&error)
    if let error = error {
        print(error)
    }
}

public func tryRunUserScript(appleScript: AppleScriptCommand?) -> (event: NSAppleEventDescriptor?,filePath: URL?) {
    guard let command = appleScript else {
        return (nil,nil)
    }
    
    guard let filePath = fileScriptPath(fileName: "JKToolScript") else {
      return (nil,nil)
    }

    guard FileManager.default.fileExists(atPath: filePath.path) else {
      openPanel()
      return (nil,nil)
    }
    
    let parameters = NSAppleEventDescriptor.list()
    parameters.insert(NSAppleEventDescriptor(string: command.toolName), at: 0)
    parameters.insert(NSAppleEventDescriptor(string: command.script), at: 0)
    parameters.insert(NSAppleEventDescriptor(string: command.path), at: 0)

    let event = NSAppleEventDescriptor(
        eventClass: AEEventClass(fourCharCode(from: "ascr")),
        eventID: AEEventID(fourCharCode(from: "psbr")),
        targetDescriptor: nil,
        returnID: AEReturnID(kAutoGenerateReturnID),
        transactionID: AETransactionID(kAnyTransactionID)
    )
    event.setDescriptor(NSAppleEventDescriptor(string: "JKToolScript"), forKeyword: AEKeyword(fourCharCode(from: "snam")))
    event.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))
    return (event, filePath)
}

public func runUserScript(appleScript: AppleScriptCommand?){
    
    let (event, filePath) = tryRunUserScript(appleScript: appleScript)
    
    guard let event1 = event else {
        return
    }
    guard let filePath1 = filePath else {
        return
    }
    
    let appleScript = try! NSUserAppleScriptTask(url: filePath1)
    appleScript.execute(withAppleEvent: event1, completionHandler: { (_, error) in
        if let error = error {
            print(error)
        }
    })
    
}

public class AppleScriptCommand {
    let toolName: String
    let script: String
    let path: String
    init(toolName: String,script: String, path:String) {
        self.toolName = toolName
        self.script = script
        self.path = path
    }
}

public extension AppleScriptCommand {
    static func JKToolScript(needToPath:Bool, script:String,options: ConsoleOptions) ->AppleScriptCommand? {
        var consoleScript = "JKTool \(script)"
        guard let path = options.path else {
            return nil
        }
        
        consoleScript = consoleScript + " -p=" + path
        
        if let url = options.url {
            consoleScript = consoleScript + " -u=" + url
        }
        
        if let branch = options.branch {
            consoleScript = consoleScript + " -b=" + branch
        }
        
        if let tag = options.tag {
            consoleScript = consoleScript + " -v=" + tag
        }
        
        if let scheme = options.scheme {
            consoleScript = consoleScript + " -t=" + scheme
        }
    
        if let cache = options.cache {
            consoleScript = consoleScript + " -c=" + "\(cache)"
        }
        
        if let config = options.config {
            consoleScript = consoleScript + " -m=" + "\(config)"
        }
        
        if let export = options.export {
            consoleScript = consoleScript + " -e=" + export
        }
        
        if let libraryOptions = options.libraryOptions {
            consoleScript = consoleScript + " -l=" + "\(libraryOptions)"
        }
        
        if let desc = options.desc {
            consoleScript = consoleScript + " -d=" + desc
        }
        
        consoleScript = consoleScript + ";"
        
        let cd = "cd \(path);"
        consoleScript = "\(needToPath ? cd : "")" + consoleScript + "\(needToPath ? "" : cd)"
        return AppleScriptCommand(toolName: "Terminal", script: consoleScript, path: path)
    }
    
    static func AppleScript(script:String,options: ConsoleOptions) ->AppleScriptCommand? {
        guard let path = options.path else {
            return nil
        }
        let consoleScript = "open -a \(script) "
        return AppleScriptCommand(toolName: script, script: consoleScript, path: path)
    }
}
