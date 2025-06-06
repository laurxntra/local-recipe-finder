import 'package:geocoding/geocoding.dart';

Future<String> getAreaFromCoords(double lat, double long) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String? country = place.country;

      if (country != null) {
        final countryLower = country.toLowerCase();
        if (countryLower.contains("canada")) return "Canadian";
        if (countryLower.contains("mexico")) return "Mexican";
        if (countryLower.contains("italy")) return "Italian";
        if (countryLower.contains("france")) return "French";
        if (countryLower.contains("india")) return "Indian";
        if (countryLower.contains("japan")) return "Japanese";
        if (countryLower.contains("china")) return "Chinese";
        if (countryLower.contains("united states") || countryLower.contains("usa")) return "American";
        if (countryLower.contains("greece")) return "Greek";
        if (countryLower.contains("morocco")) return "Moroccan";
        if (countryLower.contains("russia")) return "Russian";
      }
    }
  } catch (e) {
    print("Error in geocoding");
  }
  return "American";
}