//
//  PreferencesViewController.swift
//  JKTools
//
//  Created by 姜奎 on 2021/4/9.
//

import Cocoa
import AppKit

class PreferencesViewController: NSViewController {

    lazy var projectArr = Projects.projectsList()
    
    @IBOutlet weak var table: NSTableView!
    
    @IBOutlet weak var subScroll: NSScrollView!
    
    @IBOutlet weak var subView: NSView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.rowHeight = 73
    }
    
    @IBAction func cloneAction(_ sender: Any) {
        if self.projectArr.count <= 0 {
            return
        }
        let selectedRow = self.table.selectedRow
        if selectedRow < 0 {
            return
        }
        let projectInfo = self.projectArr[selectedRow]
        
    }
    

    @IBAction func switchAction(_ sender: Any) {
        if self.projectArr.count <= 0 {
            return
        }
        let selectedRow = self.table.selectedRow
        let projectInfo = self.projectArr[selectedRow]
        
        
    }
    
    
    @IBSegueAction func pop(_ coder: NSCoder) -> InsertProjectViewController? {
        let vc = InsertProjectViewController(coder: coder)
    
        vc?.callback = { [weak self] projectInfo in
            self?.insert(projectInfo)
        }
        return vc
    }
    
}
    
    

extension PreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return projectArr.count
    }
}

extension PreferencesViewController: NSTableViewDelegate{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PreferencesCellView"), owner: self) as! PreferencesCellView
        cell.projectInfo = projectArr[row]
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if edge == .trailing {
            let action = NSTableViewRowAction(style: .destructive, title: "DEL") { (action, row) in
                self.del(row)
            }
            
            return [action]
        }
        return []
    }
}

extension PreferencesViewController {
    func insert(_ projectInfo: ProjectInfoBean) {
        self.projectArr.append(projectInfo)
        self.table.reloadData()
        let count: Int = self.projectArr.count
        if count > 0 {
            self.table.selectRowIndexes(IndexSet.init(integer: count-1), byExtendingSelection: false)
        }
        Projects.save(projects: self.projectArr)
    }
    
    func del(_ row:Int) {
        self.projectArr.remove(at: row)
        self.table.removeRows(at: IndexSet.init(integer: row), withAnimation: NSTableView.AnimationOptions.slideLeft)
        Projects.save(projects: self.projectArr)
    }
}

