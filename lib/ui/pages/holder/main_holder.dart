import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/holder/following/following_page.dart';
import 'package:laviu_flutter/ui/pages/holder/home/home_page.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/my_detail_page.dart';

class MainHolder extends StatefulWidget {
  @override
  State<MainHolder> createState() => _MainHolderState();
}

class _MainHolderState extends State<MainHolder> {
  int selectedIndex = 0;
  List<int> loadPages = [0];

  void selectedBottomMenu(int index) {
    if (!loadPages.contains(index)) {
      loadPages.add(index);
    }

    selectedIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          loadPages.contains(0) ? const HomePage() : Container(),
          loadPages.contains(1) ? const FollowingPage() : Container(),
          loadPages.contains(2) ? const MyDetailPage() : Container(),
          // loadPages.contains(3) ? const UserDetailPage() : Container(),
          // loadPages.contains(4) ? const NotificationPage() : Container(),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      currentIndex: selectedIndex,
      onTap: selectedBottomMenu,
      selectedLabelStyle: MText.label2Bold(color: MColors.textNeutral),
      unselectedLabelStyle: MText.label2Regular(color: MColors.textAlternative),
      selectedItemColor: MColors.textNeutral,
      unselectedItemColor: MColors.textAlternative,
      selectedIconTheme: IconThemeData(color: MColors.primaryStrong),
      unselectedIconTheme: IconThemeData(color: MColors.textAlternative),
      items: [
        BottomNavigationBarItem(
          label: "홈",
          icon: Icon(Icons.home_filled),
        ),
        BottomNavigationBarItem(
          label: "팔로잉",
          icon: Icon(CupertinoIcons.heart_fill),
        ),
        BottomNavigationBarItem(
          label: "MY",
          icon: Icon(CupertinoIcons.profile_circled),
        ),
      ],
    );
  }
}
