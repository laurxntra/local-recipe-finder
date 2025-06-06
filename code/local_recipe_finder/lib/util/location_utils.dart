/// This function gets the general area given the latitude and longitude coordinates.
/// It returns a size-2 list containing the area name and country name.
/// If the coordinates do not match any known area, it defaults to "American" and "United States" because that
/// is where the developers of this app are located and thus is the most probable area to be used.
/// Parameters:
/// - lat: latitude of the coordinates
/// - lng: longitude of the coordinates
/// Returns: A size-2 list containing the area name and country name
List<String> getAreaFromCoords(double lat, double lng) {
  // Each entry: [areaName, countryName, minLat, maxLat, minLng, maxLng]
  // These ranges per country were obtained using Google.com.
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

  return ["Chinese", "China"]; // default fallback
}
