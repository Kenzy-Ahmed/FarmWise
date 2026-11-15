// Typed views of the FarmWise API responses used by the screens.

double _d(dynamic v) => v == null ? 0 : (v as num).toDouble();

class Metric {
  final String key, label, display, description, source, asOf;
  final double bar;
  Metric.fromJson(Map<String, dynamic> j)
      : key = j['key'],
        label = j['label'],
        display = j['display'],
        description = j['description'],
        source = j['source'],
        asOf = j['as_of'],
        bar = _d(j['bar']);
}

class Risk {
  final String key, label, level, description, method;
  final int value;
  Risk.fromJson(Map<String, dynamic> j)
      : key = j['key'],
        label = j['label'],
        level = j['level'],
        description = j['description'],
        method = j['method'],
        value = j['value'];
}

class SeasonMonth {
  final int month;
  final String name, fieldStatus;
  final double rainMm, tempMean, tempMax, et0Mm;
  final double? ndvi;
  SeasonMonth.fromJson(Map<String, dynamic> j)
      : month = j['month'],
        name = j['month_name'],
        fieldStatus = j['field_status'],
        rainMm = _d(j['rain_mm']),
        tempMean = _d(j['temp_mean_c']),
        tempMax = _d(j['temp_max_c']),
        et0Mm = _d(j['et0_mm']),
        ndvi = j['ndvi'] == null ? null : _d(j['ndvi']);
}

class SeasonInsight {
  final String title, text;
  SeasonInsight.fromJson(Map<String, dynamic> j)
      : title = j['title'],
        text = j['text'];
}

class CropRecommendation {
  final int rank;
  final String name, code, label, summary;
  final double score, irrigationMm;
  final List<String> suitableMonths, strengths, limitations;
  CropRecommendation.fromJson(Map<String, dynamic> j)
      : rank = j['rank'],
        name = j['crop_name'],
        code = j['crop_code'],
        label = j['suitability_label'],
        summary = j['summary'],
        score = _d(j['overall_score']),
        irrigationMm = _d(j['est_irrigation_need_mm_season']),
        suitableMonths = List<String>.from(j['suitable_months']),
        strengths = List<String>.from(j['strengths']),
        limitations = List<String>.from(j['limitations']);
}

class SoilInfo {
  final double ph, soc, nitrogen;
  final String phClass, textureClass;
  SoilInfo.fromJson(Map<String, dynamic> j)
      : ph = _d(j['ph']),
        soc = _d(j['soc_g_kg']),
        nitrogen = _d(j['nitrogen_g_kg']),
        phClass = j['ph_class'],
        textureClass = j['texture_class'];
}

class DataSource {
  final String name, provides;
  DataSource.fromJson(Map<String, dynamic> j)
      : name = j['name'],
        provides = j['provides'];
}
