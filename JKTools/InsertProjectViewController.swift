//
//  InsertProjectViewController.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/9.
//

import Cocoa

class InsertProjectViewController: NSViewController {
    
    @IBOutlet weak var projectNameLab: NSTextField!
    
    @IBOutlet weak var projectPathLab: NSTextField!
    
    @IBOutlet weak var sourcePathLab: NSTextField!
    typealias Callback = (ProjectInfoBean) -> Void
    var callback:Callback?
    var isInsertAction = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func textfieldAction(_ sender: Any) {
        guard isInsertAction else {
            checkAndInsert(projectName: projectNameLab.stringValue, projectPath: projectPathLab.stringValue, sourcePath: sourcePathLab.stringValue,isInsertAction: false)
            return
        }
        
    }
    @IBAction func insertAction(_ sender: NSButton) {
        checkAndInsert(projectName: projectNameLab.stringValue, projectPath: projectPathLab.stringValue, sourcePath: sourcePathLab.stringValue,isInsertAction: true)
    }
    
    func checkAndInsert(projectName: String, projectPath: String, sourcePath: String, isInsertAction:Bool) {
        
        
        guard projectPath != "" else {
            return
        }
        
        guard sourcePath != "" else {
            return
        }
        
        guard let projectPathURL = NSURL(string: projectPath) else {
            return
        }
        
        guard let sourcePathURL = NSURL(string: sourcePath) else {
            return
        }
        
        guard projectName != "" else {
            if let lastPathComponent = sourcePathURL.lastPathComponent {
                projectNameLab.stringValue = lastPathComponent;
            }else if let lastPathComponent = projectPathURL.lastPathComponent {
                projectNameLab.stringValue = lastPathComponent;
            }
            return
        }
        
        self.isInsertAction = isInsertAction
        let projectInfo = ProjectInfoBean(projectName: projectName, projectPath: projectPath, sourcePath: sourcePath)
        callback?(projectInfo)
        dismiss(self)
    }
    
}
