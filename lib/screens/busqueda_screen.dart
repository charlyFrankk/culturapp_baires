import 'package:culturapp_baires/application/helpers_service.dart';
import 'package:flutter/material.dart';
import 'package:culturapp_baires/application/database_service.dart';
import 'package:culturapp_baires/application/nearby_places_service.dart';

class BusquedaScreen extends StatefulWidget {
  final double userLat;
  final double userLon;
  final HelpersService helpersService;

  const BusquedaScreen({
    super.key,
    required this.userLat,
    required this.userLon,
    required this.helpersService,
  });

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> results = [];

  Future<void> searchPlaces() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        results = [];
      });
      return;
    }

    try {
      final db = await DatabaseService.openDatabaseConnection();

      final List<Map<String, dynamic>> queryResults = await db.query(
        'datos',
        where: 'nombre_establecimiento LIKE ?',
        whereArgs: ['%$query%'],
      );

      final List<Map<String, dynamic>> mutableResults =
          List<Map<String, dynamic>>.from(queryResults);

      mutableResults.sort((a, b) {
        final double latA =
            double.tryParse(a['latitud']?.toString() ?? '') ?? 0.0;
        final double lonA =
            double.tryParse(a['longitud']?.toString() ?? '') ?? 0.0;
        final double latB =
            double.tryParse(b['latitud']?.toString() ?? '') ?? 0.0;
        final double lonB =
            double.tryParse(b['longitud']?.toString() ?? '') ?? 0.0;

        double distA = NearbyPlacesService.calculateDistance(
          widget.userLat,
          widget.userLon,
          latA,
          lonA,
        );
        double distB = NearbyPlacesService.calculateDistance(
          widget.userLat,
          widget.userLon,
          latB,
          lonB,
        );

        return distA.compareTo(distB);
      });

      setState(() {
        results = mutableResults;
      });
    } catch (e) {
      setState(() {
        results = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda por nombre'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Escribí lo que estás buscando...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
              onPressed: searchPlaces,
              child: const Text(
                'Buscar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Resultados de búsqueda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Expanded(
              child:
                  results.isEmpty
                      ? const Center(
                        child: Text(
                          'No se encontraron resultados.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final place = results[index];

                          final double latPlace =
                              double.tryParse(
                                place['latitud']?.toString() ?? '',
                              ) ??
                              0.0;
                          final double lonPlace =
                              double.tryParse(
                                place['longitud']?.toString() ?? '',
                              ) ??
                              0.0;

                          double distance =
                              NearbyPlacesService.calculateDistance(
                                widget.userLat,
                                widget.userLon,
                                latPlace,
                                lonPlace,
                              );

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            child: ExpansionTile(
                              title: Text(
                                place['nombre_establecimiento'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "* Tipo: ${place['establecimiento']}\n"
                                      "* Municipio: ${place['municipio_nombre']}\n"
                                      "* Distancia desde tu ubicación: ${distance.toStringAsFixed(2)} km \n",
                                    ),
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    widget.helpersService.openGoogleMaps(
                                      place['latitud'],
                                      place['longitud'],
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text("Abrir en Google Maps"),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
