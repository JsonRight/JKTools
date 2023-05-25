//
//  ModulesConfig.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

public class ModulesConfigs {
    
    struct Config: Decodable {
        var checkouts: String = "Module/checkouts"
        var builds: String = "Module/Builds"
        var build: String = "build"
        var toolUrl: String = "https://gitee.com/jk14138/JKTools/releases/download/JKTool/JKTool"
        var completionUrl: String = "https://gitee.com/jk14138/JKTools/releases/download/JKTool-completion/JKTool-completion"
    }
    
    var config: Config
    
    static let sharedInstance = ModulesConfigs()
    private init() {
        let url = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Containers/com.jk.JKTool/Data/Documents/config.json")
        if let data = try? Data(contentsOf: url),let config = try? JSONDecoder().decode(Config.self, from: data) {
            self.config = config
        } else {
            self.config = Config()
        }
    }
}
