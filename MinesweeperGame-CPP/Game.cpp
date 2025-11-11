# include "Game.h"
# include <random>
# include <ctime>
# include <iostream>

Game::Game(int width, int height, int num_mines) {

  this->grid_width = width;
  this->grid_height = height;
  this->mines = num_mines;
  this->flags = 0;
  this->game_over_flags = false;

  // 创建所有的格子(对象)
  for (int j = 0; j < grid_height; j++) {
    for (int i = 0; i < grid_width; i++) {
      blocks.emplace_back(block(i, j));
    }
  }

  // 布雷
  srand(time(0));
  int mine_counter = 0;
  while (mine_counter < mines) {
    int random_index = rand() % (grid_width * grid_height);
    if (blocks[random_index].mine == 0) {
      blocks[random_index].mine = 1;
      mine_counter++;
    }
  }

  // 初始化所有格子的数字
  for (int j = 0; j < grid_height; j++) {
    for (int i = 0; i < grid_width; i++) {
      blocks[j * grid_width + i].scan(blocks, grid_width, grid_height);
    }
  }

  std::cout << "Game Engine Created!" << std::endl;

}

// 揭开一个格子
void Game::reveal_cells(int x, int y) {
  if (this->game_over_flags || this->is_game_win()) return; // 游戏结束就不揭开

  // 定位当前的格子坐标
  int index = y * grid_width + x;

  if (this->blocks[index].look == 1) return; // 点开过就不揭开

  if (this->blocks[index].mine == 1) {
    this->game_over_flags = true;
    return;
  }

  open_blank_cells(x, y);
}

void Game::flag_cells(int x, int y) {
  if (this->game_over_flags || this->is_game_win()) return; // 游戏结束就不插旗

  // 定位当前的格子坐标
  int index = y * grid_width + x;

  if (this->blocks[index].look == 1) return; // 点开过就不插旗

  // 插旗逻辑
  if (this->blocks[index].flag == 0) { // 检查是否插过
    this->blocks[index].flag = 1;
    if (this->blocks[index].mine == 1) {
      this->flags++;
    }
  }
  else {
    this->blocks[index].flag = 0;
    if (this->blocks[index].mine == 1) {
      this->flags--;
    }
  }
}

void Game::open_blank_cells(int x, int y) {
  // 设置返回逻辑
  if (x < 0 || x >= this->grid_width || y < 0 || y >= this->grid_height) {
    return; // 超出边界则返回
  }

  // 定位当前的格子坐标
  int index = y * this->grid_width + x;

  if (this->blocks[index].look == 1) {
    return; // 跳过已经揭开过的格子
  }

  this->blocks[index].look = 1;   // 揭开操作
  this->blocks[index].flag = 0;

  // 不递归
  if (blocks[y * grid_width + x].neighbor_mines > 0) {
    return;
  }
  // 递归
  if (blocks[y * grid_width + x].neighbor_mines == 0) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        open_blank_cells(x + i, y + j);
      }
    }
  }
}

const std::vector<block>& Game::get_blocks() const {
  return this->blocks;
}

// 胜利函数与失败函数
bool Game::is_game_win() {
  return this->flags == this->mines;
}
bool Game::is_game_over() {
  return this->game_over_flags;
}




