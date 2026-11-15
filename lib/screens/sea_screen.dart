import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeaScreen extends StatelessWidget {
  const SeaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final mutedColor = isDark ? const Color(0xFF9AAB9F) : const Color(0xFF5D6B62);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;

    final months = ["J","F","M","A","M","J","J","A","S","O","N","D"];
    final rain = [22,18,14,6,2,0,0,0,1,6,16,22];
    final tmp = [14,15,18,23,28,31,33,33,30,26,20,15];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Seasonal insights", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          Text("Typical pattern, Demo data (illustrative, Oct 2026)", style: TextStyle(color: mutedColor)),
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
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: 20 + r * 3,
                        decoration: BoxDecoration(
                          color: r < 5 ? const Color(0xFFE3C27D) : (isDark ? const Color(0xFF3E5A48) : const Color(0xFFA9BFA4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(months[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
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
                          color: t > 29 ? const Color(0xFFB5503C) : (isDark ? const Color(0xFF223028) : const Color(0xFFE3EBDF)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text('$t°', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text("Field status (current rotation)", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),const SizedBox(height: 8),
                Row(
                  children: List.generate(12, (i) {
                    bool isBare = i >= 5 && i <= 8;
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
              children: [
                _card("Vulnerable", "May–Sep: little rain and heat above 29 °C.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _card("Cover crop window", "Oct–Nov, when rain returns and the field sits bare.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _card("Rotation windows", "Late Oct for cool-season crops; April for summer crops.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
              ],
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