import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'api_models.dart';

enum ApiStatus { loading, online, offline }

class Strategy {
  final String name;
  final List<String> sequence;
  final int waterDemand;
  final int soilBenefit;
  final int nitrogenPotential;
  final int erosionReduction;
  final int climateSuitability;
  final int incomePotential;
  final String risk;
  final String why;

  Strategy({
    required this.name,
    required this.sequence,
    required this.waterDemand,
    required this.soilBenefit,
    required this.nitrogenPotential,
    required this.erosionReduction,
    required this.climateSuitability,
    required this.incomePotential,
    required this.risk,
    required this.why,
  });

  factory Strategy.fromJson(Map<String, dynamic> j) => Strategy(
        name: j['name'],
        sequence: List<String>.from(j['sequence']),
        waterDemand: j['water_demand'],
        soilBenefit: j['soil_benefit'],
        nitrogenPotential: j['nitrogen_potential'],
        erosionReduction: j['erosion_reduction'],
        climateSuitability: j['climate_suitability'],
        incomePotential: j['income_potential'],
        risk: j['risk'],
        why: j['why'],
      );
}

class AppState extends ChangeNotifier {
  AppState({ApiClient? api}) : api = api ?? ApiClient();

  final ApiClient api;

  // ---- Live data from the FarmWise API (null = not loaded / offline) ----
  ApiStatus apiStatus = ApiStatus.loading;
  String? apiError;
  List<Metric>? metrics;
  List<Risk>? risks;
  List<SeasonMonth>? seasonMonths;
  List<SeasonInsight>? seasonInsights;
  List<CropRecommendation>? cropRecommendations;
  List<DataSource>? dataSources;
  SoilInfo? soil;
  List<Strategy>? _apiStrategies;
  Timer? _rotationDebounce;

  bool get isLive => apiStatus == ApiStatus.online;

  String get dataLabel => isLive
      ? "Live NASA satellite data${metrics != null && metrics!.isNotEmpty ? ' (as of ${metrics!.first.asOf})' : ''}"
      : apiStatus == ApiStatus.loading
          ? "Loading satellite data…"
          : "Demo data (illustrative), backend offline";

