// lib/game_service.dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'minesweeper_api.dart'; // 导入 ffigen 生成的代码
import 'tile_state.dart';

class GameService {
  late MinesweeperApi _api;
  late Pointer<Game> _gameInstance; // 我们的“遥控器”

  final int width;
  final int height;
  final int mines;

  GameService({this.width = 9, this.height = 9, this.mines = 10}) {
    // 加载 .dll 并创建游戏实例
    _api = MinesweeperApi(DynamicLibrary.open('MinesweeperCore.dll'));
    _gameInstance = _api.create_game(width, height, mines);
  }

  // 揭开格子
  void revealCell(int x, int y) {
    _api.reveal_cell(_gameInstance, x, y);
  }

  // 插旗
  void flagCell(int x, int y) {
    _api.flag_cell(_gameInstance, x, y);
  }

  // 检查游戏状态
  bool isGameOver() => _api.is_game_over(_gameInstance) != 0;
  bool isGameWon() => _api.is_game_win(_gameInstance) != 0;

  // 获取棋盘状态 (这是最复杂的部分)
  List<TileState> getBoardState() {
    // 1. 在 Dart 的内存里，创建一个“空鸡蛋盒”
    //    malloc 是 ffi 库提供的，用来分配 C 语言兼容的内存
    final pointer = malloc.allocate<simple_block>(sizeOf<simple_block>() * (width * height));

    // 2. 把空盒子的地址传给 C++，让它填充
    _api.get_board_state(_gameInstance, pointer);

    // 3. 把 C++ 填充好的数据，转换成 Dart 的 List<TileState>
    final stateList = <TileState>[];
    for (var i = 0; i < width * height; i++) {
      final tile = pointer.elementAt(i).ref;
      stateList.add(TileState(
        isRevealed: tile.look == 1,
        isMine: tile.mine == 1,
        isFlagged: tile.flag == 1,
        adjacentMines: tile.neighbor_mines,
      ));
    }

    // 4. 【至关重要】释放我们之前分配的 C 内存，防止内存泄漏
    malloc.free(pointer);

    return stateList;
  }

  // 销毁游戏实例
  void dispose() {
    _api.destroy_game(_gameInstance);
  }
}