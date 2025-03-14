import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SliverSafeAreaHeader extends StatelessWidget {
  final Color? color;

  const SliverSafeAreaHeader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).scaffoldBackgroundColor;

    return SliverPersistentHeader(
      pinned: true,
      delegate: SafeAreaHeaderDelegate(
        height: MediaQuery.of(context).padding.top,
        color: effectiveColor,
      ),
    );
  }
}

class SafeAreaHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Color color;

  const SafeAreaHeaderDelegate({required this.height, required this.color});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final factor = (shrinkOffset / height * 1.5).clamp(0.0, 1.0);

    return _RawSafeAreaHeader(factor: factor, color: color);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SafeAreaHeaderDelegate oldDelegate) {
    return oldDelegate.color != color || oldDelegate.height != height;
  }
}

class _RawSafeAreaHeader extends StatelessWidget {
  const _RawSafeAreaHeader({required this.factor, required this.color});

  final double factor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: color.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).padding.top,
        ),
        color: Color.lerp(color.withAlpha(0), color, factor),
      ),
    );
  }
}
