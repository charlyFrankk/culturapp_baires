import 'dart:io';
import 'package:culturapp_baires/application/helpers_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:culturapp_baires/application/google_engine_service.dart';
import 'package:culturapp_baires/application/nearby_places_service.dart';
import 'package:culturapp_baires/application/user_location_service.dart';
import 'package:culturapp_baires/screens/busqueda_screen.dart';
import 'package:culturapp_baires/screens/global_state.dart';
import 'package:culturapp_baires/screens/login_screen.dart';
import 'package:culturapp_baires/screens/museos_screen.dart';
import 'package:culturapp_baires/screens/cines_teatros_screen.dart';
import 'package:culturapp_baires/screens/bibliotecas_screen.dart';
import 'package:culturapp_baires/screens/otros_lugares_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> places = [];

  GoogleEngineService googleEngineService = GoogleEngineService();
  HelpersService helpersService = HelpersService();

  double userLat = -34.62; // Latitud de ejemplo
  double userLon = -58.54; // Longitud de ejemplo
  double searchRatio = 10; // Radio de búsqueda en km

  String dateMigration = "Cargando...";

  @override
  void initState() {
    super.initState();
    getMigrationDatabaseDate().then((date) {
      setState(() {
        dateMigration = date ?? "N/A";
      });
    });

    getNearbyPlaces();
  }

  Future<void> getNearbyPlaces() async {
    Position? position = await LocationService.getLocation();
    if (position != null) {
      List<Map<String, dynamic>> results =
          await NearbyPlacesService.searchPlaces(
            position.latitude,
            position.longitude,
            searchRatio,
          );
      setState(() {
        places = results;
        userLat = position.latitude;
        userLon = position.longitude;
      });
    } else {
    }
  }

  Future<String?> getMigrationDatabaseDate() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/last-migration.txt');

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return "N/A";
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${GlobalState.name}'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.amber[50],
      drawer: Drawer(
        backgroundColor: Colors.amber[100],
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            const SizedBox(height: 70),
            const Text(
              'Menú',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              'Última actualización de datos:',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              dateMigration,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 100),
            const Text(
              '* Desarrollado por Carlos A. Franco (3811) como trabajo final para la cátedra "Gobierno Electrónico" de la Universidad Nacional Arturo Jauretche.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontStyle: FontStyle.normal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '** Esta aplicación utiliza el dataset "establecimientos-cultura.csv" suministrado por el Gobierno de la Provincia de Buenos Aires, a traves de su sitio oficial "Datos Abiertos PBA".',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontStyle: FontStyle.normal,
              ),
            ),
            const SizedBox(height: 140),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Salir'),
              style: ListTileStyle.drawer,
              tileColor: const Color.fromARGB(255, 241, 16, 39),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              onTap: () async {
                GlobalState.email = '';
                GlobalState.name = '';
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(Icons.location_pin, size: 40),
              const SizedBox(height: 20),
              const Text(
                'Sitios culturales cerca tuyo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                '¿Qué estás buscando?',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                children: [
                  _buildCategoryButton(
                    context,
                    'Teatros y Cines',
                    Icons.movie,
                    Colors.red,
                    CinesTeatrosScreen(
                      places: places,
                      searchEngineService: googleEngineService,
                      helpersService: helpersService,
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    'Museos',
                    Icons.museum,
                    Colors.blue,
                    MuseosScreen(
                      places: places,
                      searchEngineService: googleEngineService,
                      helpersService: helpersService,
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    'Bibliotecas',
                    Icons.library_books,
                    Colors.green,
                    BibliotecasScreen(
                      places: places,
                      searchEngineService: googleEngineService,
                      helpersService: helpersService,
                    ),
                  ),
                  _buildCategoryButton(
                    context,
                    'Otros',
                    Icons.location_city,
                    Colors.orange,
                    OtrosLugaresScreen(
                      places: places,
                      searchEngineService: googleEngineService,
                      helpersService: helpersService,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BusquedaScreen(
                            userLat: userLat,
                            userLon: userLon,
                            helpersService: helpersService,
                          ),
                    ),
                  );
                },
                child: const Text(
                  'Buscar por nombre de establecimiento',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String category,
    IconData icon,
    Color color,
    Widget? screen,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: color,
      child: InkWell(
        onTap: () {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
