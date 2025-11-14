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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        final double boardAspectRatio = gridWidth / gridHeight;

        double boardWidth;
        double boardHeight;

        if (maxWidth / maxHeight > boardAspectRatio) {
          boardHeight = maxHeight;
          boardWidth = boardHeight * boardAspectRatio;
        } else {
          boardWidth = maxWidth;
          boardHeight = boardWidth / boardAspectRatio;
        }

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: GridView.builder(
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
            ),
          ),
        );
      },
    );
  }
}