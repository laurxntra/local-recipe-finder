import 'package:geocoding/geocoding.dart';

List<String> getAreaFromCoords(double lat, double lng) {
  // Each entry: [areaName, countryName, minLat, maxLat, minLng, maxLng]
  print("lat: $lat, lng: $lng");
  final countries = [
    ["American", "United States", 24.5, 49.4, -125.0, -66.9],
    ["Canadian", "Canada", 41.7, 83.1, -141.0, -52.6],
    ["Mexican", "Mexico", 14.5, 32.7, -118.4, -86.7],
    ["Italian", "Italy", 35.5, 47.1, 6.6, 18.5],
    ["French", "France", 41.3, 51.1, -5.1, 9.6],
    ["Indian", "India", 6.5, 35.7, 68.1, 97.4],
    ["Japanese", "Japan", 24.2, 45.5, 122.9, 145.8],
    ["Chinese", "China", 18.0, 53.6, 73.5, 135.1],
    ["Greek", "Greece", 34.8, 41.8, 19.3, 28.2],
    ["Moroccan", "Morocco", 27.6, 35.9, -13.0, -1.0],
    ["Russian", "Russia", 41.2, 82.0, 19.6, 180.0],
  ];

  for (final c in countries) {
    final areaName = c[0] as String;
    final countryName = c[1] as String;
    final minLat = c[2] as double;
    final maxLat = c[3] as double;
    final minLng = c[4] as double;
    final maxLng = c[5] as double;

    if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
      return [areaName, countryName];
    }
  }

  print("couldn't find, so defaulting to [Chinese, China]");
  return ["Chinese", "China"]; // default fallback
}

// Future<String> getAreaFromCoords(double lat, double long) async {
//   try {
//     List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks.first;
//       String? country = place.country;

//       if (country != null) {
//         final countryLower = country.toLowerCase();
//         if (countryLower.contains("canada")) return "Canadian";
//         if (countryLower.contains("mexico")) return "Mexican";
//         if (countryLower.contains("italy")) return "Italian";
//         if (countryLower.contains("france")) return "French";
//         if (countryLower.contains("india")) return "Indian";
//         if (countryLower.contains("japan")) return "Japanese";
//         if (countryLower.contains("china")) return "Chinese";
//         if (countryLower.contains("united states") || countryLower.contains("usa")) return "American";
//         if (countryLower.contains("greece")) return "Greek";
//         if (countryLower.contains("morocco")) return "Moroccan";
//         if (countryLower.contains("russia")) return "Russian";
//       }
//     }
//   } catch (e) {
//     print("Error in geocoding");
//   }
//   return "American";
// }