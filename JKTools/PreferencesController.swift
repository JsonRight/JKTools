//
//  PreferencesController.swift
//  JKTools
//
//  Created by 姜奎 on 2022/7/22.
//

import Cocoa

class PreferencesController: NSViewController {

    @IBOutlet weak var subModulePath: NSTextField!
    
    @IBOutlet weak var buildsPath: NSTextField!
    
    @IBOutlet weak var buildPath: NSTextField!
    
    lazy var config: JKToolConfig = {
        return JKToolConfig.read()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subModulePath.stringValue = self.config.checkouts
        self.buildsPath.stringValue = self.config.builds
        self.buildPath.stringValue = self.config.build
    }
    
}

extension PreferencesController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSTextField
        if textfield.tag == 1 && self.config.checkouts != textfield.stringValue {
            self.config.checkouts = textfield.stringValue
            self.config.save()
        } else if textfield.tag == 2 && self.config.builds != textfield.stringValue {
            self.config.builds = textfield.stringValue
            self.config.save()
        } else if textfield.tag == 3 && self.config.build != textfield.stringValue {
            self.config.build = textfield.stringValue
            self.config.save()
        }
    }
}

