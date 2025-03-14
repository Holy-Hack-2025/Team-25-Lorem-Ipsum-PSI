import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:app/widgets/global_kitchen_buttons.dart';
import 'package:sliver_tools/sliver_tools.dart';

class GlobalKitchenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;

  final Color? foregroundColor;
  final BoxDecoration? decoration;
  final CustomClipper<Path>? clipper;
  final bool hasBackButton;

  final EdgeInsetsGeometry padding;

  const GlobalKitchenAppBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.hasBackButton = true,
    this.decoration,
    this.clipper,
  }) : assert(
          title != null || leading != null || trailing != null,
          'At least one of title, leading or trailing must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final child = AnnotatedRegion<SystemUiOverlayStyle>(
      value: switch (Theme.of(context).brightness) {
        Brightness.dark => SystemUiOverlayStyle.light,
        Brightness.light => SystemUiOverlayStyle.dark,
      },
      child: ClipPath(
        clipper: clipper,
        child: AnimatedContainer(
          decoration: decoration,
          padding: padding,
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            bottom: false,
            child: Container(
              constraints: BoxConstraints.tight(preferredSize),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.headlineSmall!,
                    textAlign: TextAlign.center,
                    child: title ?? const SizedBox(),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: DefaultTextStyle(
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: foregroundColor),
                      child: Row(
                        children: [
                          if (hasBackButton &&
                              Navigator.of(context).canPop() &&
                              leading == null)
                            GlobalKitchenActionButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              backgroundColor: Colors.grey.withAlpha(51),
                              child: const Icon(TablerIcons.arrow_left),
                            ),
                          if (leading != null) leading!,
                          const Spacer(),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (foregroundColor == null) return child;

    return IconTheme(
      data: IconThemeData(color: foregroundColor),
      child: DefaultTextStyle(
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(color: foregroundColor),
        child: child,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class SliverGlobalKitchenAppBar extends GlobalKitchenAppBar {
  const SliverGlobalKitchenAppBar({
    super.key,
    super.title,
    super.leading,
    super.trailing,
    super.foregroundColor,
    super.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.hasBackButton = true,
    super.decoration,
    super.clipper,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPinnedHeader(child: super.build(context));
  }
}
