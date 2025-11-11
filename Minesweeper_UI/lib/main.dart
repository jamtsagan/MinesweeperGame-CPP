// lib/main.dart

import 'package:flutter/material.dart';
import 'game_service.dart';
import 'tile_state.dart';
import 'tile_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 游戏服务和状态
  late final GameService _gameService;
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
      _showGameOverDialog("你踩到雷了！");
    } else if (_gameService.isGameWon()) {
      _showGameOverDialog("恭喜你，游戏胜利！");
    }
  }

  // 显示游戏结束的对话框
  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击外部关闭对话框
      builder: (BuildContext context) {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          title: const Text('Minesweeper'),
          backgroundColor: Colors.grey[900],
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
              // 回归到最简洁、最高效的 itemBuilder 版本
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
      ),
    );
  }

  @override
  void dispose() {
    _gameService.dispose();
    super.dispose();
  }
}