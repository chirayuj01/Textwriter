import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:typewritertext/typewritertext.dart';

class TextEditorPage extends StatefulWidget {
  @override
  _TextEditorPageState createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedFont = 'Arial';
  double _fontSize = 16.0;
  Color _fontColor = Colors.black;
  List<TextWidget> _textWidgets = [];
  final GlobalKey _stackKey = GlobalKey();

  // Undo and Redo stack
  final List<List<TextWidget>> _undoStack = [];
  final List<List<TextWidget>> _redoStack = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TypeWriter.text('Text Editor',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25), duration: Duration(milliseconds: 50)),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xffcd9cf2), Color(0xfff6f3ff)]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextInput(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TypeWriter.text(
                  duration: Duration(milliseconds: 50),
                  'FontStyle:   ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                _buildFontSelection(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  '      FontSize selector:',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                _buildFontSizeSelector(),
              ],
            ),
            _buildColorPicker(),
            ElevatedButton(
              onPressed: _addTextWidget,
              child: Text('Add Text'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _undo,
                  child: Icon(Icons.undo),
                ),
                SizedBox(width: 240,),
                ElevatedButton(
                  onPressed: _redo,
                  child: Icon(Icons.redo),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Stack(
                    key: _stackKey,
                    children: _textWidgets,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(11.0),
      child: TextField(
        enableSuggestions: true,
        keyboardAppearance: Brightness.light,
        controller: _textController,
        decoration: InputDecoration(
          labelText: 'Enter text',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(21),
            borderSide: BorderSide(
              color: Colors.purple,
              width: 20,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontSelection() {
    return DropdownButton<String>(
      value: _selectedFont,
      onChanged: (String? newValue) {
        setState(() {
          _selectedFont = newValue!;
        });
      },
      items: <String>['Arial', 'Times New Roman', 'Courier New'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSelector() {
    return Slider(
      value: _fontSize,
      min: 10.0,
      max: 50.0,
      onChanged: (double newValue) {
        setState(() {
          _fontSize = newValue;
        });
      },
    );
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorOption(Colors.red),
        _buildColorOption(Colors.green),
        _buildColorOption(Colors.blue),
        _buildColorOption(Colors.black),
        _buildColorOption(Colors.yellow),
        _buildColorOption(Colors.white),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _fontColor = color;
        });
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(_fontColor == color ? 1.0 : 0.2),
          borderRadius: BorderRadius.circular(21),
        ),
      ),
    );
  }

  void _addTextWidget() {
    setState(() {
      _saveStateForUndo();
      _textWidgets.add(TextWidget(
        text: _textController.text,
        font: _selectedFont,
        fontSize: _fontSize,
        color: _fontColor,
        parentKey: _stackKey,
      ));
    });
    _textController.clear();
  }

  void _saveStateForUndo() {
    _undoStack.add(List.from(_textWidgets));
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _redoStack.add(List.from(_textWidgets));
        _textWidgets = _undoStack.removeLast();
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _undoStack.add(List.from(_textWidgets));
        _textWidgets = _redoStack.removeLast();
      });
    }
  }
}

class TextWidget extends StatefulWidget {
  final String text;
  final String font;
  final double fontSize;
  final Color color;
  final GlobalKey parentKey;

  TextWidget({
    required this.text,
    required this.font,
    required this.fontSize,
    required this.color,
    required this.parentKey,
  });

  @override
  _TextWidgetState createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  Offset offset = Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Draggable(
        feedback: _buildText(),
        child: _buildText(),
        childWhenDragging: Container(),
        onDragEnd: (dragDetails) {
          final RenderBox renderBox = widget.parentKey.currentContext!.findRenderObject() as RenderBox;
          final position = renderBox.globalToLocal(dragDetails.offset);
          setState(() {
            offset = position;
          });
        },
      ),
    );
  }

  Widget _buildText() {
    return Text(
      widget.text,
      style: TextStyle(
        fontFamily: widget.font,
        fontSize: widget.fontSize,
        color: widget.color,
      ),
    );
  }
}
