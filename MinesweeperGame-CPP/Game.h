#ifndef GAME_H
#define GAME_H

# include <vector>
# include "block.h"

class Game {
  public:
    Game(int width, int height, int num_mines);

    // 揭开一个格子
    void reveal_cells(int x, int y);

    // 插旗
    void flag_cells(int x, int y);

    // 获取所有格子的状态
    const std::vector<block>& get_blocks() const;

    // 检查游戏是否胜利
    bool is_game_win();

    // 检查游戏受否因为踩雷结束
    bool is_game_over();

  private:

    // 递归揭开空格子
    void open_blank_cells(int x, int y);

    int grid_width, grid_height;
    int mines;
    int flags;
    bool game_over_flags;

    std::vector<block> blocks;

};

#endif