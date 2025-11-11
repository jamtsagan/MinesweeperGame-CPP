# include <iostream>
# include <vector>
# include "block.h"
# include <random>
# include <ctime>

#ifdef _WIN32
    #include <windows.h>
#endif

// 用来揭开格子的递归函数
void open_blank_cells(std::vector<block>& all_blocks, const int x, const int y, const int grid_width, const int grid_height) {
  // 设置返回逻辑
  if (x < 0 || x >= grid_width || y < 0 || y >= grid_height) {
    return; // 超出边界则返回
  }
  if (all_blocks[y * grid_width + x].look == 1) {
    return; // 曾经被揭开则返回
  }

  all_blocks[y * grid_width + x].look = 1;   // 揭开操作

  // 不递归
  if (all_blocks[y * grid_width + x].neighbor_mines > 0) {
    return;
  }
  // 递归
  if (all_blocks[y * grid_width + x].neighbor_mines == 0) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        open_blank_cells(all_blocks, x + i, y + j, grid_width, grid_height);
      }
    }
  }
}


int main() {
  #ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
  #endif

  // 初始化棋盘大小和雷数
  int mines = 3;
  int grid_width = 9, grid_height = 9;
  int flags = 0; // 用来判断胜利

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

  // 打印初始雷区
  std::cout << "打印初始雷区" << std::endl;
  for (int j = 0; j < grid_height; j++) {
    for (int i = 0; i < grid_width; i++) {
      std::cout << blocks[j * grid_width + i].mine << " ";
    }
    std::cout << std::endl;
  }

  // 输出起始文本
  std::cout << "开始游戏" << std::endl;
  std::cout << "请输入坐标后再输入命令来表示‘看’ 或 ‘插旗’" << std::endl;
  std::cout << "如 “5 8 c”\n   “8 4 f”" << std::endl;

  for (int j = 0; j < grid_width; j++) {
    for (int i = 0; i < grid_width; i++) {
      if (blocks[j * grid_width + i].look == 0) {
        std::cout << "■ ";
      }
    }
    std::cout << std::endl;
  }

  // 程序主循环
  while (1) {
    std::cout << "请输入您的选择：" << std::endl;

    // 初始化输入
    int temp_x, temp_y;
    std::string cmd;
    std::cin >> temp_x >> temp_y >> cmd;

    // 防呆设置
    if (temp_x < 0 || temp_x >= grid_width || temp_y < 0 || temp_y >= grid_height) {
      std::cout << "所选格子不合法，请重新选择" ;
      continue;
    }
    if (cmd == "q") {
      std::cout << "已退出游戏" << std::endl;
      return 0;
    }
    if (cmd != "q" && cmd != "c" && cmd != "f") {
      std::cout << "非法符号，请重新输入" << std::endl;
      continue;
    }

    if (cmd == "c") {
      if (blocks[temp_y * grid_width + temp_x].mine == 1) {
        break;
      }
      if (blocks[temp_y * grid_width + temp_x].look == 1) {
        std::cout << "已经点击过该格子" ;
        continue;
      }

      open_blank_cells(blocks, temp_x, temp_y, grid_width, grid_height);
    }

    if (cmd == "f") {
      if (blocks[temp_y * grid_width + temp_x].flag == 1) {
        std::cout << "已经点击过该格子" ;
        continue;
      }
      if (blocks[temp_y * grid_width + temp_x].look == 1) {
        std::cout << "无法点击此格子，请重新选择" ;
        continue;
      }

      blocks[temp_y * grid_width + temp_x].flag = 1;

      if (blocks[temp_y * grid_width + temp_x].mine == 1) {
        flags++;
      }
    }

    // 打印棋盘
    for (int j = 0; j < grid_height; j++) {
      for (int i = 0; i < grid_width; i++) {
        if (blocks[j * grid_width + i].look == 1) {
          if (blocks[j * grid_width + i].neighbor_mines == 0) {
            std::cout << "  ";
          }
          else {
            std::cout << blocks[j * grid_width + i].neighbor_mines << " ";
          }
          continue;
        }
        if (blocks[j * grid_width + i].flag == 1) {
          std::cout << "F ";
          continue;
        }

        std::cout << "■ ";

      }

      std::cout << "\n";
    }

    if (flags == mines) {
      std::cout << "游戏胜利" << std::endl;
      return 0;
    }
  }

  std::cout << "游戏结束" << std::endl;

  return 0;
}