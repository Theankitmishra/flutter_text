import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Text Styling Demo',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.themeMode,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust animation duration as needed
    );
    _animation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward(); // Start the animation
    // Navigate to the main screen after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TextStylingDemo()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              width: _animation.value,
              height: _animation.value,
              child: Image.asset(
                'assets/logo.png', // Replace with your image asset path
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}

class TextStylingDemo extends StatefulWidget {
  @override
  _TextStylingDemoState createState() => _TextStylingDemoState();
}

class _TextStylingDemoState extends State<TextStylingDemo> {
  double _fontSize = 20.0;
  String _selectedFont = 'Roboto';
  int _currentColorIndex = 0;
  Offset _offset = Offset(0, 0);
  String _editedText = 'Drag me';

  final List<Map<String, dynamic>> _fontStyles = [
    {'name': 'Roboto', 'style': TextStyle(fontFamily: 'Roboto')},
    {'name': 'Arial', 'style': TextStyle(fontFamily: 'Arial')},
    {'name': 'Courier', 'style': TextStyle(fontFamily: 'Courier')},
    {'name': 'Verdana', 'style': TextStyle(fontFamily: 'Verdana')},
    {
      'name': 'Times New Roman',
      'style': TextStyle(fontFamily: 'Times New Roman')
    },
    {'name': 'Georgia', 'style': TextStyle(fontFamily: 'Georgia')},
    {'name': 'Helvetica', 'style': TextStyle(fontFamily: 'Helvetica')},
  ];

  final List<Color> _textColors = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
  ];

  List<Map<String, dynamic>> _textStyleHistory = [];
  int _historyIndex = -1;

  void initState() {
    super.initState();
    // Adjust the initial offset to the top center of the container
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _offset = Offset(
            MediaQuery.of(context).size.width / 2 -
                _editedText.length * _fontSize / 4,
            50);
      });
    });
  }

  void _updateHistory() {
    if (_historyIndex < _textStyleHistory.length - 1) {
      _textStyleHistory.removeRange(
          _historyIndex + 1, _textStyleHistory.length);
    }

    _textStyleHistory.add({
      'fontSize': _fontSize,
      'selectedFont': _selectedFont,
      'currentColorIndex': _currentColorIndex,
      'offset': _offset,
      'editedText': _editedText,
    });

    _historyIndex++;
  }

  void _updateOffset(Offset newOffset) {
    setState(() {
      _offset = newOffset;
      _updateHistory();
    });
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        var lastState = _textStyleHistory[_historyIndex];
        _fontSize = lastState['fontSize'];
        _selectedFont = lastState['selectedFont'];
        _currentColorIndex = lastState['currentColorIndex'];
        _offset = lastState['offset'];
        _editedText = lastState['editedText'];
      });
    }
  }

  void _redo() {
    if (_historyIndex < _textStyleHistory.length - 1) {
      setState(() {
        _historyIndex++;
        var nextState = _textStyleHistory[_historyIndex];
        _fontSize = nextState['fontSize'];
        _selectedFont = nextState['selectedFont'];
        _currentColorIndex = nextState['currentColorIndex'];
        _offset = nextState['offset'];
        _editedText = nextState['editedText'];
      });
    }
  }

  void _increaseFontSize() {
    setState(() {
      _updateHistory();
      _fontSize += 2.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _updateHistory();
      _fontSize -= 2.0;
      if (_fontSize < 0) _fontSize = 0;
    });
  }

  void _setFont(String? font) {
    setState(() {
      _updateHistory();
      if (font != null) {
        _selectedFont = font;
      }
    });
  }

  void _changeTextColor() {
    setState(() {
      _updateHistory();
      _currentColorIndex = (_currentColorIndex + 1) % _textColors.length;
    });
  }

  void _editText() {
    showDialog(
      context: context,
      builder: (context) {
        String newText = _editedText;
        return AlertDialog(
          title: Text('Edit Text'),
          content: TextField(
            onChanged: (value) {
              newText = value;
            },
            controller: TextEditingController(text: newText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _updateHistory();
                  _editedText = newText;
                  Navigator.of(context).pop();
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Text Styling'),
      ),
      body: Stack(
        children: [
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: GestureDetector(
              onTap: _editText,
              child: Draggable(
                feedback: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _editedText,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontFamily: _selectedFont,
                      color: _textColors[_currentColorIndex],
                    ),
                  ),
                ),
                childWhenDragging: Container(),
                child: Text(
                  _editedText,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontFamily: _selectedFont,
                    color: _textColors[_currentColorIndex],
                  ),
                ),
                onDraggableCanceled: (velocity, offset) {
                  _updateOffset(offset);
                },
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: _decreaseFontSize,
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _increaseFontSize,
                    ),
                    IconButton(
                      icon: Icon(Icons.undo),
                      onPressed: _undo,
                    ),
                    IconButton(
                      icon: Icon(Icons.redo),
                      onPressed: _redo,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton<Map<String, dynamic>>(
                      value: _fontStyles.firstWhere(
                          (style) => style['name'] == _selectedFont),
                      onChanged: (value) => _setFont(value?['name']),
                      items: _fontStyles.map((style) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: style,
                          child: Text(
                            style['name'],
                            style: style['style'],
                          ),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: _changeTextColor,
                      child: Text('Change Text Color'),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