  /// Load everything the screens need. Safe to call again to retry.
  Future<void> loadAll() async {
    apiStatus = ApiStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        api.dashboard(),
        api.seasons(),
        api.location(),
        api.recommendations(),
      ]);
      final dash = results[0];
      final sea = results[1];
      final loc = results[2];
      final rec = results[3];

      metrics = (dash['metrics'] as List).map((e) => Metric.fromJson(e)).toList();
      risks = (dash['risks'] as List).map((e) => Risk.fromJson(e)).toList();
      soil = SoilInfo.fromJson(dash['soil']);
      seasonMonths = (sea['months'] as List).map((e) => SeasonMonth.fromJson(e)).toList();
      seasonInsights = (sea['insights'] as List).map((e) => SeasonInsight.fromJson(e)).toList();
      dataSources = (loc['data_sources'] as List).map((e) => DataSource.fromJson(e)).toList();
      cropRecommendations =
          (rec['recommendations'] as List).map((e) => CropRecommendation.fromJson(e)).toList();
      location = dash['location'] ?? location;
      if (soil != null && soilTypes.contains(soil!.textureClass)) {
        soilType = soil!.textureClass;
      }
      apiStatus = ApiStatus.online;
      apiError = null;
      notifyListeners();
      await refreshRotations();
    } catch (e) {
      apiStatus = ApiStatus.offline;
      apiError = e.toString();
      notifyListeners();
    }
  }

  /// Re-score rotations on the backend (user's rotation vs suggested strategies).
  Future<void> refreshRotations() async {
    if (apiStatus == ApiStatus.offline) return;
    try {
      final list = await api.rotations(rotation, activePriorities);
      _apiStrategies = list.map((e) => Strategy.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('rotations failed: $e');
    }
  }

  void _scheduleRotationRefresh() {
    _rotationDebounce?.cancel();
    _rotationDebounce = Timer(const Duration(milliseconds: 500), refreshRotations);
  }

  /// Ask FarmWise: backend answer when online, local fallback otherwise.
  Future<String> ask(String message, String Function(String) fallback) async {
    if (!isLive) return fallback(message);
    try {
      return await api.chat(message, rotation: rotation, priorities: activePriorities);
    } catch (_) {
      return fallback(message);
    }
  }

  List<String> get activePriorities =>
      priorities.entries.where((e) => e.value).map((e) => e.key).toList();

  final List<String> soilTypes = ["Clay loam", "Sandy", "Silty", "Loam", "Not sure"];

  @override
  void dispose() {
    _rotationDebounce?.cancel();
    super.dispose();
  }

  Map<String, bool> priorities = {
    'soil': true,
    'water': false,
    'res': true,
    'n': false,
    'ero': false,
    'inc': false,
  };

  bool isDarkMode = false;

void toggleTheme() {
  isDarkMode = !isDarkMode;
  notifyListeners();
}


  final Map<String, String> priorityNames = {
    'soil': 'Improve soil health',
    'water': 'Reduce water use',
    'res': 'Increase resilience',
    'n': 'Improve nitrogen',
    'ero': 'Reduce erosion',
    'inc': 'Generate income',
  };

  String rotation = "Wheat → Maize → Fallow";
  int activeLayer = 0;
  List<Offset> fieldPoints = [];
  String location = "Sharqia, Egypt";
  String area = "5";
  String soilType = "Clay loam";
  String irrigation = "Canal, limited in summer";

  final List<String> layers = [
    "Soil moisture",
    "Temperature",
    "Rainfall",
    "Vegetation health",
    "Water stress",
    "Elevation & erosion"
  ];

  final List<List<String>> nasaDatasets = [
    [
      "SMAP",
      "Soil moisture",
      "Shows how much water is in the top soil, so you can time planting and spot early drought.",
      "Favors deep-rooted or drought-tolerant crops where moisture runs low."
    ],
    [
      "ECOSTRESS",
      "Land surface temperature, evapotranspiration",
      "Shows how hot plants are and how fast they lose water.",
      "Flags heat and water stress before leaves show damage."
    ],
    [
      "GPM",
      "Rainfall",
      "Rain measured from space every few hours.",
      "Tells us which seasons are dry and where cover crops can use rain."
    ],
    [
      "Landsat / MODIS",
      "Vegetation greenness (NDVI)",
      "Greenness of crops over years.",
      "Reveals bare-field periods and weak-growth patches."
    ],
    [
      "NASA POWER",
      "Weather history",
      "Temperature, sunshine and rain records.",
      "Sets growing seasons and frost or heat windows."
    ],
    [
      "GRACE-FO",
      "Groundwater and water storage",
      "Changes in total water stored underground.",
      "Warns if irrigation water is declining long-term."
    ],
    [
      "SRTM",
      "Elevation and slope",
      "Terrain shape.",
      "Steeper land needs erosion-reducing crops."
    ]
  ];

  List<Strategy> get strategies => _apiStrategies ?? demoStrategies;

  /// Original illustrative strategies, used when the backend is unreachable.
  List<Strategy> get demoStrategies {
    List<String> userSeq = rotation
        .split(RegExp(r'→|->|,'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return [
      Strategy(
        name: "Existing rotation",
        sequence: userSeq.isEmpty ? ["Wheat", "Maize", "Fallow"] : userSeq,
        waterDemand: 74,
        soilBenefit: 38,
        nitrogenPotential: 18,
        erosionReduction: 34,
        climateSuitability: 42,
        incomePotential: 60,
        risk: "High water demand in the dry months, long bare fallow, few nitrogen-fixing crops.",
        why: "This is your current practice, used as the baseline for comparison.",
      ),
      Strategy(
        name: "Soil health strategy",
        sequence: ["Wheat", "Faba bean", "Maize", "Clover cover crop"],
        waterDemand: 62,
        soilBenefit: 86,
        nitrogenPotential: 82,
        erosionReduction: 78,
        climateSuitability: 64,
        incomePotential: 55,
        risk: "Cover crop uses some water; faba bean yields can vary with disease.",
        why: "A legume after cereals adds nitrogen, and cover crops keep roots in the soil and add organic matter.",
      ),
      Strategy(
        name: "Climate resilience strategy",
        sequence: ["Barley", "Chickpea", "Sorghum"],
        waterDemand: 38,
        soilBenefit: 64,
        nitrogenPotential: 58,
        erosionReduction: 60,
        climateSuitability: 88,
        incomePotential: 62,
        risk: "Local market for sorghum may be limited; chickpea is sensitive to waterlogging.",
        why: "Drought-tolerant, lower-water crops suit the low soil moisture and high heat stress seen here.",
      ),
    ];
  }

  int calculateScore(Strategy s) {
    Map<String, int> values = {
      'soil': s.soilBenefit,
      'water': 100 - s.waterDemand,
      'res': s.climateSuitability,
      'n': s.nitrogenPotential,
      'ero': s.erosionReduction,
      'inc': s.incomePotential,
    };

    List<String> activeKeys = priorities.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeKeys.isEmpty) {
      activeKeys = values.keys.toList();
    }

    double total = 0;
    for (var k in activeKeys) {
      total += values[k]!;
    }

    return (total / activeKeys.length).round();
  }

  void togglePriority(String key) {
    priorities[key] = !(priorities[key] ?? false);
    notifyListeners();
    // Scores are recomputed locally (calculateScore); no API call needed.
  }

  void setLayer(int layer) {
    activeLayer = layer;
    notifyListeners();
  }

  void addPoint(Offset pt) {
    fieldPoints.add(pt);
    notifyListeners();
  }

  void clearPoints() {
    fieldPoints.clear();
    notifyListeners();
  }

  void updateLocation(String val) { location = val; notifyListeners(); }
  void updateArea(String val) { area = val; notifyListeners(); }
  void updateSoil(String val) { soilType = val; notifyListeners(); }
  void updateRotation(String val) { rotation = val; notifyListeners(); _scheduleRotationRefresh(); }
  void updateIrrigation(String val) { irrigation = val; notifyListeners(); }
}
