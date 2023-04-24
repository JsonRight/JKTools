//
//  Biz.swift
//  JKTool
//
//  Created by 姜奎 on 2023/4/17.
//

import Foundation
extension JKTool {
    
    struct HBBiz: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "biz",
            _superCommandName: "JKTool",
            abstract: "还呗特殊脚本", subcommands: [MPaaS.self,BBSec.self,Fir.self])
    }
}

extension JKTool.HBBiz {
    
    struct MPaaS: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "mpaas",
            _superCommandName: "biz",
            abstract: "MPaaS工程处理")
        
        @Option(name: .shortAndLong, help: "工程对应的Target")
        var target: String
        
        @Option(name: .shortAndLong, help: "代码环境[Debug、LBK_ENV_DEV、LBK_ENV_PRE、Release]，default：Debug")
        var configuration: String?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            guard project.rootProject == project else {
                
                return po(tip: "请在项目根目录执行脚本", type: .error)
                
            }
            
            func modeReflect(string: String?) -> String {
                if string == "Debug" {
                    return "SIT"
                }
                if string == "LBK_ENV_DEV" {
                    return "DEV"
                }
                if string == "LBK_ENV_PRE" {
                    return "PRE"
                }
                return "PROD"
            }
            
            
            do {
                po(tip: "开始更新配置")
                try shellOut(to: .copyFile(from: "\(project.buildsPath)/MPaaSPackage/\(target)/\(modeReflect(string: configuration))/meta.config", to: "\(project.directoryPath)/MPaaS/Targets/\(target)/meta.config"))
                try shellOut(to: .copyFile(from: "\(project.buildsPath)/MPaaSPackage/\(target)/\(modeReflect(string: configuration))/yw_1222.jpg", to: "\(project.directoryPath)/MPaaS/Targets/\(target)/yw_1222.jpg"))
                po(tip: "配置更新成功")
            } catch {
                let error = error as! ShellOutError
                po(tip: "配置更新失败\n" + error.message + error.output,type: .error)
            }
            
            po(tip: "清理workspace")
            _ = try? shellOut(to: .removeFolder(from: "\(project.buildsPath)/MPaaSPackage/workspace"))
            _ = try? shellOut(to: .createFolder(path: "\(project.buildsPath)/MPaaSPackage/workspace"))
            po(tip: "清理workspace成功")
            
            po(tip: "遍历amr列表")
            
            
            guard let fileList = FileManager.default.getFileList(directoryPath: "\(project.buildsPath)/MPaaSPackage/\(target)/\(modeReflect(string: configuration))") else {
                return po(tip: "【\(project.buildsPath)/MPaaSPackage/\(target)/\(modeReflect(string: configuration))】为空", type: .error)
            }
            
            var amr_path_list = [String]()
            
            for file in fileList {
                if file.isDirectory {
                    let amr_path = "\(project.buildsPath)/MPaaSPackage/workspace/\(file.name)"
                    amr_path_list.append(amr_path)
                    _ = try? shellOut(to: .copyFolder(from: file.path, to: amr_path))
                }
            }
            po(tip: "遍历amr列表完成")
            
            po(tip: "生成bizInfo和h5_json")
            var H5_JSON = [String: Any]()
            var BIZ_INFO = [String: Any]()
            var offline_h5json_info = [String: Any]()
            var offline_amr_info = [String: Any]()
            var amr_file_path_list = [FileManager.FileModel]()
            for amr_path in amr_path_list {
                guard let fileList = FileManager.default.getFileList(directoryPath: amr_path) else {
                    return po(tip: "【\(amr_path)】为空", type: .warning)
                }
                
                for var file in fileList {
                    if file.suffix == ".json" {
                        guard let json = try? Data(contentsOf: URL(fileURLWithPath: file.path)),let info = try? JSONSerialization.jsonObject(with: json, options: .mutableContainers) as? [String: Any] else {
                            return po(tip: "【\(file.path)】为空", type: .warning)
                        }
                        
                        let first = (info["data"] as! [Any]).first as? [String: Any] ?? [String: Any]()
                        if H5_JSON.isEmpty {
                            H5_JSON = info
                        } else {
                            var data = H5_JSON["data"] as? [Any] ?? [Any]()
                            data.append(first)
                            H5_JSON["data"] = data
                        }
                        offline_h5json_info[first["app_id"] as! String] = first["version"]
                    } else if file.suffix == ".amr" {
                        let amr_name = file.name.prefix(file.name.count - ".amr".count)
                        let amr_app_id = amr_name.components(separatedBy: "_").first
                        let amr_version = amr_name.components(separatedBy: "_").last
                        offline_amr_info[amr_app_id!] = amr_version
                        amr_file_path_list.append(file)
                        let zip_path = file.path.replacingOccurrences(of: ".amr", with: ".zip")
                        let unzip_path = file.path.replacingOccurrences(of: ".amr", with: "")
                        _ = try? shellOut(to: .copyFile(from: file.path, to: zip_path))
                        
                        
                        _ = try? Zip.unzipFile(URL(fileURLWithPath: zip_path), destination: URL(fileURLWithPath: unzip_path), overwrite: false, password: nil)
                        
                        guard let fileList = FileManager.default.getFileList(directoryPath: unzip_path) else {
                            return po(tip: "【\(unzip_path)】为空", type: .warning)
                        }
                        
                        for var file in fileList {
                            if file.suffix == ".tar" {
                                _ = try? shellOut(to: .createFolder(path: "\(unzip_path)/tar"))
                                do {
                                    try shellOut(to: ShellOutCommand(string: "tar -xvf \(file.path) -C \(unzip_path)/tar"))
                                } catch {
                                    let error = error as! ShellOutError
                                    po(tip: "配置更新失败\n" + error.message + error.output,type: .error)
                                }
                            }
                        }
                        
                        if amr_app_id != "99999999" || amr_app_id != "88888888" {
                            guard let fileList = FileManager.default.getFileList(directoryPath: "\(unzip_path)/tar") else {
                                return po(tip: "【\(unzip_path)/tar】为空", type: .warning)
                            }
                            var biz_info = [String: Any]()
                            for file in fileList {
                                if file.name == "hpmfile.json" {
                                    guard let json = try? Data(contentsOf: URL(fileURLWithPath: file.path)),let info = try? JSONSerialization.jsonObject(with: json, options: .mutableContainers) as? [String: Any] else {
                                        return po(tip: "【\(file.path)】为空", type: .warning)
                                    }
                                    biz_info["appInfo"] = [info["appid"] as! String: info["version"]]
                                } else if file.name == "moduleInfo.json" {
                                    guard let json = try? Data(contentsOf: URL(fileURLWithPath: file.path)),let info = try? JSONSerialization.jsonObject(with: json, options: .mutableContainers) as? [String: Any] else {
                                        return po(tip: "【\(file.path)】为空", type: .warning)
                                    }
                                    biz_info["moduleInfo"] = info
                                } else if file.name == "pageInfo.json" {
                                    guard let json = try? Data(contentsOf: URL(fileURLWithPath: file.path)),let info = try? JSONSerialization.jsonObject(with: json, options: .mutableContainers) as? [String: Any] else {
                                        return po(tip: "【\(file.path)】为空", type: .warning)
                                    }
                                    biz_info["pageInfo"] = info
                                }
                            }
                            BIZ_INFO[amr_app_id!] = biz_info
                        }
                    }
                }
                
            }
            
            for (app_id, version) in offline_h5json_info {
                let amr_version = offline_amr_info[app_id]
                if amr_version as! String != version as! String {
                    po(tip: "离线包h5_json与amr文件信息不匹配，请检查！！！",type: .error)
                }
            }
            
            if !H5_JSON.isEmpty {
                _ = try? H5_JSON.toString().write(toFile: "\(project.buildsPath)/MPaaSPackage/workspace/h5_json.json", atomically: true, encoding: .utf8)
            }
            
            if !BIZ_INFO.isEmpty {
                _ = try? BIZ_INFO.toString().write(toFile: "\(project.buildsPath)/MPaaSPackage/workspace/bizInfo.json", atomically: true, encoding: .utf8)
            }
            
            po(tip: "移动amr文件")
            for amr_file_path in amr_file_path_list {
                _ = try? shellOut(to: .copyFile(from: amr_file_path.path, to: "\(project.buildsPath)/MPaaSPackage/workspace/\(amr_file_path.name)"))
                _ = try? shellOut(to: .removeFolder(from: URL(fileURLWithPath: amr_file_path.path).deletingLastPathComponent().path))
            }
            
            po(tip: "生成bundle并替换")
            _ = try? shellOut(to: .removeFolder(from: "\(project.buildsPath)/MPaaSPackage/LBKMPaaSPackage.bundle"))
            
            _ = try? shellOut(to: .copyFolder(from: "\(project.buildsPath)/MPaaSPackage/workspace", to: "\(project.buildsPath)/MPaaSPackage/LBKMPaaSPackage.bundle"))
            
            po(tip: "生成bundle并替换完成")
        }
    }
    
    
}

