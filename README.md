### iOS 客户端接入 Flutter 实践

### 目录
* 介绍
* 搭建 Flutter-iOS 开发环境
* iOS现有项目接入flutter
* 改造iOS工程
* 运行进行测试
* 相关文档

#### 一、介绍
Flutter是一款移动应用程序SDK，一份代码可以同时生成iOS和Android两个高性能、高保真的应用程序。

Flutter目标是使开发人员能够交付在不同平台上都感觉自然流畅的高性能应用程序。

目前使用Flutter的APP并不算很多，相关资料并不丰富，介绍现有工程引入Flutter的相关文章也比较少。

![](./1541640512455.png)


##### Flutter架构
![](./1541830962432.png)


#### 二、搭建 Flutter-iOS 开发环境

#### 1. 获取 Flutter 工程
* 克隆 Flutter 到本地
* sudo git clone -b beta https://github.com/flutter/flutter.git $HOME/flutter

#### 2. 配置 Flutter 环境变量
#### （1）说明
* 由于在国内访问Flutter有时可能会受到限制，Flutter官方为中国开发者搭建了临时镜像，可以把镜像地址添加到环境变量中。
-
* 为了方便后续使用，需要将项目根目录下bin路径加入环境变量PATH中，打开~/.bash_profile文件，修改环境变量即可。

#### （2）添加环境变量（确保路径指向没问题）
* 执行命令 `open ~/.bash_profile` 在底部添加环境变量。
![](./1541681506456.png)

```
export PATH=$HOME/flutter/bin:$PATH
export FLUTTER_ROOT=$HOME/flutter

export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```
* 然后生效环境变量，终端 执行 `source ~/.bash_profile`

#### （3）注意
* 如果你使用的是zsh，终端启动时 ~/.bash_profile 将不会被加载，解决办法就是修改 ~/.zshrc ，在其中添加：source ~/.bash_profile，执行命令 `open ～/.zshrc`，底部添加如下：
![](./1541681031279.png)
```
source ~/.bash_profile
```

#### 3. 配置基本环境依赖
```
brew install --HEAD libimobiledevice
brew install ideviceinstaller ios-deploy cocoapods
```

#### 4. flutter doctor 检测本机环境
##### 1. 说明
* 因为flutter依赖的东西比较多，如果我们想要保证flutter环境没问题，需要执行 flutter doctor 检测确保当前环境。
* 在终端中执行 `flutter doctor` 命令，如下图：
![](./1541649211874.png)

##### 2. flutter doctor 检查失败原因
* flutter doctor 检测失败的原因会有很多，例如以下
* 没有安装 Android Studio。
* Android Studio 配置有问题。
* Android Studio 没有安装Flutter插件。
* 没有安装Xcode，或Xcode版本过低。
* 没有安装CocoaPods
* 没有安装 libimobiledevice
* 没有安装 ideviceinstaller
* 没有安装 ios-deploy
* 一步一步按照提示进行修复问题
* 安装或修改需要的地方，直到 flutter doctor 没有错误提示为止。

##### 3. 安卓SDK相关环境变量设置 
* 这是作者本机的环境变量，如果遇到问题，可对比一下区别。
```
# android sdk目录，替换为你自己的即可。
export ANDROID_HOME="/Users/用户名/Documents/android_sdk" 
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools
```

#### 三、iOS现有项目接入flutter
##### （1）说明
* Flutter的工程结构比较特殊，由Flutter目录再分别包含Native工程的目录（即 iOS 和Android 两个目录）组成。
-
* 默认情况下，引入了 Flutter 的 Native 工程无法脱离父目录进行独立构建和运行，因为它会反向依赖于 Flutter 相关的库和资源。
-
* 如果已经现有工程，那么我们需要在同级目录创建flutter模块。

##### （2）创建Flutter模块
* 假设当前工程是 Flutter_iOS ，那么 cd到项目同级目录，执行flutter命令创建。
```
cd /Users/sen/Desktop/Flutter工程/Flutter_iOS
flutter create -t module flutter_library
```
![](./1541754860478.png)

