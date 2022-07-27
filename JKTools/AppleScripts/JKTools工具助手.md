# JKTools的起源@_@

#### 简单介绍工程模块化

首先先介绍一下个人对于一个工程的简单的模块化拆分方案：

1. 将整个App纵向拆分为：`壳工程` `开源的常用基础库` `第三方私有库` `自家私有基础库` `基础组件库` `业务库`；
2. `自家私有基础库`横向拆分：`Foundation` `UIKit` `Common`;
3. `基础组件库`横向拆分：各种业务基础组件库;
4. `业务库`横向拆分：各种业务库。

通过`路由框架`作为桥梁，实现业务功能插件化。漂亮！！！

#### 工程模块化管理工具的挑选

我觉得大家应该都对Cocoapods、Carthage有充足的认知！这里就不过多介绍！

不管你用什么做管理工具，不知道你是否经历过：

1. 全工程`build`50minutes+

2. `.a`嵌套`.framework`嵌套`第三方sdk`

3. gitHub全天443

4. 切一下分支，又要`build`

5. what？只能拉锁定的tag，不能拉最新代码？

   ……我艹【一种🦙爱吃吃的草】

不想写space，不想443，不想重复build，于是我们走上自构建模块化管理工具的路——JKTools诞生了。

# JKTools组成

#### JKTools管理程序（Bate版）

JKTools并不需要持续运行，它仅提供`git忽略文件示例` `配置中心` `安装脚本` `帮助` `退出`以上5个基础功能。

1. `git忽略文件示例`内附带简单的Xcode工程几条个人认为务必要忽略的内容，仅供参考；
2. `配置中心` 内提供 JKTools格式的模块化管理工具需要配置的几个路径：SubModule相对于壳工程的统一路径、Build产物（.a、.framework、.bundle）相对于壳工程的统一路径、Build中间产物（缓存）相对于壳工程的统一路径；
3. `安装脚本`提供了在首次启动JKTools时安装JKTool命令行工具失败或者失误删除JKTool命令行工具时，手动安装JKTool的入口。
4. `帮助`这里很大概率看到的就是本文档了。
5. `退出`退出功能是有必要的，JKTools没有任何必要长期存在于进程中，它只是提供以上4个功能，在学会并安装使用本工具后，它只是一个没用的图标。

#### JKTools的安装

1. 将`JKTools.app`拖进Mac的应用程序，双击`JKTools[🐢]`，你会看到出现安装JKTool命令行工具的文件夹选择窗口。
2. 点击`Selecte Script Folder`他会将JKTool安装到对的目录，接下来会出现一个Alert，`Done`代表安装成功，`Fail`代表安装失败。
3. 你不需要过多操作，请相信我，JKTools是无害的，JKTool也很小。如果你没看到窗口，大概率这个窗口在其他Mac App的窗口后面，你会看到他的！

*我并不准备将这个工具完全开源，也不准备提交AppStore，毕竟它很简单，它能提供的能力很简单！*并且当前并不提供命令行动态更新服务。

#### JKTool命令行工具（Bate版）

JKTool是一个很简单的命令行工具，提供的命令也很简单：

*你可以通过`JKTool help <subcommand>` 查看他提供了哪些子命令*

```
JKTool
├─git
│	├─init //JKTool git init [<path>] 初始化一个git仓库
│	├─clone
│	│	├─sub //JKTool git clone sub [<force>] [<path>] clone全部submodule
│	│	└─all //JKTool git clone all <url> <path> [<branch>] clone壳工程以及全部
│	├─commit //JKTool git commit <message> [<recursive>] [<path>] 写入提交信息，自动执行git add -A
│	├─pull //JKTool git pull [<recursive>] [<path>] pull当前分支
│	├─push //JKTool git push [<branch>] [<recursive>] [<path>] push git仓库
│	├─prune //JKTool git prune [<recursive>] [<path>]
│	├─rebase //JKTool git rebase <branch>
│	├─merge //JKTool git merge <branch> [<squash>] [<recursive>] [<path>] 将当前分支merge到branch
│	├─squash //JKTool git squash <from> <to> <message> [<del>] [<recursive>] [<path>] squash分支
│	├─branch
│	│	├─create //JKTool git branch create <branch> [<recursive>] [<quiet>] [<path>] 创建分支
│	│	└─del
│	│		├─local //JKTool git branch del local <branch> [<recursive>] [<path>] 删除本地分支
│	│		└─origin //JKTool git branch del origin <branch> [<recursive>] [<path>] 删除远程分支
│	├─checkout //JKTool git checkout <branch> [<recursive>] [<force>] [<path>]
│	├─status //JKTool git status [<recursive>] [<path>]
│	├─tag
│	│	├─add //JKTool git tag add <tag> [<recursive>] [<path>] 添加tag
│	│	└─del //JKTool git tag del <tag> [<recursive>] [<path>] 移除tag
│	└─submodule
│	│	└─update
│	│		├─sub //JKTool git submodule update sub [<prune>] [<remote>] [<path>] 构建git submodule
│	│		└─all //JKTool git submodule update all <url> <path> [<remote>] [<branch>]  clone壳工程并构建git submodule
├─build
│	├─static //JKTool build static [<cache>] [<configuration>] [<sdk>] [<path>] 编译成.a
│	├─framework //JKTool build framework [<cache>] [<configuration>] [<sdk>] [<path>] 编译成.framework
│	├─xcframework //JKTool build xcframework [<cache>] [<configuration>] [<sdk>] [<path>] 编译成.xcframework
│	└─unknown //JKTool build unknown [<cache>] [<configuration>] [<sdk>] [<path>] 智能编译成.a或者.framework
├─archive //JKTool archive <configuration> <scheme> <config-path> [<export>] [<path>]
├─export //JKTool export <configuration> <scheme> <config-path> [<path>]
├─upload
│	├─account //JKTool upload account <config-path> [<path>]
│	├─api //JKTool upload api <config-path> [<path>]
│	└─export //JKTool upload export <config-path> [<path>]
├─shell //JKTool shell <shell> [<path>] //执行自定义脚本
└─config //JKTool config //获取archive/export/upload的config.json示例
```



*部分命令并没有解释，相信没有也能看得懂，以下是部分命令key的含义*:

1. *path*：String 命令执行路径，必须是绝对路径，非必填字段时为空则为当前路径
2. *force*：Bool 是否强制执行
3. *recursive*：Bool 是否递归子模块，使子模块执行同样的功能命令
4. *config-path*：String config.json的路径，可以是相对路径
5. *<...>* 代表必填字段、*[<...>]* 代表可选字段







