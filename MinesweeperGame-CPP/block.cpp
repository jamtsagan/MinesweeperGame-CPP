#include "block.h"
#include <vector>

block::block(int x, int y) {
  this->x_coord = x;
  this->y_coord = y;
  this->mine = 0;
  this->look = 0;
  this->flag = 0;
  this->neighbor_mines = 0;
}

// 决定这个格子的数字
void block::scan(const std::vector<block>& all_blocks, int grid_width, int grid_height) {
  if (this->mine) {
    this->neighbor_mines = -1;
    return;
  }

  int mines_count = 0;
  for (int i = -1; i < 2; i++) {
    for (int j = -1; j < 2; j++) {
      if (i == 0 && j == 0) continue;

      int neighbor_x = this->x_coord + i;
      int neighbor_y = this->y_coord + j;

      if (neighbor_x >= 0 && neighbor_y >= 0 && neighbor_x < grid_width && neighbor_y < grid_height) {
        int neighbor_index = neighbor_y * grid_width + neighbor_x;

        if (all_blocks[neighbor_index].mine == 1) {
          mines_count++;
        }
      }
    }
  }
  this->neighbor_mines = mines_count;
};

