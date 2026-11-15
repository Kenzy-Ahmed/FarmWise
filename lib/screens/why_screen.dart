import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../widgets/custom_widgets.dart';

class WhyScreen extends StatelessWidget {
  final AppState state;
  const WhyScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;

    final glossary = [
      ["Soil moisture anomaly", "How much wetter or drier the soil is than usual."],
      ["NDVI", "A greenness score from 0 to 1; higher means healthier plants."],
      ["Evapotranspiration", "Water lost from soil and leaves into the air."],
      ["Vegetation stress", "Plants growing poorly, often from heat or thirst."],
      ["Water balance", "Water coming in (rain, irrigation) minus water lost."],
      ["Frost risk", "Chance of freezing temperatures that damage crops."],
    ];

    final high = state.risks?.where((r) => r.level != 'Low').map((r) => r.label.toLowerCase()).toList();
    final indicators = high != null && high.isNotEmpty
        ? "Elevated: ${high.join(', ')}. Based on ${state.metrics?.map((m) => m.label.toLowerCase()).join(', ')}."
        : "Low soil moisture, low rainfall, high heat and water stress.";
    final datasets = state.dataSources != null
        ? state.dataSources!.map((d) => d.name).join(', ')
        : "SMAP, GPM, ECOSTRESS, MODIS/Landsat, POWER (demo values here).";
    final top = state.cropRecommendations?.isNotEmpty == true ? state.cropRecommendations!.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Why this recommendation?", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            double w = constraints.maxWidth > 600 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _card("Indicators used", indicators, w, cardBg, borderColor, textColor),
                _card("Datasets", datasets, w, cardBg, borderColor, textColor),
                _card("Crop traits", "Water need, nitrogen fixing, temperature range, soil pH, cover and residue (FAO ECOCROP / GAEZ).", w, cardBg, borderColor, textColor),
                _card("Uncertainty", state.isLive
                    ? "Satellite pixels are 250 m to ~10 km, soil values are modelled (no lab test), and the crop model is rule-based."
                    : "Demo data, coarse pixels, no soil test, simplified crop model.", w, cardBg, borderColor, textColor),
              ],
            );
          }),
          if (top != null) ...[
            const SizedBox(height: 24),
            Text("Top crop: ${top.name}", style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 6),
            Text(top.summary, style: TextStyle(color: textColor)),
            const SizedBox(height: 8),
            ...top.strengths.map((t) => Text("✓ $t", style: TextStyle(color: textColor))),
            ...top.limitations.map((t) => Text("! $t", style: TextStyle(color: textColor))),
          ],
          const SizedBox(height: 24),
          Text("Plain-language glossary", style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          Column(
            children: glossary.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${g[0]}: ", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  Expanded(child: Text(g[1], style: TextStyle(color: textColor))),
                ],
              ),
            )).toList(),
          ),
          const NoteCard(text: "Confirm advice with a soil test and a local agricultural expert. You make the final decision."),
        ],
      ),
    );
  }

  Widget _card(String title, String desc, double width, Color cardBg, Color borderColor, Color textColor) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 6),
          Text(desc, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }
}