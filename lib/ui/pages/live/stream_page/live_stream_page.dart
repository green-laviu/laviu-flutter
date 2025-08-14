import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_body.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({super.key});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiveStreamBody(scrollCtrl: _scrollCtrl, msgCtrl: _msgCtrl),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -40),
        child: MDevFloatingBtn(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
