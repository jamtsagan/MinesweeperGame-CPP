// lib/tile_state.dart

// 这个 Dart 类，完美对应了我们 C++ 里的 simple_block 结构体
// 它就是 UI 和 核心逻辑之间沟通的“语言”
class TileState {
  bool isRevealed; // 是否被揭开
  bool isMine;     // 是否是雷
  bool isFlagged;  // 是否被插旗
  int adjacentMines; // 周围的雷数

  // 构造函数
  TileState({
    this.isRevealed = false, // 默认都是未揭开
    this.isMine = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}