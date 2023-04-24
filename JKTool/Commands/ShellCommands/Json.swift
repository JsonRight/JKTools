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
            po(tip: json.toString(),type: .echo)
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
                    po(tip: "Undefined",type: .echo)
                }
                break
            case "Array":
                if let value = value, let val = value as? [Any] {
                    po(tip: val.toString())
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            case "String":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            case "Number":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            default:
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined",type: .echo)
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
        var index: Int?
        
        @Option(name: .shortAndLong, help: "value")
        var value: String?
        
        @Option(name: .shortAndLong, help: "value类型：Dictionary、Array、String、Number，default：String")
        var type: String = "String"
        
        mutating func run() {
            
            var json = String.toArray(string: array)
            
            switch type {
            case "Dictionary":
                if let index = index, index < json.count {
                    if let value = value {
                        let val = String.toDictionary(string: value)
                        json[index] = val
                    } else {
                        json.remove(at: index)
                    }
                }else{
                    if let value = value {
                        let val = String.toDictionary(string: value)
                        json.append(val)
                    }
                }
                break
            case "Array":
                if let index = index, index < json.count {
                    if let value = value {
                        let val = String.toArray(string: value)
                        json[index] = val
                    } else {
                        json.remove(at: index)
                    }
                }else{
                    if let value = value {
                        let val = String.toDictionary(string: value)
                        json.append(val)
                    }
                }
                break
            case "String":
                if let index = index, index < json.count {
                    if let value = value {
                        json[index] = value
                    } else {
                        json.remove(at: index)
                    }
                }else{
                    if let value = value {
                        json.append(value)
                    }
                }
                break
            case "Number":
                if let index = index, index < json.count {
                    if let value = value {
                        json[index] = value
                    } else {
                        json.remove(at: index)
                    }
                }else{
                    if let value = value {
                        json.append(value)
                    }
                }
                break
            default:
                if let index = index, index < json.count {
                    if let value = value {
                        json[index] = value
                    } else {
                        json.remove(at: index)
                    }
                }else{
                    if let value = value {
                        json.append(value)
                    }
                }
                break
            }
            po(tip: json.toString(),type: .echo)
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
                return po(tip: "Undefined",type: .echo)
            }
            let value = json[index]
            switch type {
            case "Dictionary":
                if let val = value as? [String: Any] {
                    po(tip: val.toString(),type: .echo)
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            case "Array":
                if let val = value as? [Any] {
                    po(tip: val.toString(),type: .echo)
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            case "String":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            case "Number":
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            default:
                if let value = value as? String {
                    po(tip: value)
                } else {
                    po(tip: "Undefined",type: .echo)
                }
                break
            }
        }
    }
}
