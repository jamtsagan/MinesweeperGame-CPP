// lib/game_service.dart

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'minesweeper_api.dart';
import 'tile_state.dart';

class GameService {
  // 1. 成员变量声明 (改为 final，更健壮)
  final MinesweeperApi _api;
  final Pointer<Game> _gameInstance;
  final int width;
  final int height;
  final int mines;

  // 2. 一个私有的命名构造函数，只负责接收最终的初始化结果
  GameService._internal(this._api, this._gameInstance, this.width, this.height, this.mines);

  // 3. 【核心】一个公开的工厂构造函数
  //    这是外部唯一能调用的构造函数，所有复杂的初始化逻辑都在这里
  factory GameService({int width = 9, int height = 9, int mines = 10}) {
    String libraryPath = '';

    if (Platform.isWindows) {
      String scriptPath = Platform.script.toFilePath(windows: true);
      String scriptDirectory = path.dirname(scriptPath);
      libraryPath = path.join(scriptDirectory, 'MinesweeperCore.dll');
    } else {
      // (为其他平台做准备)
      // libraryPath = 'libMinesweeperCore.so';
    }

    // 加载库
    final api = MinesweeperApi(DynamicLibrary.open(libraryPath));
    // 创建 C++ 游戏实例
    final gameInstance = api.create_game(width, height, mines);

    // 调用私有构造函数，返回一个被完全初始化的 GameService 对象
    return GameService._internal(api, gameInstance, width, height, mines);
  }

  // 4. 所有其他方法都保持不变，现在它们可以正常工作了
  void revealCell(int x, int y) {
    _api.reveal_cell(_gameInstance, x, y);
  }

  void flagCell(int x, int y) {
    _api.flag_cell(_gameInstance, x, y);
  }

  bool isGameOver() => (_api.is_game_over(_gameInstance)) != 0;
  bool isGameWon() => (_api.is_game_win(_gameInstance)) != 0;

  List<TileState> getBoardState() {
    final pointer = malloc.allocate<simple_block>(sizeOf<simple_block>() * (width * height));
    try {
      _api.get_board_state(_gameInstance, pointer);
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
      return stateList;
    } finally {
      // 确保 malloc 分配的内存总是被释放，即使中间发生错误
      malloc.free(pointer);
    }
  }

  void dispose() {
    _api.destroy_game(_gameInstance);
  }
}