import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../widgets/custom_widgets.dart';

class DashScreen extends StatelessWidget {
  final AppState state;
  const DashScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final mutedColor = isDark ? const Color(0xFF9AAB9F) : const Color(0xFF5D6B62);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;

    final demoMetrics = [
      ["Average temperature", "27.4 °C", 62, "Warm days speed up growth but raise water needs."],
      ["Recent rainfall", "4 mm / 30 days", 8, "Very little rain means crops depend on irrigation."],
      ["Soil moisture", "0.18 m³/m³", 32, "Low moisture early in the season risks poor germination."],
      ["Vegetation health (NDVI)", "0.46", 46, "A lower value suggests crops or cover are under stress."],
      ["Evapotranspiration", "5.1 mm/day", 70, "How much water plants and soil lose each day."],
      ["Water availability", "Moderate", 50, "How much irrigation water you can count on."],
    ];

    final demoRisks = [
      ["Drought risk", 72, "Long dry spells can cut yields."],
      ["Heat stress", 64, "Hot spells can damage flowering."],
      ["Soil erosion risk", 38, "Bare slopes lose topsoil in storms."],
      ["Water stress", 69, "Crops may need more water than is available."],
      ["Extreme rainfall risk", 18, "Bare slopes lose topsoil in storms."],
    ];

    // Live API data when available, illustrative values otherwise
    final metrics = state.metrics != null
        ? state.metrics!.map((m) => [m.label, m.display, m.bar.round(), "${m.description} (${m.source})"]).toList()
        : demoMetrics;
    final risks = state.risks != null
        ? state.risks!.map((r) => [r.label, r.value, "${r.description} Method: ${r.method}."]).toList()
        : demoRisks;
    final crops = state.cropRecommendations ?? const [];
    final accent = isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Farmer dashboard", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          DataStatusChip(state: state),
          const SizedBox(height: 20),
          Text("Environmental overview", style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: 150,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final m = metrics[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m[0] as String, style: TextStyle(fontSize: 12, color: mutedColor)),
                    const SizedBox(height: 4),
                    Text(m[1] as String, style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C))),
                    const SizedBox(height: 6),
                    CustomProgressBar(value: (m[2] as int).toDouble()),
                    const SizedBox(height: 6),
                    Expanded(child: Text(m[3] as String, style: TextStyle(fontSize: 11, color: mutedColor), maxLines: 2, overflow: TextOverflow.ellipsis)),],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text("Risk indicators", style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: risks.length,
            itemBuilder: (context, index) {
              final r = risks[index];
              int val = r[1] as int;
              String tagType = val >= 65 ? 'h' : (val >= 40 ? 'm' : '');
              String tagText = val >= 65 ? 'High' : (val >= 40 ? 'Medium' : 'Low');

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r[0] as String, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        TagWidget(text: tagText, type: tagType),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomProgressBar(value: val.toDouble(), isWarning: tagType == 'm', isDanger: tagType == 'h'),
                    const SizedBox(height: 6),
                    Text(r[2] as String, style: TextStyle(color: mutedColor, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
          if (crops.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text("Best-suited crops for this site", style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            Text("Ranked from local temperature, rainfall, soil pH and water need", style: TextStyle(color: mutedColor, fontSize: 12)),
            const SizedBox(height: 12),
            ...crops.take(5).map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("#${c.rank}  ", style: TextStyle(color: mutedColor, fontWeight: FontWeight.bold)),
                          Expanded(child: Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                          Text(c.score.toStringAsFixed(0), style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.bold, color: accent)),
                          Text("/100", style: TextStyle(color: mutedColor, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomProgressBar(value: c.score),
                      const SizedBox(height: 6),
                      Text(
                        "${c.label} · Best months: ${c.suitableMonths.isEmpty ? '–' : c.suitableMonths.join(', ')} · Est. irrigation ${c.irrigationMm.toStringAsFixed(0)} mm/season",
                        style: TextStyle(color: mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                )),
          ],
          const NoteCard(text: "Satellite pixels cover large areas (from about 30 m up to several km). Conditions in your own field may differ."),
        ],
      ),
    );
  }
}