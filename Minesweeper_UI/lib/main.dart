// lib/main.dart

import 'package:flutter/material.dart';
import 'game_service.dart';
import 'tile_state.dart';
import 'tile_widget.dart';

void main() {
  runApp(const MyApp());
}

// MyApp 现在是一个纯粹的“外壳”，只负责创建 MaterialApp。
// 这是一个 StatelessWidget，因为它永远不变。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home 属性现在指向我们新的、有状态的游戏页面
      home: const GamePage(),
    );
  }
}

// -----------------------------------------------------------------
// GamePage 才是我们真正的游戏界面，它是有状态的
// -----------------------------------------------------------------
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // 【修正 1】'late final' 改为 'late'，允许我们重新开始游戏
  late GameService _gameService;
  late List<TileState> _boardState;

  // 游戏配置
  final int gridWidth = 9;
  final int gridHeight = 9;
  final int mines = 10;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  // 初始化游戏
  void _initializeGame() {
    _gameService = GameService(width: gridWidth, height: gridHeight, mines: mines);
    _boardState = _gameService.getBoardState();
  }

  // 处理左键点击 -> 揭开格子
  void _handleTileTap(int index) {
    // 游戏结束后，不再响应任何点击
    if (_gameService.isGameOver() || _gameService.isGameWon()) return;

    int x = index % gridWidth;
    int y = index ~/ gridWidth;

    setState(() {
      _gameService.revealCell(x, y);
      _boardState = _gameService.getBoardState();
    });

    _checkGameStatus();
  }

  // 处理右键点击 -> 插旗
  void _handleTileFlag(int index) {
    // 游戏结束后，不再响应任何点击
    if (_gameService.isGameOver() || _gameService.isGameWon()) return;

    int x = index % gridWidth;
    int y = index ~/ gridWidth;

    setState(() {
      _gameService.flagCell(x, y);
      _boardState = _gameService.getBoardState();
    });

    _checkGameStatus();
  }

  // 检查游戏是否结束
  void _checkGameStatus() {
    if (_gameService.isGameOver()) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _showGameOverDialog("你踩到雷了！");
      });
    } else if (_gameService.isGameWon()) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _showGameOverDialog("恭喜你，游戏胜利！");
      });
    }
  }

  // 显示游戏结束的对话框
  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // 【修正 2】为了确保弹窗能正确关闭，我们给 builder 一个新的 context 名字
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("游戏结束"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("重新开始"),
              onPressed: () {
                setState(() {
                  _gameService.dispose();
                  _initializeGame();
                });
                // 使用新的 dialogContext 来关闭弹窗
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text('Minesweeper'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _gameService.dispose();
                _initializeGame();
              });
            },
          ),
        ],
      ),
      // body 部分是我们的主战场
      body: Center(
        // 【第一层包装：LayoutBuilder】 - 我们的“高级侦察兵”
        // builder 函数会给我们两个宝贵的信息：
        // 1. context: 组件树的上下文
        // 2. constraints: 父组件（这里是 Center）提供的最大可用空间信息
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // --- 这是我们智能算法的核心 ---
            // 1. 获取最大可用宽度和高度
            final double maxWidth = constraints.maxWidth;
            final double maxHeight = constraints.maxHeight;

            // 2. 计算出在这块空间里，能放下的最大正方形的边长
            //    我们取宽度和高度中较小的那一个值
            final double boardSize = (maxWidth < maxHeight) ? maxWidth : maxHeight;

            // 3. (可选，但推荐) 我们再给这个最大尺寸打个折，比如 80%，
            //    这样棋盘就不会完全贴着屏幕边缘，留出一些“呼吸空间”。
            final double constrainedSize = boardSize * 0.85;

            // --- 布局结构开始 ---
            // 【第二层包装：ConstrainedBox】 - 我们的“尺寸限制器”
            return ConstrainedBox(
              // 我们用 BoxConstraints.tightFor 来创建一个严格的正方形约束
              // 它的宽度和高度都必须等于我们刚刚计算出的 constrainedSize
              constraints: BoxConstraints.tightFor(
                width: constrainedSize,
                height: constrainedSize,
              ),

              // 【被包裹的核心内容：我们的 GridView】
              // GridView 现在被严格限制在这个智能计算出的正方形区域内
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridWidth * gridHeight,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridWidth,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => _handleTileTap(index),
                    onSecondaryTapDown: (details) => _handleTileFlag(index),
                    child: TileWidget(state: _boardState[index]),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameService.dispose();
    super.dispose();
  }
}