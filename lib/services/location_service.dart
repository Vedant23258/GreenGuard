import 'package:geolocator/geolocator.dart';

class LocationPoint {
  final double latitude;
  final double longitude;

  const LocationPoint(this.latitude, this.longitude);
}

class LocationService {
  Future<LocationPoint> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw const LocationServiceException(
        'Location permission denied. Enable it in settings to use GPS.',
      );
    }

    final Position position = await Geolocator.getCurrentPosition();
    return LocationPoint(position.latitude, position.longitude);
  }
}

class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

