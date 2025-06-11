import 'dart:convert';
import 'package:culturapp_baires/api_key_provider.dart';
import 'package:http/http.dart' as http;

class GoogleEngineService {
  final String apiUrl = "https://www.googleapis.com/customsearch/v1";

  Future<String?> fetchGoogleMapsSearch(
    String establishment,
    String ubication,
  ) async {
    String? apiKey = await ApiKeyProvider.getApiKey("GOOGLE_SEARCH_API_KEY");
    String? cx = await ApiKeyProvider.getApiKey("GOOGLE_SEARCH_CX");

    String query = Uri.encodeComponent("$establishment $ubication");

    final Uri url = Uri.parse("$apiUrl?key=$apiKey&cx=$cx&q=$query&num=1");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (data['items'] == null) {
          return null;
        }

        if (data['items'].isEmpty) {
          return null;
        }

        if (data['items'][0]['pagemap'] == null) {
          return null;
        }

        if (data['items'][0]['pagemap']['cse_thumbnail'].isEmpty) {
          return null;
        }

        String? thumbnail =
            data['items']?[0]['pagemap']['cse_thumbnail'][0]['src'] as String?;
        if (thumbnail != null && thumbnail.isNotEmpty) {
          return thumbnail;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> getDescription(
    String establecimiento,
    String ubicacion,
  ) async {
    return await fetchGoogleMapsSearch(establecimiento, ubicacion);
  }
}
