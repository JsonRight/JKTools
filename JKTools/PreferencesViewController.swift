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
    
    weak var projectsTable: NSTableView!
    lazy var projectsAdapter = ProjectsAdapter(self.projectsTable, projects: projectArr)
    
    weak var subModuleTable: NSTableView!
    
    lazy var subModuleAdapter = ProjectsAdapter(self.subModuleTable, projects: projectArr)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // https://www.jianshu.com/p/4ce99b9dfb93?u_atoken=82757054-8ef4-4b37-9914-b5c890f0d852&u_asession=01q0nNJxj-v6IEkxWnvLoifPtDSO3UekYqBhzUqHRdVtsZ2I744ZgwtFJ-FqzWdA22X0KNBwm7Lovlpxjd_P_q4JsKWYrT3W_NKPr8w6oU7K9SbC9sS88GXK72H5ViKdrpnHmbkqVcEgdObpAroqY1_GBkFo3NEHBv0PZUm6pbxQU&u_asig=05AgoYYQl0cTU7bxDlYhq3QZlFn6W2QbSu9OIitL2jFPh4SKBbI2QqzuJgViHItuUqhN3jT7CVafX8S0jcM8r2i_RgA-EG5fYyh2JjwtD9lZYj2QZNJiWG9HmezzlPtosRYlLQevZq2QmzleyVyTyrA5ryYIts-YHS3V8FRJvUYr_9JS7q8ZD7Xtz2Ly-b0kmuyAKRFSVJkkdwVUnyHAIJzewyfIaOzmYeIfxrc8T9w3ltv0qcmFfc9y0A4MgCLln76xbSxAaWh9ph0bRUFW-6vO3h9VXwMyh6PgyDIVSG1W-LJON7ToHm0ldapH27jep9vDDbFVJYdBKb20HLpJxMYrwtnUZJSAwj4H-lQ5LymNtSzYl0dssjOGvjOH1AZVa7mWspDxyAEEo4kbsryBKb9Q&u_aref=pGVledrlqcfIQu8%2BUleAUGG95Ss%3D
        
    
        
        func createProjectsTable(){
            let scroll = NSScrollView()
            self.view.addSubview(scroll)
            scroll.hasVerticalRuler = true
            scroll.hasVerticalScroller = true
            scroll.translatesAutoresizingMaskIntoConstraints = false
            let scrollLead = scroll.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
            let scrollWidth = scroll.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5)
            let scrollTop = scroll.topAnchor.constraint(equalTo: self.view.topAnchor)
            let scrollBottom = scroll.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            self.view.addConstraints([scrollLead,scrollWidth,scrollTop,scrollBottom])
            scroll.wantsLayer = true
            scroll.layer?.backgroundColor = NSColor.red.cgColor
            
            let table = NSTableView() //是否设置尺寸无所谓——下方放置到ScrollView的documentView中
            scroll.addSubview(table)
            self.projectsTable = table
            scroll.contentView.documentView = table //不能添加约束——否则尺寸不能调整（宽不能调整）
//
            table.wantsLayer = true
            table.layer?.backgroundColor = NSColor.cyan.cgColor
            table.delegate = self.projectsAdapter
            table.dataSource = self.projectsAdapter
            table.target = self.projectsAdapter
            
            //添加列（必须）
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Projects"))
            column.title = "Projects"
            column.headerToolTip = column.title
            column.resizingMask = .autoresizingMask
            table.addTableColumn(column)
            let nib = NSNib(nibNamed: "PreferencesCellView", bundle: nil)
            table.register(nib, forIdentifier: NSUserInterfaceItemIdentifier("PreferencesCell"))
        }
        
        func createSubModuleTable(){
            
            let scroll = NSScrollView()
            self.view.addSubview(scroll)
            scroll.hasVerticalRuler = true
            scroll.hasVerticalScroller = true
            scroll.translatesAutoresizingMaskIntoConstraints = false
            let scrollTrail = scroll.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            let scrollWidth = scroll.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5)
            let scrollTop = scroll.topAnchor.constraint(equalTo: self.view.topAnchor)
            let scrollBottom = scroll.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            self.view.addConstraints([scrollTrail,scrollWidth,scrollTop,scrollBottom])
            scroll.wantsLayer = true
            scroll.layer?.backgroundColor = NSColor.red.cgColor
            
            let table = NSTableView() //是否设置尺寸无所谓——下方放置到ScrollView的documentView中
            scroll.addSubview(table)
            self.subModuleTable = table
            scroll.contentView.documentView = table //不能添加约束——否则尺寸不能调整（宽不能调整）
            table.wantsLayer = true
            table.layer?.backgroundColor = NSColor.cyan.cgColor
            
            table.delegate = self.subModuleAdapter
            table.dataSource = self.subModuleAdapter
            table.target = self.subModuleAdapter
            
            //添加列（必须）
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("SubModule"))
            column.title = "SubModule"
            column.headerToolTip = column.title
            column.resizingMask = .autoresizingMask
            table.addTableColumn(column)
            let nib = NSNib(nibNamed: "PreferencesCellView", bundle: nil)
            table.register(nib, forIdentifier: NSUserInterfaceItemIdentifier("PreferencesCell"))
        }
        
        createProjectsTable()
        createSubModuleTable()
    }
    
}


    
class ProjectsAdapter: NSObject,NSTableViewDelegate,NSTableViewDataSource {
    
    var table: NSTableView!
    
    var projectArr: [ProjectInfoBean]!
    
    init(_ table: NSTableView, projects: [ProjectInfoBean]) {
        self.table = table
        self.projectArr = projects
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
        return self.projectArr.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("PreferencesCell"), owner: self) as! PreferencesCellView
        cell.projectInfo = self.projectArr[row]
        return cell

    }
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {//可进行编辑
        return true
    }
    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {//鼠标悬停在cell上显示的提示文本
        return "tip\n大厦等级拉丝机\n的撒酒疯拉萨附近阿里附近阿拉斯加阿克苏交电费卡拉时间反馈时间的考虑"
    }
    func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {//当列表长度无法展示完整某行数据时 当鼠标悬停在此行上 是否扩展显示
        return true
    }
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print("tableColumn.title", tableColumn.title)
        
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        print("row:", row)
        
        return true
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

class SubModuleAdapter: NSObject,NSTableViewDelegate,NSTableViewDataSource {
    
    var table: NSTableView!
    
    var projectArr: [ProjectInfoBean]!
    
    init(_ table: NSTableView, projects: [ProjectInfoBean]) {
        self.table = table
        self.projectArr = projects
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
        return self.projectArr.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("PreferencesCell"), owner: self) as! PreferencesCellView
        cell.projectInfo = self.projectArr[row]
        return cell
    }
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {//可进行编辑
        return true
    }
    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {//鼠标悬停在cell上显示的提示文本
        return "tip\n大厦等级拉丝机\n的撒酒疯拉萨附近阿里附近阿拉斯加阿克苏交电费卡拉时间反馈时间的考虑"
    }
    func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {//当列表长度无法展示完整某行数据时 当鼠标悬停在此行上 是否扩展显示
        return true
    }
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print("tableColumn.title", tableColumn.title)
        
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        print("row:", row)
        
        return true
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

extension ProjectsAdapter {
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

extension SubModuleAdapter {
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

