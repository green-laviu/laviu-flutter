import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';

class MyUpdateProfileImgBtn extends StatelessWidget {
  const MyUpdateProfileImgBtn({super.key});

  @override
  Widget build(BuildContext context) {
    const String imgUrl = "https://picsum.photos/200";
    const double badge = 24; // + 배지 지름

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () {
          // TODO: 이미지 액션 시트
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: MSizes.radiusHuge * 2,
              backgroundColor: MColors.fillNormal,
              foregroundImage: NetworkImage(imgUrl),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: badge,
                height: badge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MColors.white,
                    width: 2.0,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: MSizes.iconS,
                  color: MColors.lineNormal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
