//
//  HelperViewController.swift
//  JKTools
//
//  Created by 姜奎 on 2022/11/10.
//

import Cocoa

class HelperViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    
    lazy var indicator: NSProgressIndicator = {
        var indicator = NSProgressIndicator()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .bar
        indicator.isDisplayedWhenStopped = true
        indicator.usesThreadedAnimation = true
        indicator.isIndeterminate = true
        self.view.addSubview(indicator)
        indicator.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        indicator.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        indicator.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
//        self.updateHelpMD()
//        self.download()
    }
    
    func download() {
        self.startAnimation()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let request = URLRequest(url: URL(string: "https://gitee.com/jk14138/JKTools/releases/download/JKTools-md/JKTools工具助手.md".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        //
        let downloadTask = session.downloadTask(with: request) { location, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                self.stopAnimation()
                return
            }
            guard let locationPath = location?.path else {
                self.stopAnimation()
                return
            }
            let document = FileManager.DocumnetsDirectory() + "/JKTools工具助手.md"
            
            try? FileManager.default.moveItem(atPath: locationPath, toPath: document)
            self.updateHelpMD()
            self.stopAnimation()
        }
        downloadTask.resume()
    }
    
    func updateHelpMD() {
        let filePath: String
        
        let document = FileManager.DocumnetsDirectory() + "/JKTools工具助手.md"
        
        if FileManager.default.fileExists(atPath: document) {
            filePath = document
        } else {
            guard let path = Bundle.main.path(forResource: "JKTools工具助手", ofType: "md") else {
                Alert.alert(message: "Fail")
                return
            }
            filePath = path
        }

        guard let md = try? String(contentsOf: URL(fileURLWithPath: filePath)) else {
            return
        }
        
        guard let attributedString = try? NSAttributedString(markdown: md) else {
            return
        }
        
        DispatchQueue.main.async {
            self.textView.textStorage?.append(attributedString)
        }
    }
    
    func startAnimation(){
        DispatchQueue.main.async {
            self.indicator.startAnimation(nil)
        }
    }
    
    func stopAnimation(){
        DispatchQueue.main.async {
            self.indicator.stopAnimation(nil)
            self.indicator.isHidden = true
        }//
    }
}
