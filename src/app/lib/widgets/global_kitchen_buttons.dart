import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:app/helpers/theming.dart';

class GlobalKitchenActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const GlobalKitchenActionButton._({
    this.onPressed,
    required this.child,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: enabled ? 1 : 0.5,
        child: Material(
          type: MaterialType.button,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(20),
          color:
              backgroundColor ?? Theme.of(context).colorScheme.secondaryNetrual,
          child: IconTheme(
            data: IconThemeData(
              color: foregroundColor ??
                  Theme.of(context).textTheme.bodyLarge!.color,
            ),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: foregroundColor,
                  ),
              child: InkWell(
                onTap: onPressed,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  factory GlobalKitchenActionButton.icon({
    required VoidCallback onPressed,
    required Widget child,
    bool enabled = true,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return GlobalKitchenActionButton._(
      enabled: enabled,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(width: 60, height: 40),
        child: Center(child: child),
      ),
    );
  }

  factory GlobalKitchenActionButton.expanded(
    BuildContext context, {
    required VoidCallback onPressed,
    required Widget leading,
    required String text,
    bool enabled = true,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return GlobalKitchenActionButton._(
      onPressed: onPressed,
      enabled: enabled,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints.tightFor(height: 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(10),
            IconTheme(
              data: IconThemeData(
                size: 20,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              child: leading,
            ),
          ],
        ),
      ),
    );
  }
}

class GlobalKitchenPushButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;

  const GlobalKitchenPushButton._({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  factory GlobalKitchenPushButton.accent({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    bool primary = false,
    BorderRadius? borderRadius,
    Key? key,
  }) {
    return GlobalKitchenPushButton._(
      key: key,
      onPressed: onPressed,
      backgroundColor: primary
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.secondaryNetrual,
      foregroundColor:
          primary ? Theme.of(context).scaffoldBackgroundColor : null,
      borderRadius: borderRadius,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.button,
      color: backgroundColor ?? Theme.of(context).colorScheme.secondaryNetrual,
      clipBehavior: Clip.antiAlias,
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(minHeight: 50),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: foregroundColor,
                ),
            textAlign: TextAlign.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
