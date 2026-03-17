import 'dart:io';

import 'package:flutter/material.dart';
import 'package:green_guard/services/api_service.dart';
import 'package:green_guard/services/camera_service.dart';
import 'package:green_guard/services/location_service.dart';
import 'package:green_guard/widgets/custom_button.dart';
import 'package:green_guard/widgets/input_field.dart';

class RegisterPlantScreen extends StatefulWidget {
  const RegisterPlantScreen({super.key});

  @override
  State<RegisterPlantScreen> createState() => _RegisterPlantScreenState();
}

class _RegisterPlantScreenState extends State<RegisterPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plantNameController = TextEditingController();
  final _locationController = TextEditingController();

  final _locationService = LocationService();
  final _cameraService = CameraService();

  LocationPoint? _gps;
  String? _photoUrl;
  bool _saving = false;

  @override
  void dispose() {
    _plantNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _captureGps() async {
    try {
      final gps = await _locationService.getCurrentLocation();
      setState(() => _gps = gps);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS captured: ${gps.latitude}, ${gps.longitude}'),
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
        const SnackBar(content: Text('Failed to capture GPS.')),
      );
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _cameraService.takePhoto();
    if (photo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied or cancelled.')),
      );
      return;
    }
    setState(() => _photoUrl = photo);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo captured.')),
    );
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    final gps = _gps;
    if (gps == null || gps.latitude == 0 || gps.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture GPS before saving.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final file = (_photoUrl == null) ? null : File(_photoUrl!);
      await ApiService.instance.createPlant(
        _plantNameController.text.trim(),
        gps.latitude,
        gps.longitude,
        file,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant saved.')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save plant.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gpsText = _gps == null
        ? 'Not captured'
        : '${_gps!.latitude.toStringAsFixed(5)}, ${_gps!.longitude.toStringAsFixed(5)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Register Plant')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Plant Details',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      InputField(
                        controller: _plantNameController,
                        label: 'Plant Name',
                        hintText: 'e.g., Neem, Mango, Bamboo',
                        prefixIcon: Icons.local_florist_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Plant name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      InputField(
                        controller: _locationController,
                        label: 'Location',
                        hintText: 'e.g., Sector 4, North Field',
                        prefixIcon: Icons.place_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed_rounded, color: cs.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'GPS: $gpsText',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Capture GPS',
                        icon: Icons.my_location_rounded,
                        onPressed: _captureGps,
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        label: _photoUrl == null ? 'Take Photo' : 'Retake Photo',
                        icon: Icons.camera_alt_outlined,
                        onPressed: _takePhoto,
                      ),
                      const SizedBox(height: 14),
                      if (_photoUrl != null)
                        Card(
                          color: cs.primaryContainer.withValues(alpha: 0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: 56,
                                    width: 56,
                                    child: Image.file(
                                      File(_photoUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _photoUrl!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: _saving ? 'Saving…' : 'Save Plant',
                        icon: Icons.save_outlined,
                        onPressed: _saving ? null : _savePlant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

