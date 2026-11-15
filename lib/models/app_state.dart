import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
}

class AppState extends ChangeNotifier {
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

  List<Strategy> get strategies {
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
  void updateRotation(String val) { rotation = val; notifyListeners(); }
  void updateIrrigation(String val) { irrigation = val; notifyListeners(); }
}
