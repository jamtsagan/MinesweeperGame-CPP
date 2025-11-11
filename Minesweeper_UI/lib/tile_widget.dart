// lib/tile_widget.dart

import 'package:flutter/material.dart';
import 'tile_state.dart';

class TileWidget extends StatelessWidget {
  final TileState state;
  const TileWidget({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: state.isRevealed ? Colors.grey[700] : Colors.grey[400],
        border: Border.all(color: Colors.black, width: 2),
      ),
      // 我们在 Container 内部添加一个 Center，用来居中显示内容
      child: Center(
        child: _buildTileContent(), // 调用一个辅助函数来决定显示什么
      ),
    );
  }

  // 这是一个辅助函数，根据格子的状态返回不同的 Widget
  Widget _buildTileContent() {
    if (state.isFlagged) {
      // 如果插旗了，就显示一个旗帜图标
      return const Icon(Icons.flag, color: Colors.red, size: 30);
    }
    if (state.isRevealed) {
      if (state.isMine) {
        // 如果是雷，显示一个火焰图标
        return const Icon(Icons.local_fire_department, color: Colors.orange, size: 30);
      }
      if (state.adjacentMines > 0) {
        // 如果是数字，显示文本
        return Text(
          '${state.adjacentMines}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue, // 暂时用蓝色
          ),
        );
      }
    }
    // 如果是未揭开的空格子，或者揭开的0格，就什么都不显示
    return const SizedBox.shrink();
  }
}