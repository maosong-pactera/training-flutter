# Flutter 骨架

为了开发标准化简化管理、降低入门难度，专门定制了一套开发架构，也可以称为脚手架。以 Flutter + BLoC(RxDart) + SQLite 为基础，规范了文件夹结构、网络请求、数据库、状态管理、视图之间的数据流转方式。

[点击下载 Flutter 骨架源码](#)

!> 本文档编写时正处于Flutter培训课程 `第1课` 的制作末期，因此某些特性的文档会在 `之后课程` 中补齐。

## 文件夹结构

- YOUR-APP-FLODER/
  - android/ - Android项目
  - assets/ - 资源
  - ios/ - iOS项目
  - lib/ - Flutter核心代码
    - [core/](#APP启动) - APP启动
      - app.dart - 初始化
      - app_component.dart - Widget容器
      - error_handler.dart - 全局错误处理
    - [bloc/](#BLoC(RxDart)) - 状态管理
      - 功能名称/
        - 功能名称_页面名称_bloc.dart
      - bloc_base.dart - 所有BLoC的基础类
      - [bloc_provider.dart](#BlocProvider) - Bloc供应商
    - config/
      - color_define.dart - 颜色定义
      - icon_font.dart - 文字图标
      - [lang_define.dart](#语言包) - 语言包
      - [routes.dart](#路由) - 路由配置
    - [model/](#数据模型) - 数据模型
      - [db/](#数据库模型) - 数据库模型
        - db_model.dart - 数据库模型的基础类
      - [item/](#数据结构定义) - 数据结构定义
    - utility/
      - [db/](#数据库工具) - 数据库工具
        - database_helper.dart
        - database_migration.dart
      - [application_profile.dart](#应用程序信息) - 应用程序信息
      - [global_event.dart](#全局消息) - 全局消息
      - log.dart - 日志工具
      - [request_permission.dart](#权限申请工具) - 权限申请工具
    - [views/](#视图) - 视图
      - 功能名称/
        - 功能名称_页面名称_page.dart
    - main.dart - 入口文件
  - plugins/ - 本地插件
  - test/ - 自动化测试
  - [.env.sample](#环境配置文件) - 环境配置文件
  - pubspec.yaml - pubspec
  - README.md - 说明文件

## 环境配置文件

与 react/vue 的 `.env` 文件作用相同，可以在其中定义APP名称、API前缀、数据库名称等参数。

请在 `调试` 或 `编译` 前请将 `.env.sample` 复制到 `.env`。

## APP启动

APP以 `lib/main.dart` 为入口文件，会执行 `lib/app/app.dart` 的 `start()` 方法进行初始化，执行完毕你将获得 `环境配置`、`数据库`、`文件访问`、`路由`、`日志` 等功能。其中 `数据库` 和 `文件访问` 是异步初始化的，以便更快地显示界面。

初始化完毕后会调用 `runApp()` 函数，实例化`lib/app/app_component.dart`，这是App的UI骨架，在骨架中绑定路由、navigatorKey、定义Theme和语言包等操作。然后它会自动打开 '/' 路由对应的页面（路由组件的特性）。

最后，通过 `lib/app/error_handler.dart` 截获全局错误，出错时会弹出 dialog 提示框。

至此，APP初始化完毕。

## 路由

使用 `fluro` 第三方库，在 `lib/config/routes.dart` 中定义，在 `lib/app/app.dart` 中初始化，在 `lib/app/app_component.dart` 中通过 `onGenerateRoute` 参数绑定。

我们提供了 `App.navigateTo` 实现页面跳转，以下是完整的路由配置实例：


```dart
// file: lib/config/routes.dart
import 'package:fluro/fluro.dart' as fluro;
import 'package:myapp/views/home/home_page.dart';
import 'package:myapp/views/user/user_page.dart';

abstract class Routes {
  static const String home = '/';
  static const String user = '/user';
  static void configureRoutes(fluro.Router router) {
    // 404
    router.notFoundHandler = fluro.Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return NotFoundPage();
    });

    // home
    router.define(test, handler: fluro.Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return HomePage();
    }));

    // user
    router.define(test, handler: fluro.Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return UserPage(id: int.tryParse(params['id']?.first ?? ''));
    }));
  }
}

// file: lib/views/home/home_page.dart
import 'package:site_blackboard_app/app/app.dart';
import 'package:site_blackboard_app/config/routes.dart';

class HomePage extends StatelessWidget {
  ...
  await App.navigateTo(context, Routes.blackboardEditor, params: {
    'id': 1
  });
  dialog('已返回本页');
  ...
}

// file: lib/views/user/user_page.dart
class UserPage extends StatefulWidget {
  final int id;
  CaseUpdatePage({this.id, Key key}) : super(key: key);
  ...
}

// file: lib/views/not_found_page.dart
class NotFoundPage extends StatelessWidget {
  ...
}
```

## BLoC(RxDart)

我们使用的第三方库 `RxDart` 是 `BLoC状态管理` 的一种实现方式。

本文假设你已经了解 `RxDart`，如果对他们不熟悉，请参考以下两篇文章：

- [Flutter | 状态管理探索篇——BLoC(三) ](https://juejin.im/post/6844903689082109960)
- [Flutter | 状态管理拓展篇——RxDart(四)](https://www.jianshu.com/p/e0b0169a742e)

原则上 `bloc/` 文件夹中按 `功能` 和 `页面` 来划分文件，例如 `个人中心 => 基本资料页面` 对应 `bloc/profile/baseinfo_bloc.dart`。

每个bloc文件仅为对应的单个页面提供数据增、删、改、查的功能，并且应该为每个操作设定单独的 `方法` 和 `BehaviorSubject`。

### BlocProvider

这个类主要提供 `of` 方法，允许调用父组件绑定的Bloc，例如某页面中显示 `用户名` 等信息。

> 完整文档将在 `之后课程` 中补齐。

## 语言包

语言包文件 `lang_define.dart` 实际是多个类的集合，原则上每个功能一个类，通过静态属性存放该功能特定的语言。

通过 `lang` 函数可以实现占位符替换。

## 数据库

数据库选用 `sqlite`，并通过 `sqflite` 第三方组件操作。  

我们提供了 `lib/utility/db/database_helper.dart` 数据库助手类，负责数据库的打开和关闭，在其内部调用 `DatabaseMigration` 的实例类，负责数据库 `创建`、`升级`。

### 实现 DatabaseMigration

开发App之前应该实现 `DatabaseMigration`，负责APP第一次启动时创建数据库、APP升级时更新数据库结构等工作。

首先，在 `lib/utility/db` 中创建任意dart文件，建议 `{APPNAME}_database_migration.dart`，以下是样例代码：

```dart
// file: lib/utility/db/myappname_database_migration.dart
import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';

class MyappnameDatabaseMigration implements DatabaseMigration {
  // 当前APP的数据库版本
  static const int VERSION_CURRENT = 2;

  @override
  int getVersion() {
    return VERSION_CURRENT;
  }

  @override
  void onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute('create table xxx ...');
    batch.execute('create table yyy ...');
    batch.execute('create table zzz ...');
    await batch.commit();

    Log.info('Created database version: $version');
  }

  @override
  void onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      Batch batch = db.batch();
      batch.execute('ALERT ...');
      batch.execute('UPDATE ...');
      batch.execute('DELETE ...');
      await batch.commit();
    }

    Log.info('Upgraded the database version from $oldVersion to $newVersion');
  }
}
```

最后，修改 `lib/app/app.dart` 的 `get db async` 属性，将 `DatabaseHelper` 的第二个参数改为 `MyappnameDatabaseMigration()`。

### 使用数据库

`DatabaseHelper` 在 `lib/app/app.dart` 中被实例化，并对外暴漏 `App.db` 异步属性，这个属性便是 `sqflite` 的实例，可以直接使用：

```dart
Database db = await App.db;
db.query('users', where: '...');

--- or ---

await (await App.db).query('users', where: '...');
```

## 数据模型

`lib/model` 存放 `数据库`、`网络请求`、`内部数据` 的 `模型` 和 `数据结构定义`。

### 数据结构定义

`lib/model/item` 存放模型的数据结构定义，我们以 `用户（user）` 的数据结构为例。

```dart
// file: lib/model/item/user_item.dart

/// 定义列名称，比如数据库的列名
abstract class UserColumn {
  static final String id = 'id';
  static final String name = 'name';
  // ...
}

/// 数据结构
class UserItem {
  int id;
  String name;

  UserItem({Map<String, dynamic> map}) {
    if (null != map) {
      fromMap(map);
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      UserColumn.name: name,
    };

    if (id != null) {
      map[UserColumn.id] = id;
    }

    return map;
  }

  fromMap(Map<String, dynamic> map) {
    id = map[UserColumn.id];
    name = map[UserColumn.name];
  }

  fromItem(CaseItem item) {
    fromMap(item.toMap());
  }
}
```

### 数据库模型

`lib/model/db` 存放数据库模型，实现表的增删改查，还是以上面的  `用户（user）`  为例。

```dart
// file: lib/model/db/user_model.dart
import 'dart:io';

import 'package:myapp/app/app.dart';
import 'package:myapp/model/db/db_model.dart';
import 'package:myapp/model/item/user_item.dart'; // 调用user数据结构定义

class UserModel extends DbModel {
  @override
  String get tableName => 'user';

  /// 查询全部
  Future<List<UserItem>> findAll() async {
    var res =
        await (await db).query(tableName, orderBy: '${UserColumn.id} desc');
    List<UserItem> list =
        res.isNotEmpty ? res.map((c) => UserItem(map: c)).toList() : [];
    return list;
  }

  /// 获取单条信息
  Future<UserItem> get(int id) async {
    List<Map> maps = await (await db)
        .query(tableName, where: '${UserColumn.id} = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return UserItem(map: maps.first);
    }

    return null;
  }

  /// 插入数据
  Future<UserItem> insert(UserItem item) async {
    item.id = await (await db).insert(tableName, item.toMap());
    return item;
  }

  /// 修改数据
  update(UserItem item) async {
    await (await db).update(tableName, item.toMap(),
        where: '${UserColumn.id} = ?', whereArgs: [item.id]);
  }

  /// 删除数据
  delete(int id) async {
    await (await db)
        .delete(tableName, where: '${UserColumn.id} = ?', whereArgs: [id]);
  }
}
```

## 应用程序信息

可以获取 `isRelease`、`isDebug`、`isProfile`、`isWeb`、`isAndroid`、`isIos` 等信息。

## 全局消息

负责跨页面、跨组件消息传递，具体请参阅：https://pub.flutter-io.cn/packages/event_bus

## 权限申请工具

使用 `permission_handler` 第三方组件，并将其封装为 `lib/utility/request_permission.dart`，以下是用例：

```dart
import 'package:permission_handler/permission_handler.dart';
import 'package:myapp/utility/request_permission.dart';

if (await RequestPermission.request(
Permission.camera, '未启用相机权限')) {
  // some...
}

Map<Permission, bool> result = await RequestPermission.batchRequest({
    Permission.camera: '未启用相机权限',
    Permission.location: '未启用定位权限'
});
if (result[Permission.camera] && result[Permission.location]) {
    // some...
}
```
