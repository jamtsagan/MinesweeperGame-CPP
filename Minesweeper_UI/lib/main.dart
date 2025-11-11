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
    // 【修正 3】build 方法现在返回的是 Scaffold，而不是 MaterialApp
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text('Minesweeper'),
        backgroundColor: Colors.grey[900],
        // 添加刷新按钮
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 这个 setState 现在可以正常工作了
              setState(() {
                _gameService.dispose();
                _initializeGame();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
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