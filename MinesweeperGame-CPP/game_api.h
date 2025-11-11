#ifndef GAME_API_H
#define GAME_API_H

#include "dll_export.h"

#ifdef __cplusplus
extern "C" {
#endif

  // --- 结构体定义 ---
  // 把 SimpleBlock 的定义也放在这里，这样使用者就知道数据结构了
  struct simple_block {
    int mine, look, flag, neighbor_mines;
  };

  // --- 函数声明 ---
  // 我们只暴露类型，不暴露 Game 类的具体实现
  // 在 C 语言层面，我们只知道它是一个不透明的指针
  struct Game;

  // 声明所有我们可以调用的函数
  API Game* create_game(int width, int height, int mines);
  API void destroy_game(Game* game_instance);
  API void reveal_cell(Game* game_instance, int x, int y);
  API void flag_cell(Game* game_instance, int x, int y);
  API bool is_game_over(Game* game_instance);
  API bool is_game_win(Game* game_instance);
  API void get_board_state(Game* game_instance, simple_block* state_array);

#ifdef __cplusplus
}

#endif

#endif //GAME_API_H
