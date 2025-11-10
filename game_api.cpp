# include "Game.h"
# include "game_api.h"

extern "C"

// 创建新游戏
API Game* create_game(int width, int height, int mines) {
  return new Game(width, height, mines);
}

// 删除游戏
API void destroy_game(Game* game_instance) {
  delete game_instance;
}

// 揭开格子
API void reveal_cell(Game* game_instance, int x, int y) {
  if (game_instance) {
    game_instance->reveal_cells(x, y);
  }
}

// 插旗
API void flag_cell(Game* game_instance, int x, int y) {
  if (game_instance) {
    game_instance->flag_cells(x, y);
  }
}

// 游戏胜利或失败的检查
API bool is_game_over(Game* game_instance) {
  return game_instance ? game_instance->is_game_over() : true;
}

API bool is_game_win(Game* game_instance) {
  return game_instance ? game_instance->is_game_win() : false;
}


API void get_board_state(Game* game_instance, simple_block* state_array) {
  if (!game_instance) return;

  const auto& blocks = game_instance->get_blocks();

  for (size_t i = 0; i < blocks.size(); ++i) {
    state_array[i].mine = blocks[i].mine;
    state_array[i].look = blocks[i].look;
    state_array[i].flag = blocks[i].flag;
    state_array[i].neighbor_mines = blocks[i].neighbor_mines;
  }
}






