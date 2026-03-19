import 'package:flutter/material.dart';

class ChatMainScreen extends StatelessWidget {
  const ChatMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Đây là màn hình Trò chuyện (Tab 2)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}