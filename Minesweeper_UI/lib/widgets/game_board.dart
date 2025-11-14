// lib/widgets/game_board.dart
import 'package:flutter/material.dart';
import '../models/tile_state.dart';
import 'tile_widget.dart';

class GameBoard extends StatelessWidget {
  final int gridWidth;
  final int gridHeight;
  final List<TileState> boardState;
  final void Function(int index) onTileTap;
  final void Function(int index) onTileFlag;

  const GameBoard({
    super.key,
    required this.gridWidth,
    required this.gridHeight,
    required this.boardState,
    required this.onTileTap,
    required this.onTileFlag,
  });

  @override
  Widget build(BuildContext context) {
    // 现在，它只是一个纯粹的 GridView！
    // 它的尺寸将由父组件（SizedBox）严格控制。
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridWidth * gridHeight,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridWidth,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => onTileTap(index),
          onSecondaryTapDown: (details) => onTileFlag(index),
          child: TileWidget(state: boardState[index]),
        );
      },
    );
  }
}