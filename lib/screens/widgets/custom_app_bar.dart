import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isAlwaysOnTop = false;

  @override
  void initState() {
    super.initState();
    _initializeAlwaysOnTop();
  }

  Future<void> _initializeAlwaysOnTop() async {
    isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    setState(() {});
  }

  Future<void> _toggleAlwaysOnTop() async {
    isAlwaysOnTop = !isAlwaysOnTop;
    await windowManager.setAlwaysOnTop(isAlwaysOnTop);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        IconButton(
          icon: Icon(isAlwaysOnTop ? Icons.lock : Icons.lock_open),
          onPressed: _toggleAlwaysOnTop,
        ),
      ],
    );
  }
}