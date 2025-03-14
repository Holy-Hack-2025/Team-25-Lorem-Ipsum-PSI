import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:app/helpers/theming.dart';

class SlimListTile extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? details;
  final bool large;
  final EdgeInsets? padding;

  final VoidCallback? onTap;

  const SlimListTile({
    super.key,
    required this.title,
    this.details,
    this.leading,
    this.trailing,
    this.onTap,
    this.large = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment:
                large ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const Gap(20)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!,
                      child: title,
                    ),
                    if (details != null) ...[
                      const Gap(5),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium50!,
                        child: details!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const Gap(20), trailing!],
            ],
          ),
        ),
      ),
    );
  }

  factory SlimListTile.icon(
    BuildContext context, {
    Widget? details,
    required Widget title,
    required Widget icon,
    double iconSize = 50,
    Widget? trailing,
    VoidCallback? onTap,
    bool large = false,
    Color? iconColor,
    EdgeInsets? padding,
  }) {
    return SlimListTile(
      title: title,
      details: details,
      large: large,
      leading: ExcludeSemantics(
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints.tight(Size.square(iconSize)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor ?? Theme.of(context).colorScheme.secondaryNetrual,
          ),
          child: icon,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      padding: padding,
    );
  }
}
