import 'dart:io';
import 'package:culturapp_baires/api_key_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mongo_dart/mongo_dart.dart';

class HelpersService {
  void openGoogleMaps(String lat, String lon) async {
    String url = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";

    if (Platform.isAndroid) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> sendDataToMongo(String name, String email) async {
    String? mongoUser = await ApiKeyProvider.getApiKey("MONGODB_USER");
    String? mongoKey = await ApiKeyProvider.getApiKey("MONGODB_PWD");
    String? mongoServer = await ApiKeyProvider.getApiKey("MONGODB_SERVER");
    String? mongoCollection = await ApiKeyProvider.getApiKey("MONGODB_COLLECTION");
    String? mongoCluster = await ApiKeyProvider.getApiKey("MONGODB_CLUSTER");

    var db = await Db.create(
      "mongodb+srv://$mongoUser:$mongoKey@$mongoServer/$mongoCollection?retryWrites=true&w=majority&appName=$mongoCluster",
    );
    await db.open();
    var collection = db.collection("users");
    await collection.insertOne({"name": name, "email": email});
    await db.close();
  }
}
