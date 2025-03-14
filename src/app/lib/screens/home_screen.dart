import 'package:app/helpers/theming.dart';
import 'package:app/providers/kitchen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future? _preprartionFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What would you like to eat?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(30),
            FutureBuilder(
              future: _preprartionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                }

                return TextField(
                  onSubmitted: (value) async {
                    if (value.isEmpty) return;

                    final description = await context
                        .read<KitchenProvider>()
                        .ideate(value);

                    setState(() {});

                    print('Got description: $description');

                    if (!context.mounted) return;
                    context.push('/builder', extra: description);
                  },
                  decoration: InputDecoration(
                    labelText: 'pizza, sushi, etc.',
                    labelStyle: Theme.of(context).textTheme.bodyLarge50,
                    filled: true,
                    fillColor: const Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
