# include <iostream>
# include <vector>
# include "block.h"
# include <random>
# include <ctime>

#ifdef _WIN32
    #include <windows.h>
#endif


int main() {
  #ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
  #endif

  // 初始化棋盘大小和雷数
  int mines = 9;
  int grid_width = 9, grid_height = 9;

  // 初始化内存
  std::vector<block> blocks;
  blocks.reserve(grid_width * grid_height);

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
    if (blocks[random_index].is_mines() == 0) {
      blocks[random_index].mine = 1;
      mine_counter++;
    }
  }


  // 打印初始雷区
  std::cout << "打印初始雷区" << std::endl;
  for (int j = 0; j < grid_height; j++) {
    for (int i = 0; i < grid_width; i++) {
      std::cout << blocks[j * grid_height + i].mine << " ";
    }
    std::cout << std::endl;
  }

  // 输出起始文本
  std::cout << "开始游戏" << std::endl;
  std::cout << "请输入坐标后再输入命令来表示‘看’ 或 ‘插旗’" << std::endl;
  std::cout << "如 “5 8 c”\n   “8 4 f”" << std::endl;

  for (int j = 0; j < grid_height; j++) {
    for (int i = 0; i < grid_width; i++) {
      if (blocks[j * grid_height + i].is_look() == 0) {
        std::cout << "■ ";
      }
      else {
        std::cout << blocks[j * grid_height + i].neighbor_mines << " ";
      }
    }
    std::cout << std::endl;
  }

  // 程序主循环
  while (1) {
    std::cout << "请输入您的选择：" << std::endl;

    int temp_x, temp_y;
    std::string cmd;
    std::cin >> temp_x >> temp_y >> cmd;
    std::cout << temp_x << std::endl;
    std::cout << temp_y << std::endl;
    std::cout << cmd << std::endl;

    for (int j = 0; j < grid_height; j++) {
      for (int i = 0; i < grid_width; i++) {
        if (blocks[j * grid_height + i].is_look() == 0) {
          if (i == temp_x && j == temp_y) {
            std::cout << blocks[j * grid_height + i].neighbor_mines << " ";
          }
          else {
            std::cout << "■ ";
          }
        }
        else {
          std::cout << blocks[j * grid_height + i].neighbor_mines << " ";
        }
      }
      std::cout << std::endl;
    }

    if (blocks[temp_y * grid_height + temp_x].is_mines() == 1) {
      break;
    }
  }

  std::cout << "游戏结束" << std::endl;

  return 0;
}