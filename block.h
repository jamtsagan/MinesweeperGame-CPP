#ifndef BLOCK_H
#define BLOCK_H

# include <vector>

class block {
public:
    int mine; // 有雷 = 1, 无雷 = 0
    int look; // 已查看 = 1, 未查看 = 0
    int flag; // 已插旗 = 1, 未插旗 = 0
    int x_coord, y_coord;
    int neighbor_mines; // 相邻8个格子内的雷数

    block(int x, int y);

    void scan(const std::vector<block>& all_blocks, int grid_width, int grid_height);
};


#endif //BLOCK_H
