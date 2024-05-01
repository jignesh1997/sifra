import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyMagicPromptWidget extends StatelessWidget {


  CopyMagicPromptWidget();

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(const ClipboardData(text: "Add file location at top: something like this ``// pathtocreate/subpath/filename.extension``."));
    // Optional: Show a snackbar or toast to indicate that the text has been copied
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Text copied to clipboard')),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copyToClipboard,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text(
                "Copy magic prompt",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Add at the end of your prompt",
                style: TextStyle(fontSize: 10,color: Colors.red),
              ),
            ],
          ),
          SizedBox(width: 8),
          Icon(
            Icons.copy,
            size: 20,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}