extension JKTool.HBBiz {
    
    struct BBSec: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "bbsec",
            _superCommandName: "biz",
            abstract: "还呗特殊脚本,梆梆加固")
        
        @Option(name: .long, help: "设备类型，default：iOS")
        var sdk: String?
        
        @Option(name: .long, help: "sec版本")
        var secScriptPathName: String
        
        @Option(name: .long, help: "sec_config.xml路径，default：项目目录下sec_config.xml文件")
        var secConfigPath: String?
        
        @Option(name: .long, help: "sec_license.lic路径，default：项目目录下sec_license.lic文件")
        var secLicensePath: String?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            if !project.projectType.vaild() {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录下不是个正确的Xcode工程", type: .error)
            }
            
            let secConfigPath = secConfigPath ?? "\(project.directoryPath)/sec_config.xml"
            
            if !FileManager.default.fileExists(atPath: secConfigPath) {
                return po(tip: "\(secConfigPath)不存在！", type: .error)
            }
            
            let secLicensePath = secLicensePath ?? "\(project.directoryPath)/sec_license.lic"
            
            if !FileManager.default.fileExists(atPath: secLicensePath) {
                return po(tip: "\(secLicensePath)不存在！", type: .error)
            }
            
                        
            let sdk = sdk ?? "iOS"
            
            let scheme = ProjectListsModel.projectList(project: project)?.defaultScheme(sdk) ?? project.destination
            
            po(tip: "【\(scheme)】开始加固！")
            
            guard let sec_config = try? String(contentsOf: URL(fileURLWithPath: secConfigPath)) else {
                return po(tip: "\(secConfigPath)无法解析！", type: .error)
            }
            
            let config = sec_config.replacingOccurrences(of: "${SourceRoot}", with: project.directoryPath)
                .replacingOccurrences(of: "${XcodeProject}", with: "\(project.directoryPath)/\(project.projectType.entrance())")
                .replacingOccurrences(of: "${Scheme}", with: scheme)
            
            _ = try? config.data(using: .utf8)?.write(to: URL(fileURLWithPath: secConfigPath), options: .atomicWrite)
            
            
            _ = try? shellOut(to: ShellOutCommand(string: "./\(secScriptPathName)/tools/bclm -i \(secLicensePath)"),at: "~/Documents/SCShield")
            
            do {
                try shellOut(to: ShellOutCommand(string: "./\(secScriptPathName)/build_tools guider_v3 -i \(secConfigPath) --token offlinemode --online 0 --log-level DEBUG"),at: "~/Documents/SCShield")
            } catch {
                
                _ = try? sec_config.data(using: .utf8)?.write(to: URL(fileURLWithPath: secConfigPath), options: .atomicWrite)
                
                let error = error as! ShellOutError
                po(tip: "【\(scheme)】加固失败：\n" + error.message + error.output,type: .error)
            }
            
            _ = try? sec_config.data(using: .utf8)?.write(to: URL(fileURLWithPath: secConfigPath), options: .atomicWrite)
            
            
            po(tip: "【\(scheme)】加固完成！")
        }
    }
}

