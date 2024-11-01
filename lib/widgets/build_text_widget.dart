import 'package:flutter/material.dart';

class BuildTextWidget extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  const BuildTextWidget({
    super.key,
    this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "", overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: style,
    );
  }
}
