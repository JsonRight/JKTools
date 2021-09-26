//
//  Alert.swift
//  JKTools
//
//  Created by 姜奎 on 2021/9/26.
//

import Foundation
import Cocoa

struct Alert {
    
    static func alert(message: String) {
      let alert = NSAlert()
      alert.messageText = "🐢 JKTool"
      alert.informativeText = message
      alert.addButton(withTitle: "OK")

      alert.runModal()
    }

}
