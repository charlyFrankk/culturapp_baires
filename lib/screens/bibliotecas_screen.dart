import 'package:culturapp_baires/application/google_engine_service.dart';
import 'package:culturapp_baires/application/helpers_service.dart';
import 'package:flutter/material.dart';

class BibliotecasScreen extends StatefulWidget {
  final List<Map<String, dynamic>> places;
  final GoogleEngineService searchEngineService;
  final HelpersService helpersService;

  const BibliotecasScreen({
    super.key,
    required this.places,
    required this.searchEngineService,
    required this.helpersService,
  });

  @override
  State<BibliotecasScreen> createState() => _BibliotecasScreenState();
}

class _BibliotecasScreenState extends State<BibliotecasScreen> {
  Map<int, bool> expandedState = {};
  Map<int, String?> descriptions = {};

  Future<void> loadDescription(
    int index,
    String establishment,
    String municipality,
  ) async {
    if (descriptions.containsKey(index)) return;

    String? descripcion = await widget.searchEngineService.getDescription(
      establishment,
      municipality,
    );
    setState(() {
      descriptions[index] = descripcion;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPlaces =
        widget.places.where((place) {
          String establishment =
              place["establecimiento"].toString().toLowerCase();
          return establishment.contains("biblioteca");
        }).toList();

    filteredPlaces.sort((a, b) => a["distancia"].compareTo(b["distancia"]));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliotecas'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.amber[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.location_pin, size: 40),
            const SizedBox(height: 15),
            const Text(
              'Sitios culturales cerca tuyo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  filteredPlaces.isEmpty
                      ? const Center(
                        child: Text(
                          "No hay bibliotecas cercanas.",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = filteredPlaces[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            child: ExpansionTile(
                              title: Text(
                                place["nombre_establecimiento"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  expandedState[index] = expanded;
                                });
                                if (expanded) {
                                  loadDescription(
                                    index,
                                    place['nombre_establecimiento'],
                                    place['municipio_nombre'],
                                  );
                                }
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        (descriptions.containsKey(index) &&
                                                descriptions[index] != null)
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                descriptions[index]!,
                                                width: 140,
                                                height: 140,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : Container(),
                                        (descriptions.containsKey(index) &&
                                                descriptions[index] != null)
                                            ? const SizedBox(height: 8)
                                            : Container(),
                                        Text(
                                          "* Municipio: ${place['municipio_nombre']}\n* Distancia desde tu ubicación: ${place['distancia'].toStringAsFixed(2)} km",
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
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
