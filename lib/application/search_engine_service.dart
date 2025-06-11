/*
[SERVICIO DESACTIVADO]
Es posible usar el servicio de busqueda de SearchApi, pero el mismo es limitado en su versión gratuita.
Por lo tanto, no se recomienda su uso para obtener imágenes de miniaturas de establecimientos culturales, ya que puede generar un alto consumo de créditos y eventualmente bloquear el acceso a la API.
En el caso de obtener una clave de API ilimitada, se puede utilizar este codigo para obtener la imagen miniatura de un establecimiento cultural.
*/

import 'dart:convert';
import 'package:culturapp_baires/api_key_provider.dart';
import 'package:http/http.dart' as http;

class SearchEngineService {
  final String apiUrl = "https://www.searchapi.io/api/v1/search";

  Future<String?> fetchGoogleMapsSearch(
    String establishment,
    double lat,
    double lon,
  ) async {
    String? apiKey = await ApiKeyProvider.getApiKey("GOOGLE_SEARCH_API_KEY");
    String ll = Uri.encodeComponent("@$lat,$lon,20z");

    final Uri url = Uri.parse(
      "$apiUrl?q=${Uri.encodeComponent(establishment)}&api_key=$apiKey&engine=google_maps&ll=$ll",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        String? thumbnail = data['local_results']?[0]['thumbnail'] as String?;
        if (thumbnail != null && thumbnail.isNotEmpty) {
          return thumbnail;
        } else {
          return "No se encontró información relevante.";
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> getDescription(
    String establishment,
    double lat,
    double lon,
  ) async {
    return await fetchGoogleMapsSearch(establishment, lat, lon);
  }
}
