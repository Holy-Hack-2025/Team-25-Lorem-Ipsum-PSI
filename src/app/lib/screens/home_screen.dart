import 'package:app/helpers/theming.dart';
import 'package:app/providers/saus.dart';
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
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What would you like to eat?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(40),
            FutureBuilder(
              future: _preprartionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                }

                return TextField(
                  onSubmitted: (value) async {
                    if (value.isEmpty) return;

                    _preprartionFuture = context.read<SausProvider>().ideate(
                      value,
                    );

                    setState(() {});

                    final (title, description) = await _preprartionFuture;
                    print('$title: $description');

                    if (!context.mounted) return;
                    context.push('/builder', extra: (title, description));
                  },
                  decoration: InputDecoration(
                    hintText: 'Describe your meal',
                    hintStyle: Theme.of(context).textTheme.bodyLarge50,
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
