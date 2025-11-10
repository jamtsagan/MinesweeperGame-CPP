#include <iostream>
#include <vector>
#include "game_api.h" // 我们只包含“说明书”，而不是内部的 C++ 头文件

int main() {
  std::cout << "--- MinesweeperCore Library Test ---" << std::endl;

  // 1. 创建一局游戏
  std::cout << "Creating a 9x9 game with 10 mines..." << std::endl;
  Game* my_game = create_game(9, 9, 10);

  // 2. **健壮性检查**：检查游戏是否创建成功
  if (!my_game) {
    std::cout << "Error: Failed to create game!" << std::endl;
    return -1;
  }
  std::cout << "Game created successfully!" << std::endl;

  // 3. 调用一个核心功能，比如揭开 (0, 0)
  std::cout << "Revealing cell (0, 0)..." << std::endl;
  reveal_cell(my_game, 0, 0);

  // 4. 获取棋盘状态，并验证结果
  std::cout << "Getting board state..." << std::endl;
  // 准备一个足够大的“鸡蛋盒”来接收数据
  std::vector<simple_block> board_state(9 * 9);
  // 把“鸡蛋盒”的地址传给库，让它填充
  get_board_state(my_game, board_state.data());

  // 打印出 (0,0) 位置的状态，看看是不是真的被揭开了
  std::cout << "State of cell (0, 0):" << std::endl;
  std::cout << "  - is_looked: " << board_state[0].look << " (should be 1)" << std::endl;
  std::cout << "  - neighbor_mines: " << board_state[0].neighbor_mines << std::endl;

  // 5. 检查游戏状态
  std::cout << "Is game over? " << (is_game_over(my_game) ? "Yes" : "No") << std::endl;

  // 6. **至关重要**：销毁游戏，释放内存
  std::cout << "Destroying game..." << std::endl;
  destroy_game(my_game);
  std::cout << "Test finished." << std::endl;

  return 0;
}