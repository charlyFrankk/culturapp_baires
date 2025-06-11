import 'dart:math';
import 'package:culturapp_baires/application/database_service.dart';
import 'package:sqflite/sqflite.dart';

class NearbyPlacesService {
  
  static Future<List<Map<String, dynamic>>> searchPlaces(
    double userLat,
    double userLon,
    double searchRatio,
  ) async {
    final Database db = await DatabaseService.openDatabaseConnection();

    List<Map<String, dynamic>> results = await db.query("datos");

    List<Map<String, dynamic>> nearbyPlaces =
        results
            .where(
              (place) => place["latitud"] != null && place["longitud"] != null,
            )
            .map((place) {
              double lat = double.parse(place["latitud"]);
              double lon = double.parse(place["longitud"]);
              double distance = calculateDistance(
                userLat,
                userLon,
                lat,
                lon,
              );
              if (distance > searchRatio) {
                return null;
              }
              return {...place, "distancia": distance};
            })
            .where((place) => place != null)
            .cast<Map<String, dynamic>>()
            .toList();
    await db.close();
    return nearbyPlaces;
  }

  /// Calcula la distancia en kilómetros entre dos coordenadas usando la fórmula de Haversine
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double radioTierra = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierra * c;
  }

  static double _toRadians(double grados) {
    return grados * pi / 180;
  }
}
