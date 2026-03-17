import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:green_guard/models/plant_model.dart';

class PlantRepository {
  PlantRepository._();

  static final PlantRepository instance = PlantRepository._();

  final ValueNotifier<List<PlantModel>> _plantsNotifier =
      ValueNotifier<List<PlantModel>>(<PlantModel>[]);

  ValueListenable<List<PlantModel>> get plantsListenable => _plantsNotifier;

  void addPlant(PlantModel plant) {
    final next = List<PlantModel>.from(_plantsNotifier.value)..add(plant);
    _plantsNotifier.value = next;
  }

  UnmodifiableListView<PlantModel> getPlants() {
    return UnmodifiableListView<PlantModel>(_plantsNotifier.value);
  }

  void updatePlantStatus(String plantId, String status) {
    final current = _plantsNotifier.value;
    final idx = current.indexWhere((p) => p.plantId == plantId);
    if (idx == -1) return;

    final updated = current[idx].copyWith(
      status: status,
      lastUpdated: DateTime.now(),
    );

    final next = List<PlantModel>.from(current);
    next[idx] = updated;
    _plantsNotifier.value = next;
  }

  void updatePlant(PlantModel plant) {
    final current = _plantsNotifier.value;
    final idx = current.indexWhere((p) => p.plantId == plant.plantId);
    if (idx == -1) return;

    final next = List<PlantModel>.from(current);
    next[idx] = plant;
    _plantsNotifier.value = next;
  }
}

