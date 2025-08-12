import 'package:flutter/material.dart';

class LivePreviewPage extends StatelessWidget {
  const LivePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이브 미리보기')),
      body: const Center(child: Text('라이브 미리보기 준비중...')),
    );
  }
}
