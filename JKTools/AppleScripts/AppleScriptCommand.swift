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

// NSAppleScript不能用了
//func runScript(appleScript: AppleScriptCommand?, id: Constants.Id) {
//
//    let (event, filePath) = tryRunUserScript(appleScript: appleScript, id: id)
//
//    guard let event1 = event else {
//        return
//    }
//    guard let filePath1 = filePath else {
//        return
//    }
//    let script: NSAppleScript = {
//        var error: NSDictionary? = nil
//        let script = NSAppleScript(contentsOf: filePath1, error: &error)
//        return script!
//    }()
//    var error: NSDictionary? = nil
//    _ = script.executeAppleEvent(event1, error: &error)
//    _ = script.executeAndReturnError(&error)
//    if let error = error {
//        print(error)
//    }
//}

func runUserScript(appleScript: AppleScriptCommand?, id: Constants.Id){
    
    let (event, filePath) = tryRunUserScript(appleScript: appleScript,id: id)
    
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

func tryRunUserScript(appleScript: AppleScriptCommand?, id: Constants.Id) -> (event: NSAppleEventDescriptor?,filePath: URL?) {
    guard let command = appleScript else {
        return (nil,nil)
    }
    
    guard let filePath = id.fileScriptPath(fileName: "JKToolScript") else {
      return (nil,nil)
    }

    guard FileManager.default.fileExists(atPath: filePath.path) else {
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

class AppleScriptCommand {
    let toolName: String
    let script: String
    let path: String
    init(toolName: String,script: String, path:String) {
        self.toolName = toolName
        self.script = script
        self.path = path
    }
}

extension AppleScriptCommand {
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
        
        if let target = options.target {
            consoleScript = consoleScript + " -t=" + target
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
