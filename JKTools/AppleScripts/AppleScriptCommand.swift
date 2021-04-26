//
//  AppleScriptCommand.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/22.
//

import Foundation
public func runScript(appleScript: AppleScriptCommand?) {
    guard let command = appleScript else {
        return
    }
    let script: NSAppleScript = {
        let script = NSAppleScript(source: command.script)!
        return script
    }()
    var error: NSDictionary? = nil
    _ = script.executeAndReturnError(&error)
}

public struct AppleScriptCommand {
    public var script: String
    public init(script: String) {
        self.script = script
    }
}

public extension AppleScriptCommand {
    static func JKToolScript(needToPath:Bool, script:String,options: ConsoleOptions) ->AppleScriptCommand? {
        guard let path = options.path else {
            return nil
        }
        
        let cd = "cd \(path); "
        
        
        let consoleScript = """
            tell application "Terminal"
                do script with command "\(needToPath ? cd : "")JKTool \(script) -u=\(options.url ?? "") -p=\(path) -b=\(options.branch ?? "") -v=\(options.tag ?? "") -c=\(options.cache) -m=\(options.config) -t=\(options.scheme ?? "") -e=\(options.export) -l=\(options.libraryOptions) -d=\(options.desc) ; \(needToPath ? "" : cd)"
            end tell
            """
        return AppleScriptCommand(script: consoleScript)
    }
    
    static func AppleScript(script:String,options: ConsoleOptions) ->AppleScriptCommand? {
        guard let path = options.path else {
            return nil
        }
        let consoleScript = """
            tell application "\(script)"
                do shell script "open -a \(script) " & quoted form of "\(path)"
            end tell
            """
        return AppleScriptCommand(script: consoleScript)
    }
}
