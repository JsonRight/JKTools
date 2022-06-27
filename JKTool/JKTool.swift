//
//  JKTool.swift
//  JKTool
//
//  Created by 姜奎 on 2021/4/25.
//

import Darwin


struct JKTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "JKTool",
        abstract: "JKTool",
        version: "1.0.0",
        subcommands: [Build.self,Git.self,Archive.self],
        defaultSubcommand: Build.self)
    
//   static func run(arguments: [String])  {
//        var argumentExtion = arguments
//        argumentExtion.removeFirst()
//        if argumentExtion.first == "clone" {
//            CloneCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "clone_project" {
//            CloneProjectCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "pull" {
//            PullCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "pull_all" {
//            PullAllCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "prune" {
//            PruneCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "prune_all" {
//            PruneAllCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "add_tag" {
//            AddTagCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "del_tag" {
//            DeleteTagCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "build" {
//            BuildCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "buildFramework" {
//            BuildFrameworkCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "buildXCFramework" {
//            BuildXCFrameworkCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "buildStatic" {
//            BuildStaticCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "archive" {
//            ArchiveCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        }  else if argumentExtion.first == "upload" {
//            UploadCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else if argumentExtion.first == "one_key_upload" {
//            OneKeyUploadCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        } else {
//            HelperCommon().run(options: ConsoleOptions(arguments: argumentExtion))
//        }
//    }
}
