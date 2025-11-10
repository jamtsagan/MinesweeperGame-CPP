#ifndef MINESWEEPERGAME_CPP_GAME_H
#define MINESWEEPERGAME_CPP_GAME_H

#include <vector>
#include "block.h"

struct TileInfo {
  int look; // 0 for hidden, 1 for revealed
  int mine; // 0 for not mine, 1 for mine
  int neighbor_mines;
};

class Game {
public:
  // 构造函数：当一局新游戏开始时调用
  Game(int width, int height, int mines);

  // 揭开一个格子，这是 Flutter UI 将会调用的主要功能
  void revealTile(int x, int y);

  // 获取当前整个棋盘的状态，以便 UI 可以绘制它
  std::vector<TileInfo> getBoardState() const;

  // 检查游戏是否结束
  bool isGameOver() const;

private:
  // 我们的递归函数，现在是类的私有成员，外部无法直接访问
  void openBlankCells(int x, int y);

  // 游戏的状态都作为类的私有成员变量
  int grid_width;
  int grid_height;
  int mine_count;
  bool game_over;
  std::vector<block> blocks;
};

#endif //MINESWEEPERGAME_CPP_GAME_H
