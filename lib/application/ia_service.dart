/*
[SERVICIO DESACTIVADO]
El servicio de IA de Google Gemini no permite busqueda en la web,
por lo que no se puede utilizar para obtener imágenes de miniaturas de establecimientos culturales, 
ni tampoco descripciones como fue pensado al inicio del proyecto.

Se puede reactivar para proximas versiones del proyecto, 
donde se pueda elaborar un prompt en base a otros factores y la API de IA pueda generar una respuesta más precisa y útil.
*/

import 'dart:convert';
import 'package:culturapp_baires/api_key_provider.dart';
import 'package:http/http.dart' as http;

class IAService {
  Future<String?> enviarPrompt(String prompt) async {
    String? apiKey = await ApiKeyProvider.getApiKey("GOOGLE_SEARCH_API_KEY");
    String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";
    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json"},

            body: jsonEncode({
              "contents": [
                {
                  "role": "user",
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"]?[0]["content"]["parts"]?[0]["text"];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> obtenerDescripcion(
    String establecimiento,
    String municipio,
  ) async {
    String prompt =
        "Dado el establecimiento cultural '$establecimiento' ubicado en '$municipio', por favor genera una breve descripción informativa y atractiva de este lugar. Incluye datos relevantes como su historia, importancia cultural, y aspectos destacados que lo hacen único, así como recomendaciones prácticas para futuros visitantes. Procura que la respuesta sea precisa, concisa y no exceda las 100 palabras.";
    return await enviarPrompt(prompt);
  }
}
