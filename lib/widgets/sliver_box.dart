import 'package:flutter/cupertino.dart';

class SliverBox extends StatelessWidget {
  const SliverBox({
    Key? key,
    this.maxHeight = double.maxFinite,
    this.maxWidth = double.maxFinite,
    required this.child,
  }) : super(key: key);

  final double maxHeight;
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: LimitedBox(
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        child: child,
      ),
    );
  }
}