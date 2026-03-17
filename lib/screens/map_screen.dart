import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:green_guard/models/plant_model.dart';
import 'package:green_guard/services/location_service.dart';
import 'package:green_guard/services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _locationService = LocationService();
  GoogleMapController? _controller;

  late Future<List<PlantModel>> _plantsFuture;

  static const CameraPosition _fallbackCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629), // India (nice default for demo)
    zoom: 4.8,
  );

  @override
  void initState() {
    super.initState();
    _plantsFuture = ApiService.instance.getPlants();
  }

  void _showPlantDetails(PlantModel plant) {
    final cs = Theme.of(context).colorScheme;
    final photoUrl = plant.photoUrl;
    final fullPhotoUrl = (photoUrl.isEmpty || photoUrl == 'null')
        ? null
        : (photoUrl.startsWith('http')
            ? photoUrl
            : 'http://10.0.2.2:5000$photoUrl');

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.local_florist_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.plantName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(plant.lastUpdated),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(status: plant.status),
                ],
              ),
              const SizedBox(height: 12),
              if (fullPhotoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Image.network(
                      fullPhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _markersFor(List<PlantModel> plants) {
    return plants
        .where((p) => p.latitude != 0 && p.longitude != 0)
        .map(
          (p) => Marker(
            markerId: MarkerId(p.plantId),
            position: LatLng(p.latitude, p.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _hueForStatus(p.status),
            ),
            infoWindow: InfoWindow(
              title: p.plantName,
              snippet: '${p.status} • ${_formatDate(p.lastUpdated)}',
            ),
            onTap: () => _showPlantDetails(p),
          ),
        )
        .toSet();
  }

  Future<void> _centerOnUser() async {
    try {
      final loc = await _locationService.getCurrentLocation();
      final controller = _controller;
      if (controller == null) return;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(loc.latitude, loc.longitude),
            zoom: 16,
          ),
        ),
      );
    } on LocationServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch current location.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Plant Monitoring Map')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _centerOnUser,
        icon: const Icon(Icons.my_location_rounded),
        label: const Text('Center Map'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.map_outlined, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Plant Monitoring Map',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FutureBuilder<List<PlantModel>>(
                      future: _plantsFuture,
                      builder: (context, snapshot) {
                        final plants = snapshot.data ?? const <PlantModel>[];
                        final first = plants.isEmpty ? null : plants.first;
                        final initial = (first != null &&
                                first.latitude != 0 &&
                                first.longitude != 0)
                            ? CameraPosition(
                                target: LatLng(first.latitude, first.longitude),
                                zoom: 14,
                              )
                            : _fallbackCamera;

                        return Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: initial,
                              markers: _markersFor(plants),
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              onMapCreated: (c) => _controller = c,
                            ),
                            Positioned(
                              left: 12,
                              top: 12,
                              child: _LegendPill(),
                            ),
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const Center(
                                child: CircularProgressIndicator(),
                              )
                            else if (snapshot.hasError)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Card(
                                  color: cs.surface.withValues(alpha: 0.95),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      'Failed to load plants. Please try again.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                  ),
                                ),
                              )
                            else if (plants.isEmpty)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Card(
                                  color: cs.surface.withValues(alpha: 0.95),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      'No plants yet. Register plants to see markers on the map.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _hueForStatus(String status) {
  switch (status) {
    case 'Healthy':
      return BitmapDescriptor.hueGreen;
    case 'Needs Care':
      return BitmapDescriptor.hueYellow;
    case 'Dead':
      return BitmapDescriptor.hueRed;
    default:
      return BitmapDescriptor.hueAzure;
  }
}

String _formatDate(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

class _LegendPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _LegendDot(color: Color(0xFF2E7D32), label: 'Healthy'),
            SizedBox(width: 10),
            _LegendDot(color: Color(0xFFF9A825), label: 'Needs Care'),
            SizedBox(width: 10),
            _LegendDot(color: Color(0xFFC62828), label: 'Dead'),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      'Healthy' => (cs.primaryContainer, cs.primary),
      'Needs Care' => (const Color(0xFFFFF3C4), const Color(0xFF7A5A00)),
      'Dead' => (const Color(0xFFFFD6D6), const Color(0xFF8A1C1C)),
      _ => (cs.surfaceContainerHighest, cs.onSurface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

