//
//  Json.swift
//  JKTool
//
//  Created by 姜奎 on 2023/4/14.
//

import Foundation


extension JKTool {
    
    struct ToolDictionary: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "dict",
            _superCommandName: "JKTool",
            abstract: "Dictionary处理，增删改查", subcommands: [DictionarySet.self, DictionaryGet.self])
    }
    
    struct ToolArray: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "array",
            _superCommandName: "JKTool",
            abstract: "Array处理，增删改查", subcommands: [ArraySet.self, ArrayGet.self])
    }
}

extension JKTool.ToolDictionary {
    
    struct DictionarySet: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "set",
            _superCommandName: "JKTool",
            abstract: "dict处理，增删改查")
        
        @Option(name: .shortAndLong, help: "dict")
        var dict: String?
        
        @Option(name: .shortAndLong, help: "key")
        var key: String
        
        @Option(name: .shortAndLong, help: "value")
        var value: String?
        
        @Option(name: .shortAndLong, help: "value类型：Dictionary、Array、String、Number，default：String")
        var type: String = "String"
        
        mutating func run() {
            
            var json = String.toDictionary(string: dict)
            
            switch type {
            case "Dictionary":
                if let value = value {
                    let val = String.toDictionary(string: value)
                    json[key] = val
                } else {
                    json[key] = nil
                }
                break
            case "Array":
                if let value = value {
                    let val = String.toArray(string: value)
                    json[key] = val
                } else {
                    json[key] = nil
                }
                break
            case "String":
                json[key] = value
                break
            case "Number":
                json[key] = value
                break
            default:
                json[key] = value
                break
            }
            po(tip: json.toString())
        }
    }
    
    struct DictionaryGet: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "get",
            _superCommandName: "JKTool",
            abstract: "dict处理，增删改查")
        
        @Option(name: .shortAndLong, help: "dict")
        var dict: String?
        
        @Option(name: .shortAndLong, help: "key")
        var key: String
        
        @Option(name: .shortAndLong, help: "value类型：Dictionary、Array、String、Number，default：String")
        var type: String = "String"
        
        mutating func run() {
            let json = String.toDictionary(string: dict)
            let value = json[key]
            switch type {
            case "Dictionary":
                if let value = value, let val = value as? [String: Any] {
                    po(tip: val.toString())
                } else {
                    po(tip: "Undefined")
                }
                break
            case "Array":
                if let value = value, let val = value as? [Any] {
                    po(tip: val.toString())
                } else {
                    po(tip: "Undefined")
                }
                break
            case "String":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined")
                }
                break
            case "Number":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined")
                }
                break
            default:
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined")
                }
                break
            }
        }
    }
    
}

extension JKTool.ToolArray {
    
    struct ArraySet: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "set",
            _superCommandName: "JKTool",
            abstract: "dict处理，增删改查")
        
        @Option(name: .shortAndLong, help: "array")
        var array: String?
        
        @Option(name: .shortAndLong, help: "index")
        var index: Int
        
        @Option(name: .shortAndLong, help: "value")
        var value: String?
        
        @Option(name: .shortAndLong, help: "value类型：Dictionary、Array、String、Number，default：String")
        var type: String = "String"
        
        mutating func run() {
            
            var json = String.toArray(string: array)
            
            switch type {
            case "Dictionary":
                if let value = value {
                    let val = String.toDictionary(string: value)
                    if index > json.count - 1 {
                        json.append(val)
                    }else{
                        json[index] = val
                    }
                } else {
                    json.remove(at: index)
                }
                break
            case "Array":
                if let value = value {
                    let val = String.toArray(string: value)
                    if index > json.count - 1 {
                        json.append(val)
                    }else{
                        json[index] = val
                    }
                } else {
                    json.remove(at: index)
                }
                break
            case "String":
                if let value = value {
                    if index > json.count - 1 {
                        json.append(value)
                    }else{
                        json[index] = value
                    }
                } else {
                    json.remove(at: index)
                }
                break
            case "Number":
                if let value = value {
                    if index > json.count - 1 {
                        json.append(value)
                    }else{
                        json[index] = value
                    }
                } else {
                    json.remove(at: index)
                }
                break
            default:
                if let value = value {
                    if index > json.count - 1 {
                        json.append(value)
                    }else{
                        json[index] = value
                    }
                } else {
                    json.remove(at: index)
                }
                break
            }
            po(tip: json.toString())
        }
    }
    
    struct ArrayGet: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "get",
            _superCommandName: "JKTool",
            abstract: "dict处理，增删改查")
        
        @Option(name: .shortAndLong, help: "array")
        var array: String?
        
        @Option(name: .shortAndLong, help: "index")
        var index: Int
        
        @Option(name: .shortAndLong, help: "value类型：Dictionary、Array、String、Number，default：String")
        var type: String = "String"
        
        mutating func run() {
            
            var json = String.toArray(string: array)
            guard index > json.count - 1 else {
                return po(tip: "Undefined")
            }
            let value = json[index]
            switch type {
            case "Dictionary":
                if let val = value as? [String: Any] {
                    po(tip: val.toString())
                } else {
                    po(tip: "Undefined")
                }
                break
            case "Array":
                if let val = value as? [Any] {
                    po(tip: val.toString())
                } else {
                    po(tip: "Undefined")
                }
                break
            case "String":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined")
                }
                break
            case "Number":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined")
                }
                break
            default:
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined")
                }
                break
            }
        }
    }
}
