import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/widgets/my_update_form.dart';

class MyUpdateBody extends StatelessWidget {
  const MyUpdateBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.directional(start: MSizes.gapL, end: MSizes.gapL, bottom: MSizes.gapXL),
      child: MyUpdateForm(),
    );
  }
}
