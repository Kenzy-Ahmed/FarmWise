import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';

class WhyScreen extends StatelessWidget {
  const WhyScreen({super.key});

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
                _card("Indicators used", "Low soil moisture, low rainfall, high heat and water stress.", w, cardBg, borderColor, textColor),
                _card("Datasets", "SMAP, GPM, ECOSTRESS, MODIS/Landsat, POWER (demo values here).", w, cardBg, borderColor, textColor),
                _card("Crop traits", "Water need, nitrogen fixing, root depth, organic matter, erosion cover.", w, cardBg, borderColor, textColor),
                _card("Uncertainty", "Demo data, coarse pixels, no soil test, simplified crop model.", w, cardBg, borderColor, textColor),
              ],
            );
          }),
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