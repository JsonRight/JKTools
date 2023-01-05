# JKTools的起源@_@

JKTools是为了实现项目模块化、插件化、快速编译产生的产物。如果你还在为以上目标发愁，可以试试，它的使用真的非常简单。完全符合命令行的操作规范。

#### JKTools的支持的功能

1、类似Carthage的模式，管理项目子模块，从而实现模块化、插件化。

2、支持模块间嵌套使用。

3、支持多种类型库的编译（Static、Framework、XCFramework、Bundle），支持自动识别库类型。

4、提供子模块集的git一键操作，支持git submodule管理方式。

5、提供子模块集的xcodebuild一键操作，build支持自定义脚本。

6、提供build产物按当前子模块编辑状态为节点的本地化缓存，缩减子模块集的编译时间。

7、支持一键打包上传功能。

8、支持自定义脚本在子模块集顺序执行。

#### JKTools的不支持的功能

1、仅作为项目私有化模块化管理，不能做代替Carthage、Pods使用。

2、暂不支持更高级的缓存模式，比如远程缓存。

3、暂不支持你可能需要，而JKTools没有的功能。

# JKTools组成

JKTools分为两大部分：JKTools程序、JKTool命令行工具。

#### JKTools管理程序（Beta版）

#### JKTools的安装

1. 将`JKTools.app`拖进Mac的应用程序，双击`JKTools[🐢]`，你会看到出现安装JKTool命令行工具的文件夹选择窗口。
2. 点击`Selecte Script Folder`他会将JKTool安装到对的目录，接下来会出现一个Alert，`Done`代表安装成功，`Fail`代表安装失败。
3. 你不需要过多操作，请相信我，JKTools是无害的，JKTool也很小。如果你没看到窗口，大概率这个窗口在其他Mac App的窗口后面，你会看到他的！

#### JKTools的能力

JKTools它仅提供`git忽略文件示例` `配置中心` `安装脚本` `帮助` `退出`以上5个基础功能。

注意：他并不需要持续运行。

1. `git忽略文件示例`内附带简单的Xcode工程几条个人认为务必要忽略的内容，仅供参考；
2. `配置中心` 内提供 JKTools格式的模块化管理工具需要配置的几个路径：SubModule相对于壳工程的统一路径、Build产物（.a、.framework、.bundle）相对于壳工程的统一路径、Build中间产物（缓存）相对于壳工程的统一路径；
3. `安装脚本`提供了在首次启动JKTools时安装JKTool命令行工具失败或者失误删除JKTool命令行工具时，手动安装JKTool的入口。
4. `帮助`这里很大概率看到的就是本文档了。
5. `退出`退出功能是有必要的，JKTools没有任何必要长期存在于进程中，它只是提供以上4个功能，在学会并安装使用本工具后，它只是一个没用的图标。

#### JKTool命令行工具（Beta版）

#### JKTool的安装

方式一：安装JKTools，并运行；将自动安装JKTool，并可以通过JKTools 远程更新公版JKTool。

方式二：下载JKTool，或者打开JKTools.dmg 将JKTool 拷贝到`/usr/**local**/bin`目录即可。

建议使用方式一（可持续获得最新公版JKTool）

#### JKTool的能力

JKTool是一个很简单的命令行工具。

#### 使用方法

1、在壳工程（宿主项目，以下统称为壳工程）所在目录下编写`Modulefile`文件：

```
文件夹名称 git地址 [初始引用branch/tag]
...
```

2、在壳工程目录下执行命令：`JKTool update`。

JKTool会自动检查`Modulefile`文件，以及壳工程`module/checkouts`目录，递归所有JKTool管理模式的子模块。

你可以使用`--force true` 强制重新Clone子模块，避免发生异常引用。

你可以使用`--path <path>`跳过进入壳工程目录步骤，自动在path路径下执行命令。

你可以使用`--submodule true`将子模块同时拉入git submodule的管理方案中，请注意：*仅支持加入git submodule，不支持自动移除*。

你还可以使用子命令`JKTool update init`将远程已经是JKTool管理的工程Clone到本地，并自动Clone子模块。

下面列出JKTool的命令集：*你可以通过`JKTool help <subcommand>` 查看他提供了哪些子命令*

