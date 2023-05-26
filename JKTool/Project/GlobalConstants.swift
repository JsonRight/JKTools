//
//  GlobalConstants.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/24.
//

import Foundation

enum PatternEnum: String {
    case StaticPath = "Libtool (.*?)\\.a"
    case StaticHeadersPath = "Copy (.*?)\\.h"
    case FrameworkPath = "Libtool (.*?)\\.framework"
    case BundlePath = "MkDir (.*?)\\.bundle"
    
    func path(_ result: String?) -> String? {
        guard let result = result, let raw = result.regular(self.rawValue) else { return nil }
        switch self {
        case .StaticPath:
            guard let path = raw.split(separator: " ").last else { return nil }
            return String(path)
        case .StaticHeadersPath:
            guard let path = raw.split(separator: " ").last else { return nil }
            return URL(fileURLWithPath: "\(path)").deletingLastPathComponent().path
        case .FrameworkPath:
            guard let path = raw.split(separator: " ").last else { return nil }
            return String(path)
        case .BundlePath:
            return raw.components(separatedBy: " ")[1]
        }
    }
}

struct GlobalConstants {
    
    static var xcodeVersion: String? = {
        var xcodeVersion = try? shellOut(to: .xcodeVersion())
            xcodeVersion = String.safe(xcodeVersion).replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "\n", with: "-")
        return xcodeVersion
    }()
    
    static func buildPath(_ result: String?) -> String? {
        guard let result = result, let raw = result.regular("Build description path: (.*?)/XCBuildData") else { return nil }
        return raw
    }
    
    static func durationFormat(_ duration: TimeInterval) ->String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let timeString = formatter.string(from: duration)
        return timeString ?? "00:00:00"
    }
    
    static func duration(to history: TimeInterval) ->String {
        return durationFormat(Date.init().timeIntervalSince1970 - history)
    }
    
    private init() {}
}
