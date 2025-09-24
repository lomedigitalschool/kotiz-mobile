import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfilTile extends StatelessWidget {
  const ProfilTile({
    super.key,
    required this.type,
    required this.icon,
    this.content,
    this.endIcon = const Icon(LucideIcons.penLine400),
    this.showPen = true,
    this.widget = const SizedBox(),
  });
  final String type;
  final String? content;
  final Icon icon;
  final Icon endIcon;
  final bool showPen;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
          color: Color(0xffE8EDF2),
          margin: EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(padding: const EdgeInsets.all(28.0), child: icon),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
            if (content != null)
              Text(
                content!,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 19),
              ),
          ],
        ),
        const Spacer(),
        if (showPen) const Icon(LucideIcons.penLine),
        if (showPen == false) widget,
      ],
    );
  }
}