##### （3）创建iOS项目的 Config 文件
![](./1541818809834.png) 
* Config文件（管理Xcode工程的配置衔接文件） 里面包含分别创建 `Flutter.xcconfig`、`Debug.xcconfig`、`Release.xcconfig` 三个配置文件。
-
* 其中 `Flutter.xcconfig` 是指向外目录 flutter module 的 `Generated.xcconfig` 文件路径引用文件，其他两个代表Xcode的环境配置文件。

#####（4）Config 文件 内容
* Flutter.xcconfig 内容 
```
#include "../flutter_library/.ios/Flutter/Generated.xcconfig"
ENABLE_BITCODE=NO
```

* Debug.xcconfig 内容 （对应的名字换成自己）
```
#include "Flutter.xcconfig"

// 如果使用了Cocoapods，那么需要引入 cocoapods 的config文件，因为如果自定义了config，那么cocoapods 的 config 就不会自动指定了。
#include "Pods/Target Support Files/Pods-Flutter_iOS/Pods-Flutter_iOS.debug.xcconfig"
```

* Release.xcconfig 内容（对应的名字换成自己）
```
#include "Flutter.xcconfig"
FLUTTER_BUILD_MODE=release

// 如果使用了Cocoapods，那么需要引入 cocoapods 的config文件，因为如果自定义了config，那么cocoapods 的 config 就不会自动指定了。
#include "Pods/Target Support Files/Pods-Flutter_iOS/Pods-Flutter_iOS.release.xcconfig"
```

#####（4）项目中指定使用 config 
* 指定 config 文件，Debug 对应 Debug，Release 对应 Release
![](./1541755881901.png)

#####（5）设置 Flutter 的脚本 
* 在 Run Script 中增加：
![](./1541823330458.png)
```
"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build
```


#####（6）修改Flutter脚本
* 默认自己的Xcode Run Script编译好的framework并不在项目中，而在你创建flutter module文件夹下。
* 代码中有判断，进行生成的目录，需要注释代码让其生成在当前项目目录。
* 终端执行命令
* `open $FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh`
* 注释代码
* ![](./1541678204072.png)
```
local derived_dir="${SOURCE_ROOT}/Flutter"
#  if [[ -e "${project_path}/.ios" ]]; then
#    derived_dir="${project_path}/.ios/Flutter"
#  fi
RunCommand mkdir -p -- "$derived_dir"
AssertExists "$derived_dir"
```
* 配置好，Cmd+B，Build工程编译后，会生成Flutter 编译产物在项目目录下。
![Alt text](./1541822004869.png)

#####（7）引入Flutter编译产物

* 把编译产物，拖入项目中
![Alt text](./1541822088511.png)

* 注意：`flutter_assets` 并不能使用 `Create groups` 的方式添加，只能使用 `Creat folder references `的方式添加进Xcode项目内，否则跳转flutter会页面渲染失败（页面空白）。需要先删除引用。
![](./1541822138691.png)

* 然后 文件夹再Add Files to 'xxx'，选择Creat folder references
![](./1541822183840.png)

* 最终如下图
![](./1541822210108.png)

* 然后还需要添加文件夹下的两个framework添加到Embeded Binaries里。
![](./1541822314935.png)

#### 四、改造iOS工程
##### （1）AppDelegate.h 改造
* 使其继承 FlutterAppDelegate 。
* 删除 @property (strong, nonatomic) UIWindow *window; ，因为集成的delegate里面已经有了。
```
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

@interface AppDelegate : FlutterAppDelegate <UIApplicationDelegate, FlutterAppLifeCycleProvider>

@end
```

