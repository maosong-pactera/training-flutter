# Flutter 框架和 Dart 语言

本课讲解的内容均出自 [Flutter开发文档](https://flutter.cn/docs) 和 [Dart开发文档](https://dart.cn/guides) 中的内容，可以通过 [语言速查表](https://dart.cn/codelabs/dart-cheatsheet) 快速学习 Dart 语法。

推荐 [DartPad](https://dartpad.cn/) 这款极为优秀的 Dart 编程语言线上工具，可以在任何现代化浏览器中试验你的 Dart 代码或 Flutter 界面。

除此之外，你应该重点关注以下内容：

- [代码风格](https://dart.cn/guides/language/effective-dart/style)
- [核心库](https://dart.cn/guides/libraries)
- [Packages](https://dart.cn/guides/packages)
- [异步编程](https://dart.cn/codelabs/async-await)
- [空安全](https://dart.cn/null-safety)

## 实例代码

Dart 实例

```dart
import 'dart:async';

main() {
  printDatetime();
}

void printDatetime() async {
  print('Start at: ${DateTime.now()}\n');
  Sample sample = Sample('Now datetime');
  print(await sample.test());
  print('Finish at: ${DateTime.now()}\n');
}

class Sample {
  String text;

  Sample(this.text);

  Future<String> test() {
    return Future.delayed(
        Duration(seconds: 3), () => '${this.text}: ${DateTime.now()}\n');
  }
}
```

Flutter 实例

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter layout demo'),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
```