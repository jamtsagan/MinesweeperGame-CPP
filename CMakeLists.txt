# 指定 CMake 的最低版本要求
cmake_minimum_required(VERSION 3.20)

# 定义项目名称，比如 "MinesweeperGame"
project(MinesweeperGame-CPP)

add_compile_options(-finput-charset=UTF-8 -fexec-charset=UTF-8)

# 设置 C++ 标准为 C++17 (这是一个很好的现代标准)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 这是最关键的一行！
# add_executable(可执行文件名 源文件1 源文件2 源文件3 ...)
# 它告诉 CMake，你要创建一个名为 "MinesweeperGame" 的可执行文件
# 这个文件是由 main.cpp, block.cpp, 和 block.h 共同构成的。
add_executable(MinesweeperGame-CPP main.cpp block.cpp block.h)