##### （2）AppDelegate.m 改造
* 改造AppDelegate.m，转发代理消息。
* 把使用到的代理，都改为以下方式，使用_lifeCycleDelegate调用传递一次。
```
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
FlutterPluginAppLifeCycleDelegate *_lifeCycleDelegate;
}

- (instancetype)init {
if (self = [super init]) {
_lifeCycleDelegate = [[FlutterPluginAppLifeCycleDelegate alloc] init];
}
return self;
}

- (BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
return [_lifeCycleDelegate application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
[_lifeCycleDelegate applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
[_lifeCycleDelegate applicationWillEnterForeground:application];
}

- (void)applicationWillResignActive:(UIApplication*)application {
[_lifeCycleDelegate applicationWillResignActive:application];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
[_lifeCycleDelegate applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication*)application {
[_lifeCycleDelegate applicationWillTerminate:application];
}

- (void)application:(UIApplication*)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings {
[_lifeCycleDelegate application:application
didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication*)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
[_lifeCycleDelegate application:application
didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application
didReceiveRemoteNotification:(NSDictionary*)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
[_lifeCycleDelegate application:application
didReceiveRemoteNotification:userInfo
fetchCompletionHandler:completionHandler];
}

- (BOOL)application:(UIApplication*)application
openURL:(NSURL*)url
options:(NSDictionary<UIApplicationOpenURLOptionsKey, id>*)options {
return [_lifeCycleDelegate application:application openURL:url options:options];
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
return [_lifeCycleDelegate application:application handleOpenURL:url];
}

- (BOOL)application:(UIApplication*)application
openURL:(NSURL*)url
sourceApplication:(NSString*)sourceApplication
annotation:(id)annotation {
return [_lifeCycleDelegate application:application
openURL:url
sourceApplication:sourceApplication
annotation:annotation];
}

- (void)application:(UIApplication*)application
performActionForShortcutItem:(UIApplicationShortcutItem*)shortcutItem
completionHandler:(void (^)(BOOL succeeded))completionHandler NS_AVAILABLE_IOS(9_0) {
[_lifeCycleDelegate application:application
performActionForShortcutItem:shortcutItem
completionHandler:completionHandler];
}

- (void)application:(UIApplication*)application
handleEventsForBackgroundURLSession:(nonnull NSString*)identifier
completionHandler:(nonnull void (^)(void))completionHandler {
[_lifeCycleDelegate application:application
handleEventsForBackgroundURLSession:identifier
completionHandler:completionHandler];
}

- (void)application:(UIApplication*)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
[_lifeCycleDelegate application:application performFetchWithCompletionHandler:completionHandler];
}

- (void)addApplicationLifeCycleDelegate:(NSObject<FlutterPlugin>*)delegate {
[_lifeCycleDelegate addDelegate:delegate];
}

#pragma mark - Flutter
// Returns the key window's rootViewController, if it's a FlutterViewController.
// Otherwise, returns nil.
- (FlutterViewController*)rootFlutterViewController {
UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
if ([viewController isKindOfClass:[FlutterViewController class]]) {
return (FlutterViewController*)viewController;
}
return nil;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
[super touchesBegan:touches withEvent:event];

// Pass status bar taps to key window Flutter rootViewController.
if (self.rootFlutterViewController != nil) {
[self.rootFlutterViewController handleStatusBarTouches:event];
}
}
@end
```

##### （3）主工程调用Flutter 进行测试
```
#import "ViewController.h"
#import <Flutter/FlutterViewController.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
[super viewDidLoad];
// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
FlutterViewController* flutterViewController = [[FlutterViewController alloc] initWithProject:nil nibName:nil bundle:nil];
flutterViewController.navigationItem.title = @"Flutter Demo";

[self presentViewController:flutterViewController animated:YES completion:nil];
}
@end
```

#### 四、运行进行测试
#####（1）使用 Android Studio 打开 Flutter 模块
* 选择main.dart，flutter代码主文件，在终端中进行 flutter attact 等待连接。
![](./1541823592174.png)

#####（2）运行iOS工程。
* flutter attact后，改变flutter代码，然后输入R 可进行刷新重载。
![](./flutter连接.gif)

#### 五、相关文章
* Flutter论坛：http://flutter-dev.cn/
* Flutter中文网：https://flutterchina.club/get-started/install/
* Flutter混编：https://github.com/flutter/flutter/wiki/Add-Flutter-to-existing-apps
* Flutter - io：https://flutter-io.cn/#section-keynotes
* Flutter混合开发篇：https://www.jianshu.com/p/d9b1290e9e28
* Flutter笔记：https://www.jianshu.com/p/78fa581fb538
* Flutter掘金：https://juejin.im/tag/Flutter?utm_source=flutterchina&utm_medium=word&utm_content=btn&utm_campaign=q3_website
* Flutter系列教程：http://flutter-dev.cn/topic/12/flutter%E4%BB%8E%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA%E5%88%B0%E8%BF%9B%E9%98%B6%E7%B3%BB%E5%88%97%E6%95%99%E7%A8%8B
