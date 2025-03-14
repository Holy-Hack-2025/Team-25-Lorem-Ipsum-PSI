import 'package:animate_do/animate_do.dart';
import 'package:app/helpers/theming.dart';
import 'package:app/models/meal.dart';
import 'package:app/providers/saus.dart';
import 'package:app/widgets/global_kitchen_buttons.dart';
import 'package:app/widgets/safe_area_blur_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MealCreationScreen extends StatefulWidget {
  final MealIdea idea;

  const MealCreationScreen({super.key, required this.idea});

  @override
  State<MealCreationScreen> createState() => _MealCreationScreenState();
}

class _MealCreationScreenState extends State<MealCreationScreen> {
  late final Stream<MealResult> _recipeStream = context
      .read<SausProvider>()
      .craft(widget.idea);

  @override
  dispose() {
    _recipeStream.drain();
    super.dispose();
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
      body: CustomScrollView(
        slivers: [
          SliverSafeAreaHeader(),
          SliverSafeArea(
            sliver: SliverList.list(
              children: [
                Text(
                  'Preparing “${widget.idea.title}”...',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const Gap(60),
                FractionallySizedBox(
                  widthFactor: 0.4,
                  child: Hero(
                    tag: 'meal-image',
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(
                        child: Image.memory(widget.idea.imageBytes),
                      ),
                    ),
                  ),
                ),
                const Gap(60),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Theme(
                    data: buildTheme(context, brightness: Brightness.light),
                    child: Builder(
                      builder: (context) {
                        return AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          clipBehavior: Clip.none,
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.bodyMedium!,
                            child: _buildProgressView(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Gap(30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressView() {
    return StreamBuilder<MealResult?>(
      stream: _recipeStream,
      builder: (context, snapshot) {
        print('Recipe: ${snapshot.data?.recipe}');
        print('Nutrition: ${snapshot.data?.nutritionFacts}');
        print('Cost: ${snapshot.data?.costEstimate}');

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Craft', style: Theme.of(context).textTheme.headlineSmall),
            const Gap(20),
            _buildProgressStep(
              leading: Text('1'),
              title: 'Recipe',
              subtitle: Text(
                snapshot.data?.recipe == null
                    ? 'Creating the recipe...'
                    : '${snapshot.data!.recipe!.steps.length} steps, ${snapshot.data!.recipe!.ingredients.length} ingredients',
              ),
              onTap: () {
                context.push('/recipe', extra: snapshot.data?.recipe);
              },
              inProgress: snapshot.data?.recipe == null,
            ),
            const Gap(20),
            _buildProgressStep(
              leading: Text('2'),
              title: 'Nutrition Facts',
              subtitle: Text(
                snapshot.data?.nutritionFacts == null
                    ? 'Calculating nutrition facts...'
                    : '${snapshot.data!.nutritionFacts!.totalCalories.round()} calories, ${snapshot.data!.nutritionFacts!.totalCarbs.round()} carbs',
              ),
              onTap: () {},
              inProgress: snapshot.data?.nutritionFacts == null,
            ),
            const Gap(20),
            _buildProgressStep(
              leading: Text('3'),
              title: 'Estimated Cost',
              subtitle: Text(
                snapshot.data?.costEstimate == null
                    ? 'Estimating cost...'
                    : '${snapshot.data!.costEstimate!.totalCost.toStringAsFixed(2)} €',
              ),
              onTap: () {},
              inProgress: snapshot.data?.costEstimate == null,
            ),
            if (snapshot.data?.isComplete == true) ...[
              const Gap(20),
              Divider(),
              const Gap(20),
              _buildCompletedView(snapshot.data!),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProgressStep({
    required Widget leading,
    required String title,
    VoidCallback? onTap,
    Widget? subtitle,
    bool inProgress = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints.tight(Size.square(30)),
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(200),
            ),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!,
              child:
                  inProgress
                      ? SizedBox.fromSize(
                        size: Size.square(10),
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                          strokeCap: StrokeCap.round,
                        ),
                      )
                      : leading,
            ),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                if (subtitle != null) ...[
                  const Gap(5),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyMedium50!,
                    child:
                        inProgress
                            ? Flash(
                              infinite: true,
                              duration: const Duration(seconds: 5),
                              child: subtitle,
                            )
                            : subtitle,
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const Gap(20),
            const Icon(TablerIcons.chevron_right, color: Colors.grey),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedView(MealResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Delivery', style: Theme.of(context).textTheme.headlineSmall),
        const Gap(20),
        Text('Address', style: Theme.of(context).textTheme.bodyLarge50),
        const Gap(10),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEEEEEE),
            hintText: 'Mechelsestraat 202, 3000 Leuven',
            hintStyle: Theme.of(context).textTheme.bodyMedium50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const Gap(20),
        Text('Payment', style: Theme.of(context).textTheme.bodyLarge50),
        const Gap(10),
        Row(
          children: [
            Radio(value: true, groupValue: true, onChanged: (_) {}),
            Text('Cash', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const Gap(20),
        Text('Your total', style: Theme.of(context).textTheme.bodyLarge),
        const Gap(10),
        Text(
          '${result.costEstimate!.totalCost.toStringAsFixed(2)} €',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const Gap(20),
        GlobalKitchenPushButton.accent(
          context: context,
          onPressed: () {
            context.push('/delivery', extra: widget.idea);
          },
          primary: true,
          child: Text('Order'),
        ),
      ],
    );
  }
}
