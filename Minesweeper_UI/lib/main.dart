// 1. 导入 Flutter 的 Material Design 库，这是所有UI组件的基础。
import 'package:flutter/material.dart';

// 2. main() 函数：和 C++ 一样，这是你整个应用的入口点。
//    "runApp" 是 Flutter 的指令：“请把这个 Widget 作为应用的根，然后运行它！”
void main() {
  runApp(const MyApp());
}

// 3. MyApp：这是你的第一个 Widget，是整个应用的“根”。
//    它继承自 StatelessWidget，意味着它本身是静态的、不可变的。
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // 这是一个标准的构造函数，暂时不用管它

  // 4. build 方法：这是每个 Widget 都必须有的核心方法！
  //    它的工作就是“描述”这个 Widget 长什么样。Flutter 会调用它来绘制界面。
  @override
  Widget build(BuildContext context) {
    // 5. MaterialApp：这是一个非常重要的基础 Widget，它为你的应用提供了
    //    所有 Material Design 的基础功能，比如主题、导航等。
    return MaterialApp(
      // 6. Scaffold：“脚手架”，它提供了一个标准的页面布局结构，
      //    比如顶部的应用栏(appBar)和页面的主体(body)。
      home: Scaffold(
        backgroundColor: Colors.grey[800], // 给页面一个深灰色的背景
        // 7. AppBar：页面顶部的标题栏。
        appBar: AppBar(
          title: const Text('Minesweeper'),
          backgroundColor: Colors.grey[900],
        ),
        // 8. body：页面的主要内容。我们用一个 Center Widget 把它的子元素放在屏幕中央。
        body: Center(
          // 9. Container：这就是我们的扫雷方块！它是一个万能的“容器”Widget。
          child: Container(
            width: 50,  // 方块的宽度
            height: 50, // 方块的高度
            // 10. decoration：用来给 Container 添加边框、圆角、背景色等复杂样式。
            decoration: BoxDecoration(
              color: Colors.grey[400], // 方块的颜色 (未揭开的灰色)
              border: Border.all(      // 给它添加一个黑色的边框
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}