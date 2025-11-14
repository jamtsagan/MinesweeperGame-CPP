// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/theme_provider.dart';
import 'pages/game_page.dart';

void main() async {
  // Flutter插件的前置代码
  WidgetsFlutterBinding.ensureInitialized();

  // 窗口管理器的前置代码
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(400, 500), // 设置窗口的最小宽度和高度
    center: true,
    // size: Size(800, 600), // 你也可以设置一个初始大小
    // title: "Minesweeper", // 你也可以在这里设置标题
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    // 使用 ChangeNotifierProvider 把我们的 ThemeProvider 注入到 Widget 树中
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 来“消费”或“监听” ThemeProvider 的变化
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // 当主题改变时，这个 builder 会被重新调用
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // 我们不再硬编码主题，而是从 ThemeProvider 获取
          theme: ThemeData(
            brightness: themeProvider.currentTheme.brightness,
            // 你可以根据 themeProvider.currentTheme 来配置更多 ThemeData 的属性
          ),
          home: const GamePage(),
        );
      },
    );
  }
}