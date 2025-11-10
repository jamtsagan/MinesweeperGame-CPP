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







}