```
JKTool
├─update
│		└─init
├─build
│		├─clean
│		├─static
│		├─framework
│		├─xcframework
│		└─other
├─export
├─upload
│		├─account
│		└─api
├─git
│		├─init
│		├─clone 
│		│		└─init
│		└─submodule
│ 	│		└─init
│		├─commit
│		├─pull
│		├─push
│		├─prune
│		├─merge
│		├─squash
│		├─branch
│		│		├─create
│		│		└─del
│		│			├─local
│		│			└─origin
│		├─checkout
│		├─status
│		└─tag
│				├─add
│				└─del
├─shell
└─config
```

# 模块化的应用<Modulefile>

下面通过JKTool目录环境默认的工程结构作为示例：

```
Notebook（壳工程）
├─.git
├─.gitgnore
├─.gitmodules
├─Notebook
├─Notebook.xcodeproj
├─Notebook.xcworkspace
├─Pods
├─podfile
├─Podfile.lock
├─Modulefile
├─Modulefile.recordList
└─Module
		├─Builds
		│		├─JKFoundation
		│		│		└─JKFoundation.framework
		│		├─JKUIKit
		│		│		├─JKUIKit.a
		│		│		├─JKUIKit.bundle
		│		│		└─JKUIKit
		│		│				└─...*.h
		│		├─JKCommon
		│		│		└─JKFoundation.framework
		│		├─...
		│		└─JKSwift
		│				└─JKFoundation.framework
		└─checkouts
				├─JKFoundation
				│		├─.git
				│		├─.gitgnore
				│		├─JKFoundation
				│		└─JKFoundation.xcodeproj
				├─JKUIKit
				│		├─.git
				│		├─.gitgnore
				│		├─.gitmodules
				│		├─JKUIKit
				│		├─JKUIKit.xcodeproj
				│		├─Modulefile
				│		├─Modulefile.recordList
				│		└─Module
				│				└─Builds
				│						└─JKFoundation (壳工程Module/Builds/JKFoundation 的links)
				├─JKCommon
				│		├─.git
				│		├─.gitgnore
				│		├─.gitmodules
				│		├─JKCommon
				│		├─JKCommon.xcodeproj
				│		├─Modulefile
				│		├─Modulefile.recordList
				│		└─Module
				│				└─Builds
				│						├─JKFoundation (壳工程Module/Builds/JKFoundation 的links)
				│						└─JKUIKit (壳工程Module/Builds/JKUIKit 的links)
				├─JKSwift
				│		├─.git
				│		├─.gitgnore
				│		├─.gitmodules
				│		├─JKSwift
				│		├─JKSwift.xcodeproj
				│		├─Modulefile
				│		├─Modulefile.recordList
				│		└─Module
				│				└─Builds
				│						├─JKFoundation (壳工程Module/Builds/JKFoundation 的links)
				│						├─JKUIKit (壳工程Module/Builds/JKUIKit 的links)
				│						└─JKCommon (壳工程Module/Builds/JKCommon 的links)
				└─...
```

以上依赖关系可以简化为：

```
Notebook <-- [JKSwift](JKSwift 对JKCommon,JKFoundation,JKUIKit存在隐性依赖)==>Notebook对JKSwift显性依赖
JKSwift <-- [JKCommon,JKUIKit,JKFoundation]==>JKSwift对JKCommon,JKUIKit,JKFoundation显性依赖
JKUIKit <-- [JKFoundation]==>JKUIKit对JKFoundation显性依赖
JKCommon <-- [JKFoundation]==>JKCommon对JKFoundation显性依赖
依赖关系通过 Modulefile 文件描述
```

Notebook 的 Modulefile示例：

```
JKSwift git@*/JKSwift.git master
```

JKSwift 的 Modulefile示例：

```
JKCommon git@*/JKCommon.git master
JKUIKit git@*/JKUIKit.git master
JKFoundation git@*/JKFoundation.git master
```

JKUIKit 的 Modulefile示例：

```
JKFoundation git@*/JKFoundation.git master
```

JKCommon 的 Modulefile示例：

```
JKFoundation git@*/JKFoundation.git master
```

Modulefile 单行分3个部分：

1. scheme 模块名称，建议工程名、scheme使用同一个，scheme将作为文件名称以及build命令的scheme使用
2. 子模块git仓库地址
3. 默认依赖分支/tag

*`Modulefile.recordList`为构建子模块依赖树的中间文件，决定了子模块build的执行顺序。可忽略，不可删除。*