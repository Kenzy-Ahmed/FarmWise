import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../widgets/custom_widgets.dart';

class SeaScreen extends StatelessWidget {
  final AppState state;
  const SeaScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final mutedColor = isDark ? const Color(0xFF9AAB9F) : const Color(0xFF5D6B62);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;

    final months = ["J","F","M","A","M","J","J","A","S","O","N","D"];
    final live = state.seasonMonths;
    final rain = live != null ? live.map((m) => m.rainMm.round()).toList() : [22,18,14,6,2,0,0,0,1,6,16,22];
    final tmp = live != null ? live.map((m) => m.tempMean.round()).toList() : [14,15,18,23,28,31,33,33,30,26,20,15];
    final tmax = live != null ? live.map((m) => m.tempMax).toList() : tmp.map((t) => t.toDouble()).toList();
    final bare = live != null ? live.map((m) => m.fieldStatus == 'bare').toList() : List.generate(12, (i) => i >= 5 && i <= 8);
    final cards = state.seasonInsights != null
        ? state.seasonInsights!.map((c) => [c.title, c.text]).toList()
        : [
            ["Vulnerable", "May–Sep: little rain and heat above 29 °C."],
            ["Cover crop window", "Oct–Nov, when rain returns and the field sits bare."],
            ["Rotation windows", "Late Oct for cool-season crops; April for summer crops."],
          ];
    final maxRain = rain.reduce((a, b) => a > b ? a : b).clamp(1, 1000);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Seasonal insights", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          DataStatusChip(state: state),
          if (live != null)
            Text("Typical year: monthly averages 2015–2025 (rain = mean monthly total)", style: TextStyle(color: mutedColor, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rainfall", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(12, (i) {
                    double r = rain[i].toDouble();
                    return Expanded(
                      child: Tooltip(
                        message: "${months[i]}: ${rain[i]} mm",
                        child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: 20 + r / maxRain * 60,
                        decoration: BoxDecoration(
                          color: r < 5 ? const Color(0xFFE3C27D) : (isDark ? const Color(0xFF3E5A48) : const Color(0xFFA9BFA4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(months[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text("Temperature", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(12, (i) {
                    int t = tmp[i];
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: tmax[i] > 35 ? const Color(0xFFB5503C) : (isDark ? const Color(0xFF223028) : const Color(0xFFE3EBDF)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text('$t°', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(live != null ? "Field cover (satellite NDVI)" : "Field status (current rotation)", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),const SizedBox(height: 8),
                Row(
                  children: List.generate(12, (i) {
                    bool isBare = bare[i];
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isBare ? (isDark ? const Color(0xFF4A4033) : const Color(0xFFD9CDB0)) : (isDark ? const Color(0xFF3E5A48) : const Color(0xFFA9BFA4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(isBare ? 'bare' : 'crop', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards.map((c) => _card(c[0], c[1], constraints.maxWidth, cardBg, borderColor, textColor, mutedColor)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _card(String title, String desc, double maxWidth, Color cardBg, Color borderColor, Color textColor, Color mutedColor) {
    double w = maxWidth > 600 ? (maxWidth - 24) / 3 : maxWidth;
    return Container(
      width: w,
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
          Text(desc, style: TextStyle(color: mutedColor, fontSize: 13)),
        ],
      ),
    );
  }
}