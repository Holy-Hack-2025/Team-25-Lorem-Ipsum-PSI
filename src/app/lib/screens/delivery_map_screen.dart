import 'package:app/helpers/theming.dart';
import 'package:app/models/meal.dart';
import 'package:app/widgets/global_kitchen_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';

class DeliveryMapScreen extends StatelessWidget {
  final MealIdea idea;

  const DeliveryMapScreen(this.idea, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalKitchenAppBar(title: Text('Delivery map')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(50.88876394917783, 4.696213598712482),
              initialZoom: 16,
              interactionOptions: InteractionOptions(
                flags:
                    InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(50.88876394917783, 4.696213598712482),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(TablerIcons.truck_delivery, size: 42),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '8 minutes away',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Gap(10),
                    Text(
                      'Your meal is on its way!',
                      style: Theme.of(context).textTheme.bodyMedium50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
