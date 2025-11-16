// lib/pages/game_page.dart

// 导入所有需要的库
import 'dart:async'; // 提供了 Timer 等异步功能
import 'package:flutter/material.dart'; // Flutter 的核心 Material Design 库
import 'package:flutter/services.dart'; // 提供了输入框格式化等服务
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../services/game_service.dart';
import '../models/tile_state.dart';
import '../widgets/game_board.dart'; // 导入我们新的棋盘 Widget

// GamePage 是一个 StatefulWidget，因为它需要管理会随时间变化的状态。
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  // createState() 是 StatefulWidget 的核心方法，它负责创建一个 State 对象。
  @override
  State<GamePage> createState() => _GamePageState();
}

// _GamePageState 是真正存放所有状态和逻辑的地方。
// 'State<GamePage>' 意味着这个 State 是属于 GamePage 这个 Widget 的。
class _GamePageState extends State<GamePage> {
  // --- 状态变量区 ---
  // 这里存放所有会影响 UI 显示的数据。

  // 游戏服务：与 C++ 核心沟通的桥梁。'late' 表示我们承诺会在使用前初始化它。
  late GameService _gameService;
  // 棋盘状态：一个 TileState 对象的列表，UI 将根据它来绘制。
  late List<TileState> _boardState;

  // 计时器状态
  Timer? _timer; // 用来计时的 Timer 对象，'?'表示它可以是空的 (在游戏开始前或结束后)。
  int _secondsElapsed = 0; // 已经过去的秒数。
  bool _isFirstTap = true; // 一个布尔标志，用来判断是不是玩家的第一次有效点击。

  // 游戏配置：这些变量可以被菜单修改，所以它们不是 'final'。
  int _gridWidth = 9;
  int _gridHeight = 9;
  int _mines = 10;

  // initState() 是 State生命周期中的第一个方法，在 Widget 被插入到树中时只调用一次。
  // 它是执行所有初始化逻辑的最佳位置。
  @override
  void initState() {
    super.initState(); // 必须先调用父类的 initState
    _initializeGame(); // 调用我们自己的初始化函数
  }

  // --- 核心逻辑函数区 ---
  // 这里存放所有处理游戏逻辑和状态变化的方法。

  // 初始化或重置游戏。这个函数会在游戏开始和每次点击“重新开始”时被调用。
  void _initializeGame() {
    // 创建一个新的 GameService 实例，这会通过 FFI 调用 C++ 的 create_game。
    _gameService = GameService(width: _gridWidth, height: _gridHeight, mines: _mines);
    // 从 C++ 核心获取初始的棋盘状态。
    _boardState = _gameService.getBoardState();
    // 重置所有与本局游戏相关的状态。
    _isFirstTap = true;
    _stopTimer();
    _secondsElapsed = 0;
  }

