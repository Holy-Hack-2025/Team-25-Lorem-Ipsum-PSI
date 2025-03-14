import 'dart:math';
import 'dart:ui';

import 'package:app/helpers/theming.dart';
import 'package:app/models/meal.dart';
import 'package:app/providers/saus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MealBuilderScreen extends StatefulWidget {
  final String initialDescription;

  const MealBuilderScreen({super.key, required this.initialDescription});

  @override
  State<MealBuilderScreen> createState() => _MealBuilderScreenState();
}

class _MealBuilderScreenState extends State<MealBuilderScreen> {
  final _promptController = TextEditingController();
  late String _description = widget.initialDescription;

  String? title;
  Uint8List? _imageBytes;
  List<String> _suggestions = [];

  bool _isProcessing = false;

  @override
  void initState() {
    _fetchImage();
    _fetchSuggestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: buildTheme(context, brightness: Brightness.dark),
        child: Builder(builder: _buildView),
      ),
    );
  }

  Widget _buildView(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Column(
            children: [
              MealBuilderHeading(
                title: Text('Build your meal'),
                subtitle: const Text(
                  'Make sure it will match your preference.',
                ),
              ),
              const Gap(20),
              Expanded(
                child: Center(
                  child: PlateOrchestra(
                    imageBytes: _imageBytes,
                    suggestions: _suggestions,
                    isProcessing: _isProcessing,
                    onSuggestionTap: (value) async {
                      _description = await context.read<SausProvider>().modify(
                        _description,
                        'Add $value',
                      );

                      _fetchImage();
                      _fetchSuggestions();
                    },
                    onPlateTap: () {
                      if (_imageBytes == null) return;

                      context.go(
                        '/create',
                        extra: MealIdea(
                          description: _description,
                          imageBytes: _imageBytes!,
                          title: 'No Name',
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Gap(20),
              TextField(
                controller: _promptController,
                onSubmitted: (value) async {
                  if (value.isEmpty) return;
                  _promptController.clear();

                  _description = await context.read<SausProvider>().modify(
                    _description,
                    value,
                  );
                  _fetchSuggestions();
                  _fetchImage();
                },
                decoration: InputDecoration(
                  labelText: 'Make any changes...',
                  labelStyle: Theme.of(context).textTheme.bodyMedium50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Gap(20),
              Text(
                'Tap on the plate when you\'re finished.',
                style: Theme.of(context).textTheme.labelLarge50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchImage() async {
    setState(() => _isProcessing = true);

    final response = await context.read<SausProvider>().imagine(_description);

    setState(() {
      _isProcessing = false;
      _imageBytes = response;
    });
  }

  void _fetchSuggestions() async {
    final suggestions = await context.read<SausProvider>().fetchSuggestions(
      _description,
    );

    setState(() {
      _suggestions = suggestions;
    });
  }
}

class PlateOrchestra extends StatefulWidget {
  final Uint8List? imageBytes;
  final List<String> suggestions;
  final void Function(String suggestion)? onSuggestionTap;
  final VoidCallback? onPlateTap;
  final bool isProcessing;

  const PlateOrchestra({
    super.key,
    required this.suggestions,
    this.isProcessing = false,
    this.imageBytes,
    this.onSuggestionTap,
    this.onPlateTap,
  });

  @override
  State<PlateOrchestra> createState() => _PlateOrchestraState();
}

class _PlateOrchestraState extends State<PlateOrchestra>
    with TickerProviderStateMixin {
  late final _suggestionController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late final _suggestionCurve = CurvedAnimation(
    parent: _suggestionController,
    curve: Curves.easeOutCubic,
  );

  int? _currentAnimationIndex;

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlateOrchestra oldWidget) {
    if (widget.suggestions != oldWidget.suggestions) {
      _currentAnimationIndex = null;
      _suggestionController.animateTo(0, curve: Curves.easeOutCubic);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(children: [_buildPlateLayer(), _buildSuggestionsLayer()]),
    );
  }

  Widget _buildPlateLayer() {
    return GestureDetector(
      onTap: widget.onPlateTap,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: widget.isProcessing ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: SizedBox.fromSize(
                size: const Size.square(10),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.grey),
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0, end: widget.isProcessing ? 0 : 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 10 * (1 - value),
                    sigmaY: 10 * (1 - value),
                  ),
                  child: Transform.scale(
                    scale: value * 0.2 + 0.8,
                    child: Opacity(opacity: value, child: child),
                  ),
                );
              },
              child: ClipOval(
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Hero(
                    tag: 'meal-image',
                    child: AspectRatio(
                      aspectRatio: 1,
                      child:
                          widget.imageBytes != null
                              ? Image.memory(
                                widget.imageBytes!,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                'assets/plate.png',
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsLayer() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Stack(
        key: ValueKey(widget.suggestions),
        children: [
          for (final suggestion in widget.suggestions)
            _buildPlateSuggestions(
              suggestion,
              onAnimationStart: () => widget.onSuggestionTap?.call(suggestion),
            ),
        ],
      ),
    );
  }

  Widget _buildPlateSuggestions(
    String suggestion, {
    VoidCallback? onAnimationStart,
    VoidCallback? onAnimationEnd,
  }) {
    final index = widget.suggestions.indexOf(suggestion);

    return AnimatedBuilder(
      animation: _suggestionController,
      builder: (context, child) {
        final position =
            2 *
                pi *
                index /
                (widget.suggestions.length - _suggestionCurve.value) +
            pi / 3;

        final double factor =
            index == _currentAnimationIndex ? (1 - _suggestionCurve.value) : 1;

        return Opacity(
          opacity: factor,
          child: Align(
            alignment: Alignment(
              cos(position) * factor,
              sin(position) * factor,
            ),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 10 * (1 - factor),
                sigmaY: 10 * (1 - factor),
              ),
              child: child,
            ),
          ),
        );
      },
      child: MealSuggestionChip(
        suggestion: suggestion,
        onTap:
            widget.isProcessing
                ? null
                : () {
                  onAnimationStart?.call();
                  setState(() {
                    _currentAnimationIndex = index;
                    _suggestionController.forward(from: 0).then((_) {
                      onAnimationEnd?.call();
                    });
                  });
                },
      ),
    );
  }
}

class MealSuggestionChip extends StatefulWidget {
  final String suggestion;
  final VoidCallback? onTap;

  const MealSuggestionChip({super.key, required this.suggestion, this.onTap});

  @override
  State<MealSuggestionChip> createState() => _MealSuggestionChipState();
}

class _MealSuggestionChipState extends State<MealSuggestionChip>
    with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
    value: Random().nextDouble(),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            sin(_controller.value * 2 * pi) * 5,
            cos(_controller.value * 2 * pi) * 5,
          ),
          child: child,
        );
      },
      child: Material(
        clipBehavior: Clip.antiAlias,
        type: MaterialType.button,
        color: Theme.of(context).colorScheme.secondaryNetrual,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              widget.suggestion.toLowerCase(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class MealBuilderHeading extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;

  const MealBuilderHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle(
          style: Theme.of(context).textTheme.headlineMedium!,
          textAlign: TextAlign.center,
          child: title,
        ),
        if (subtitle != null) ...[
          const Gap(20),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium50!,
            textAlign: TextAlign.center,
            child: subtitle!,
          ),
        ],
      ],
    );
  }
}
