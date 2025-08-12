import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/notification/widgets/notification_item.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 수신함', style: MText.heading2(color: MColors.textNormal)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1),
        ),
      ),
      body: ListView(
        children: [
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
          NotificationItem(),
        ],
      ),
    );
  }
}
