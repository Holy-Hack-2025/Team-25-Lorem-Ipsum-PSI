import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:app/helpers/theming.dart';
import 'package:sliver_tools/sliver_tools.dart';

enum SheetHeaderType { primary, secondary }

class SliverSheetHeader extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? details;
  final SheetHeaderType type;
  final bool pinned;
  final Decoration? decoration;
  final double offset;

  final VoidCallback? onTap;

  const SliverSheetHeader({
    super.key,
    required this.title,
    this.leading,
    this.details,
    this.type = SheetHeaderType.primary,
    this.pinned = false,
    this.decoration,
    this.onTap,
    this.offset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final column = Transform.translate(
      offset: Offset(0, -offset),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20)
            .add(EdgeInsets.only(top: offset)),
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: leading!,
              ),
              const Gap(20),
            ],
            Semantics(
              header: true,
              button: true,
              child: InkWell(
                onTap: onTap,
                child: DefaultTextStyle(
                  style: switch (type) {
                    SheetHeaderType.secondary =>
                      Theme.of(context).textTheme.headlineSmall!,
                    _ => Theme.of(context).textTheme.headlineMedium!,
                  },
                  child: title,
                ),
              ),
            ),
            if (details != null) ...[
              const Gap(20),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium50!,
                child: details!,
              ),
            ],
          ],
        ),
      ),
    );

    if (pinned) return SliverPinnedHeader(child: column);
    return SliverToBoxAdapter(child: column);
  }
}
