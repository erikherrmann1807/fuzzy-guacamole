import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double tempC;
  final String city;
  final String iconUrl;
  WeatherInfo({required this.tempC, required this.city, required this.iconUrl});
}

class WeatherApiComRepo {
  final String apiKey;
  WeatherApiComRepo(this.apiKey);

  Future<WeatherInfo> currentByQuery(String q, {String lang = 'de'}) async {
    final uri = Uri.parse('https://api.weatherapi.com/v1/current.json')
        .replace(queryParameters: {'key': apiKey, 'q': q, 'lang': lang});
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;

    final city = (json['location']?['name'] ?? '') as String;
    final tempC = (json['current']?['temp_c'] as num).toDouble();
    final rawIcon = (json['current']?['condition']?['icon'] ?? '') as String;
    final iconUrl = rawIcon.startsWith('http') ? rawIcon : 'https:$rawIcon';

    return WeatherInfo(tempC: tempC, city: city, iconUrl: iconUrl);
  }

  // Optional: Koordinaten, q = "lat,lon"
  Future<WeatherInfo> currentByCoords(double lat, double lon, {String lang = 'de'}) {
    return currentByQuery('$lat,$lon', lang: lang);
  }
}
