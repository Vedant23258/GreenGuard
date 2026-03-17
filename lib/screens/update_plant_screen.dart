import 'dart:io';

import 'package:flutter/material.dart';
import 'package:green_guard/models/plant_model.dart';
import 'package:green_guard/services/api_service.dart';
import 'package:green_guard/services/camera_service.dart';
import 'package:green_guard/widgets/custom_button.dart';

class UpdatePlantScreen extends StatefulWidget {
  final PlantModel plant;
  const UpdatePlantScreen({super.key, required this.plant});

  @override
  State<UpdatePlantScreen> createState() => _UpdatePlantScreenState();
}

class _UpdatePlantScreenState extends State<UpdatePlantScreen> {
  final _cameraService = CameraService();

  late String _status;
  String? _photoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.plant.status;
    _photoUrl = widget.plant.photoUrl;
  }

  Future<void> _uploadNewPhoto() async {
    final photo = await _cameraService.takePhoto();
    if (photo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission denied or cancelled.'),
        ),
      );
      return;
    }
    setState(() => _photoUrl = photo);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New photo captured.')),
    );
  }

  Future<void> _saveUpdates() async {
    setState(() => _saving = true);
    try {
      await ApiService.instance.updatePlantStatus(widget.plant.plantId, _status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant updated.')),
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
        const SnackBar(content: Text('Failed to update plant.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Update ${widget.plant.plantId}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.local_florist_outlined,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.plant.plantName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Lat: ${widget.plant.latitude.toStringAsFixed(5)} • '
                                'Lng: ${widget.plant.longitude.toStringAsFixed(5)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Update Plant Status',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.health_and_safety_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Healthy',
                          child: Text('Healthy'),
                        ),
                        DropdownMenuItem(
                          value: 'Needs Care',
                          child: Text('Needs Care'),
                        ),
                        DropdownMenuItem(
                          value: 'Dead',
                          child: Text('Dead'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _status = v ?? _status),
                    ),
                    const SizedBox(height: 14),
                    Card(
                      color: cs.primaryContainer.withValues(alpha: 0.35),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            if (_photoUrl != null)
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
                              )
                            else
                              Icon(Icons.image_outlined, color: cs.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _photoUrl ?? 'No photo yet',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      label: 'Upload New Photo',
                      icon: Icons.upload_rounded,
                      onPressed: _uploadNewPhoto,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: _saving ? 'Saving…' : 'Save Changes',
                      icon: Icons.save_outlined,
                      onPressed: _saving ? null : _saveUpdates,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

