//
//  ShellOutCommand.swift
//  JKTool
//
//  Created by 姜奎 on 2023/5/23.
//

import Foundation

/// Git commands
extension ShellOutCommand {
    /// Initialize a git repository
    static func gitInit() -> ShellOutCommand {
        return ShellOutCommand(string: "git init")
    }
    
    static func gitAdd() -> ShellOutCommand {
        return ShellOutCommand(string: "git add -A")
    }

    /// Clone a git repository at a given URL
    static func gitClone(url: URL, to path: String? = nil, branch: String? = nil) -> ShellOutCommand {
        return gitClone(url: url.absoluteString ,to: path, branch: branch)
    }
    
    /// Clone a git repository at a given URLString
    static func gitClone(url: String, to path: String? = nil, branch: String? = nil) -> ShellOutCommand {
        var command = "git clone \(url)"
        path.map { command.append(argument: $0) }
        command.append(" -b \(branch ?? "master")")

        return ShellOutCommand(string: command)
    }

    /// Create a git commit with a given message (also adds all untracked file to the index)
    static func gitCommit(message: String) -> ShellOutCommand {
        var command = "git commit -a -m"
        command.append(argument: message)

        return ShellOutCommand(string: command)
    }

    /// Perform a git push
    static func gitPush(branch: String? = nil) -> ShellOutCommand {
        var command = "git push --set-upstream origin"
        branch.map { command.append(argument: $0) }

        return ShellOutCommand(string: command)
    }

    /// Perform a git pull
    static func gitPull() -> ShellOutCommand {
        let command = "git pull origin"

        return ShellOutCommand(string: command)
    }
    
    /// Perform a git pull
    static func gitPrune() -> ShellOutCommand {
        let command = "git remote prune origin"
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git Rebase
    static func gitRebase(branch: String? = nil) -> ShellOutCommand {
        var command = "git rebase -i"
        branch.map { command.append(argument: $0) }

        return ShellOutCommand(string: command)
    }
    
    /// Perform a git merge
    static func gitMerge(branch: String, squash: Bool?, commit: Bool?, message: String?) -> ShellOutCommand {
        var command = "git merge \(branch)"
        
        if squash == true  {
            command.append(" --squash")
        } else {
            command.append(" --no-commit --no-ff")
        }
        
        if commit == true, let message = message {
            command.connected(andCommand: gitCommit(message: message).string)
        }
        
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git get current branch name
    static func gitCurrentBranch() -> ShellOutCommand {
        let command = "git branch --show-current"
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git create branch
    static func gitCreateBranch(branch: String) -> ShellOutCommand {
        let command = "git checkout -b \(branch)"
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git delete branch
    static func gitDelLocalBranch(branch: String? = nil) -> ShellOutCommand {
        var command = "git branch -d"
        branch.map { command.append(argument: $0) }
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git delete branch
    static func gitDelOriginBranch(branch: String? = nil) -> ShellOutCommand {
        var command = "git push origin -d"
        branch.map { command.append(argument: $0) }
        return ShellOutCommand(string: command)
    }
    
    /// Perform a git tag
    static func gitAddTag(tag: String) -> ShellOutCommand {
        var command = "git tag \(tag)"
        command.append(" && ")
        command.append("git push origin \(tag)")
        return ShellOutCommand(string: command)
    }
    
    /// del a git tag
    static func gitDelTag(tag: String) -> ShellOutCommand {
        var command = "git tag -d \(tag)"
        command.append(" && ")
        command.append("git push origin :refs/tags/\(tag)")
        return ShellOutCommand(string: command)
    }
    
    /// Run a git submodule update
    static func gitSubmoduleStatus() -> ShellOutCommand {
        let command = "git submodule status"
        return ShellOutCommand(string: command)
    }

    /// Run a git submodule update
    static func gitSubmoduleUpdate(remote: Bool, path: String) -> ShellOutCommand {
        var command = "git submodule update"
        if remote {
            command.append(" --remote")
        }
        command.append(argument: path)
        return ShellOutCommand(string: command)
    }
    
    /// Run a git submodule add
    static func gitSubmoduleAdd(name: String, url: String, path: String, branch: String? = nil) -> ShellOutCommand {
        let command = "git submodule add -b \(branch ?? "master") -f --name \(name) \(url) \(path)"
        return ShellOutCommand(string: command)
    }
    
    /// Run a git submodule add
    static func gitSubmoduleRemove(path: String) -> ShellOutCommand {
        let command = "git submodule deinit -f \(path) | rm -rf .git/modules/\(path) | git rm -f \(path)"
        return ShellOutCommand(string: command)
    }

    /// Checkout a given git branch
    static func gitCheckout(branch: String, force: Bool = false) -> ShellOutCommand {
        var command = "git switch \(branch) || git checkout"
        command.append(argument: branch)
        if force {
            command.append(" --force")
        }

        return ShellOutCommand(string: command)
    }
    
    /// Checkout a given git branch
    static func gitSwitch(branch: String) -> ShellOutCommand {
        let command = "git switch \(branch)"
        return ShellOutCommand(string: command)
    }
    
    /// Checkout a given git branch
    static func gitBranch(branch: String?) -> ShellOutCommand {
        
        var command = "git branch"
        if let branch = branch {
            command.append(" | grep \(branch)")
        }
        return ShellOutCommand(string: command)
    }
    
    
    static func gitStatus() -> ShellOutCommand {
        let command = "git status"
       return ShellOutCommand(string: command)
    }
    static func gitCurrentCommitId() -> ShellOutCommand {
        let command = "git rev-parse HEAD"
       return ShellOutCommand(string: command)
    }
    
    static func gitShortCurrentCommitId() -> ShellOutCommand {
        let command = "git rev-parse --short HEAD"
       return ShellOutCommand(string: command)
    }
    
    static func gitDiffHEAD() -> ShellOutCommand {
        let command = "git diff HEAD"
       return ShellOutCommand(string: command)
    }
    
    static func gitCodeReset() -> ShellOutCommand {
        let command = "git reset --hard HEAD"
       return ShellOutCommand(string: command)
    }

}
