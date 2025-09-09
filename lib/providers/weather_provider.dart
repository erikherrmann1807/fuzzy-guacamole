import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fuzzy_guacamole/services/location_service.dart';
import 'package:fuzzy_guacamole/weather/weather_repository.dart';
import 'package:geolocator/geolocator.dart';

final weatherRepoProvider = Provider<WeatherApiComRepo>((ref) {
  final keyFromEnv = dotenv.env['WEATHER_KEY'];
  final key = (keyFromEnv != null && keyFromEnv.isNotEmpty)
      ? keyFromEnv
      : const String.fromEnvironment('WEATHER_KEY', defaultValue: '');
  if (key.isEmpty) {
    throw StateError('WEATHER_KEY fehlt. In .env setzen oder via --dart-define übergeben.');
  }
  return WeatherApiComRepo(key);
});

/*Variante A: feste Stadt
final weatherProvider = FutureProvider<WeatherInfo>((ref) async {
  return ref.read(weatherRepoProvider).currentByQuery('Berlin'); // <- Stadt anpassen
});
 */

//Variante B (optional): Koordinaten
final weatherProvider = FutureProvider<WeatherInfo>((ref) async {
  final pos = await ref.watch(positionProvider.future);
  return ref.read(weatherRepoProvider).currentByCoords(pos.latitude, pos.longitude);
});

final positionProvider = FutureProvider<Position>((ref) async {
  return LocationService.currentPosition();
});


