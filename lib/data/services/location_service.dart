import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> currentPosition() async {
    // 1) Dienste aktiv?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // 2) Berechtigungen prüfen/anfragen
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('Standortberechtigung abgelehnt');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Standortberechtigung dauerhaft abgelehnt. Bitte in den Systemeinstellungen erlauben.',
      );
    }

    // 3) Position holen
    return Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}

class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(this.message);
  @override
  String toString() => message;
}
