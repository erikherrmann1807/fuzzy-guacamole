import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/providers/weather_provider.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';

class WeatherCard extends StatelessWidget {
  final WidgetRef ref;
  const WeatherCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(),
        color: MyColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(1.5, 2),
            spreadRadius: 2,
            blurStyle: BlurStyle.solid,
          ),
        ],
      ),
      child: weatherAsync.when(
        loading: () => Row(
          children: const [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Wetter laden …'),
          ],
        ),
        error: (err, _) => Text('Fehler beim Laden: $err'),
        data: (w) => Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(w.iconUrl, width: 44, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Text('${w.tempC.round()}°', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                w.city,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