  // 启动计时器。
  void _startTimer() {
    if (_timer != null) return; // 如果计时器已经在运行，就什么都不做。
    // Timer.periodic 创建一个重复性的定时器，每隔一秒执行一次回调函数。
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // setState() 是通知 Flutter 框架：“嘿，有状态改变了，请重绘界面！”
      setState(() {
        _secondsElapsed++; // 秒数加一
      });
    });
  }

  // 停止并销毁计时器。
  void _stopTimer() {
    _timer?.cancel(); // '?' 是空安全操作符，如果 _timer 不为空，就调用 cancel()。
    _timer = null; // 把 _timer 变量重置为 null，表示当前没有计时器在运行。
  }

  // 处理左键点击 -> 揭开格子。
  void _handleTileTap(int index) {
    if (_gameService.isGameOver() || _gameService.isGameWon()) return;

    // 如果是本局的第一次有效点击，就启动计时器。
    if (_isFirstTap) {
      _startTimer();
      _isFirstTap = false;
    }

    // 计算被点击格子的二维坐标。
    int x = index % _gridWidth;
    int y = index ~/ _gridWidth;

    // 再次调用 setState() 来触发UI更新。
    setState(() {
      _gameService.revealCell(x, y); // 通过 FFI 调用 C++ 的揭开逻辑。
      _boardState = _gameService.getBoardState(); // 获取 C++ 处理后的最新棋盘状态。
    });

    _checkGameStatus(); // 每次点击后都检查一下游戏是否结束。
  }

  // 处理右键点击 -> 插旗。
  void _handleTileFlag(int index) {
    if (_gameService.isGameOver() || _gameService.isGameWon()) return;
    if (_isFirstTap) return; // 规则：不允许第一次点击就是插旗。

    int x = index % _gridWidth;
    int y = index ~/ _gridHeight;

    setState(() {
      _gameService.flagCell(x, y); // 调用 C++ 的插旗逻辑。
      _boardState = _gameService.getBoardState(); // 获取最新状态。
    });

    _checkGameStatus(); // 每次插旗后也检查是否胜利。
  }

  // 检查游戏是否结束的统一入口。
  void _checkGameStatus() {
    if (_gameService.isGameOver() || _gameService.isGameWon()) {
      _stopTimer(); // 游戏结束，立刻停止计时。
      // 延迟一小段时间再显示弹窗，让用户能看清最后一步的操作结果。
      Future.delayed(const Duration(milliseconds: 100), () {
        _showGameOverDialog(_gameService.isGameWon() ? "恭喜你，游戏胜利！" : "你踩到雷了！");
      });
    }
  }

  // 显示游戏结束的对话框。
  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击弹窗外部来关闭它。
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("游戏结束"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("重新开始"),
              onPressed: () {
                setState(() {
                  _gameService.dispose(); // 销毁旧的 C++ 游戏实例。
                  _initializeGame();    // 创建一个全新的游戏实例。
                });
                Navigator.of(dialogContext).pop(); // 关闭弹窗。
              },
            ),
          ],
        );
      },
    );
  }

  // 显示自定义游戏设置的对话框。
  void _showCustomGameDialog() {
    // TextEditingController 用于管理输入框的文本。
    final widthController = TextEditingController(text: _gridWidth.toString());
    final heightController = TextEditingController(text: _gridHeight.toString());
    final minesController = TextEditingController(text: _mines.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("自定义游戏"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widthController,
                decoration: const InputDecoration(labelText: "宽度 (9-40)"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: "高度 (9-20)"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: minesController,
                decoration: const InputDecoration(labelText: "雷数 (最少 10)"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(child: const Text("取消"), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text("开始"),
              onPressed: () {
                _gridWidth = int.tryParse(widthController.text) ?? 9;
                _gridHeight = int.tryParse(heightController.text) ?? 9;
                _mines = int.tryParse(minesController.text) ?? 10;
                setState(() {
                  _gameService.dispose();
                  _initializeGame();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 格式化时间输出
  String _formatDuration(int totalSeconds) {
    // 1. 使用秒数创建一个 Duration 对象。
    final duration = Duration(seconds: totalSeconds);

    // 2. 将 Duration 转换为 "h:mm:ss.micros" 格式的字符串。
    //    例如，70 秒会变成 "0:01:10.000000"
    String s = duration.toString();

    // 3. 我们不想要小数点后面的微秒，所以我们用 '.' 来分割字符串，
    //    并只取第一部分。
    //    "0:01:10.000000" -> "0:01:10"
    String withoutMicros = s.split('.')[0];

    // 4. 现在，我们用 ':' 来分割 "h:mm:ss" 字符串，得到一个部分列表。
    //    "0:01:10" -> ["0", "01", "10"]
    List<String> parts = withoutMicros.split(':');

    // 5. 【核心】为每个部分补上前面的 '0'，确保总是两位数。
    //    padLeft(2, '0') 的意思是：“如果字符串长度不足 2，就在左边用 '0' 来填充。”
    //    "0" -> "00"
    //    "1" -> "01"
    //    "10" -> "10"
    String hours = parts[0].padLeft(2, '0');
    String minutes = parts[1].padLeft(2, '0');
    String seconds = parts[2].padLeft(2, '0');

    // 6. 最后，用 ':' 把它们重新组合起来，并返回最终的完美格式。
    return "$hours:$minutes:$seconds";
  }

  // --- UI 构建区 ---
  // build() 方法是 State 的核心，它负责根据当前的状态，“描述”出界面应该长什么样。
  @override
  Widget build(BuildContext context) {

// 1. 获取整个窗口可用的“画布”尺寸
    //    MediaQuery.of(context).size 是整个窗口的大小
    final Size screenSize = MediaQuery.of(context).size;
    //    AppBar().preferredSize.height 是 AppBar 的标准高度
    final double appBarHeight = AppBar().preferredSize.height;
    //    MediaQuery.of(context).padding.top 是顶部安全区域（比如刘海）的高度
    final double topPadding = MediaQuery.of(context).padding.top;
    //    我们从总高度中减去 AppBar 和安全区域，得到 body 部分的实际可用高度
    final double availableHeight = screenSize.height - appBarHeight - topPadding;
    final double availableWidth = screenSize.width;

    // 2. 【核心】定义我们的“缩放比例”
    //    这个值代表棋盘最多可以占据可用空间的 85%。
    //    剩下的 15% 就会自动成为我们的动态留白！
    //    你可以随时把这个值改成 0.9 或 0.8 来调整留白大小。
    const double scaleFactor = 0.78;

    // 3. 获取棋盘自身的宽高比
    final double boardAspectRatio = _gridWidth / _gridHeight;

    // 4. 【核心算法】根据可用空间和棋盘比例，计算出棋盘的尺寸
    double finalBoardWidth;
    double finalBoardHeight;

    // 这个 if/else 逻辑和之前完全一样，它负责保持棋盘的正确形状
    if (availableWidth / availableHeight > boardAspectRatio) {
      // 可用空间比棋盘“更宽”，以高度为基准
      finalBoardHeight = availableHeight * scaleFactor; // 直接乘以缩放比例
      finalBoardWidth = finalBoardHeight * boardAspectRatio;
    } else {
      // 可用空间比棋盘“更高”，以宽度为基准
      finalBoardWidth = availableWidth * scaleFactor; // 直接乘以缩放比例
      finalBoardHeight = finalBoardWidth / boardAspectRatio;
    }
    // 在 build 方法的开头，获取当前的主题
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    // Scaffold 是一个 Material Design 的基本页面布局结构。
    return Scaffold(
      backgroundColor: theme.background,

      // AppBar 是顶部的应用栏。
      appBar: AppBar(
        // 【核心修正】这里是完整的 AppBar，连接了所有的状态数据和功能按钮。

        leading: IconButton(
          // 1. 按钮的图标会根据当前主题动态变化。
          icon: Icon(
            // 如果当前是暗黑模式，就显示“切换到亮色”的太阳图标。
            theme.brightness == Brightness.dark
                ? Icons.light_mode
            // 否则（是亮色模式），就显示“切换到暗黑”的月亮图标。
                : Icons.dark_mode,
            // 让图标的颜色也能适应主题
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: '切换主题', // 鼠标悬停时的提示文字
          // 2. 按钮的点击事件：onPressed
          onPressed: () {
            // 通过 Provider 找到 ThemeProvider，并调用它的 toggleTheme 方法。
            // 'listen: false' 是一个优化，因为这个按钮本身不需要根据主题重绘。
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),

        // title 现在是一个 Row，可以在横向上排列多个 Widget。
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 让子元素两端对齐。
          children: [
            // 实时显示剩余雷数。
            // 使用 .where() 方法筛选出所有被插旗的格子，然后用 .length 获取数量。
            Text('💣 ${_mines - _boardState.where((t) => t.isFlagged).length}'),
            // 实时显示游戏时间。
            Text('⏰ ${_formatDuration(_secondsElapsed)}'),
          ],
        ),
        backgroundColor: theme.surface,
        // actions 属性允许我们在 AppBar 的右侧放置按钮。
        actions: [
          // 刷新按钮。
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _gameService.dispose();
                _initializeGame();
              });
            },
          ),
          // 难度选择菜单。
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'easy') { _gridWidth = 9; _gridHeight = 9; _mines = 10; }
              if (value == 'medium') { _gridWidth = 16; _gridHeight = 16; _mines = 40; }
              if (value == 'hard') { _gridWidth = 30; _gridHeight = 16; _mines = 99; }
              if (value == 'custom') {
                _showCustomGameDialog();
                return; // 调用弹窗后提前返回，避免多余的 setState。
              }
              // 对于预设难度，直接重置游戏。
              setState(() {
                _gameService.dispose();
                _initializeGame();
              });
            },
            // itemBuilder 负责构建菜单里的选项。
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'easy', child: Text('简单 (9x9, 10 雷)')),
              const PopupMenuItem<String>(value: 'medium', child: Text('中等 (16x16, 40 雷)')),
              const PopupMenuItem<String>(value: 'hard', child: Text('困难 (30x16, 99 雷)')),
              const PopupMenuDivider(), // 一条分割线。
              const PopupMenuItem<String>(value: 'custom', child: Text('自定义...')),
            ],
          ),
        ],
      ),
      body: Center(
        // 我们用一个 SizedBox 来精确地控制棋盘的最终尺寸
        child: SizedBox(
          width: finalBoardWidth,
          height: finalBoardHeight,
          child: GameBoard(
            gridWidth: _gridWidth,
            gridHeight: _gridHeight,
            boardState: _boardState,
            onTileTap: _handleTileTap,
            onTileFlag: _handleTileFlag,
          ),
        ),
      ),
    );
  }

  // dispose() 是 State 生命周期的最后一个方法，在 Widget 被永久移除时调用。
  // 我们必须在这里清理所有资源，防止内存泄漏。
  @override
  void dispose() {
    _stopTimer(); // 确保计时器被销毁。
    _gameService.dispose(); // 确保 C++ 游戏实例被销毁。
    super.dispose(); // 必须调用父类的 dispose。
  }
}