extension JKTool.HBBiz {
    
    struct Fir: ParsableCommand {
        
        static var configuration = CommandConfiguration(
            commandName: "fir",
            _superCommandName: "biz",
            abstract: "还呗特殊脚本,梆梆加固")
        
        @Option(name: .long, help: "设备类型，default：iOS")
        var sdk: String = "iOS"
        
        @Option(name: .shortAndLong, help: "导出环境，default：Release")
        var configuration: String = "Release"
        
        @Option(name: .long, help: "Scheme")
        var scheme: String
        
        @Option(name: .shortAndLong, help: "更新话术,默认：上传时间")
        var message: String?
        
        @Option(name: .shortAndLong, help: "执行路径")
        var path: String?
        
        mutating func run() {
            
            guard let project = Project.project(directoryPath: path ?? FileManager.default.currentDirectoryPath) else {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录不存在", type: .error)
            }
            
            if !project.projectType.vaild() {
                return po(tip: "\(path ?? FileManager.default.currentDirectoryPath)目录下不是个正确的Xcode工程", type: .error)
            }
            
            guard project.rootProject == project else {
                return po(tip: "请在项目根目录执行脚本", type: .error)
            }
            
            
            
            let message = message ?? ({
                //创建一个时间对象
                let today = Date()// 获取格林威治时间（GMT）/ 标准时间
                //获取当前时区
                let zone = NSTimeZone.system
                //获取当前时区和GMT的时间间隔
                let interval = zone.secondsFromGMT()
                //获取当前系统时间
                let now = today.addingTimeInterval(TimeInterval(interval))
                let dateformatter = DateFormatter()

                dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"// 自定义时间格式

                let time = dateformatter.string(from: now)
                return time
            })()
            
            do {
                try shellOut(to: ShellOutCommand(string: "fir publish \(project.buildPath)/\(configuration)/\(scheme).\(Platform(sdk).fileExtension()) -c \(message)"))
            } catch {
                let error = error as! ShellOutError
                po(tip: "【\(scheme)】fir上传失败：\n" + error.message + error.output,type: .error)
            }
            
            po(tip: "【\(scheme)】fir上传完成！")
        }
    }
}
