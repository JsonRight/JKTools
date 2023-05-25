//
//  JSONExtension.swift
//  JKTool
//
//  Created by 姜奎 on 2023/4/14.
//

import Foundation

extension String {
    static func toDictionary(string: String?) -> [String: Any] {
        guard let data = string?.data(using: .utf8) else {
            return [String: Any]()
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
            return [String: Any]()
        }
        return dict
    }
    
    static func toArray(string: String?) -> [Any] {
        guard let data = string?.data(using: .utf8) else {
            return [Any]()
        }
        
        guard let array = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any] else {
            return [Any]()
        }
        return array
    }
}

extension Dictionary {
    func toString() -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else {
            return ""
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }
}

extension Array {
    func toString() -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else {
            return ""
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }
}
