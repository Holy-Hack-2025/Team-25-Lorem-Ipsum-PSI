import 'package:flutter/material.dart';

class GlobalKitchenSheetChrome extends StatelessWidget {
  static const height = 24.0;

  final Widget child;

  const GlobalKitchenSheetChrome({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                    top: height,
                  ),
            ),
            child: child,
          ),
          _buildHandle(context),
        ],
      ),
    );
  }

  Container _buildHandle(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints.expand(height: height),
      child: Container(
        constraints: const BoxConstraints.tightFor(
          height: 4,
          width: 80,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
      ),
    );
  }
}
