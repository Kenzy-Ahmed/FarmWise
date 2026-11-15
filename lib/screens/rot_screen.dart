import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../widgets/custom_widgets.dart';

class RotScreen extends StatelessWidget {
  final AppState state;
  const RotScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final strategies = state.strategies;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final mutedColor = isDark ? const Color(0xFF9AAB9F) : const Color(0xFF5D6B62);
    final chipBg = isDark ? const Color(0xFF223028) : const Color(0xFFE3EBDF);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rotation advisor", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          Text("What matters most to you?", style: TextStyle(color: mutedColor)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: state.priorityNames.entries.map((e) {
              bool selected = state.priorities[e.key] ?? false;
              return ChoiceChip(
                label: Text(e.value),
                selected: selected,
                selectedColor: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C),
                labelStyle: TextStyle(
                  color: selected 
                      ? (isDark ? const Color(0xFF10221A) : Colors.white) 
                      : textColor, 
                  fontSize: 13,
                ),
                backgroundColor: Theme.of(context).cardColor,
                onSelected: (_) => state.togglePriority(e.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: strategies.length,
            itemBuilder: (context, index) {
              final s = strategies[index];
              int score = state.calculateScore(s);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$score', style: GoogleFonts.bricolageGrotesque(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C))),
                        Text('/100', style: TextStyle(color: mutedColor, fontSize: 14)),
                      ],
                    ),
                    Text('Decision-support indicator, not a guarantee.', style: TextStyle(color: mutedColor, fontSize: 12)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,child: Row(
                        children: s.sequence.map((item) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _metricRow("Water demand", s.waterDemand, mutedColor, isWarning: true),
                    _metricRow("Soil benefit", s.soilBenefit, mutedColor),
                    _metricRow("Nitrogen potential", s.nitrogenPotential, mutedColor),
                    _metricRow("Erosion reduction", s.erosionReduction, mutedColor),
                    _metricRow("Climate suitability", s.climateSuitability, mutedColor),
                    const SizedBox(height: 10),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "Why: ", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      TextSpan(text: s.why, style: TextStyle(color: textColor)),
                    ])),
                    const SizedBox(height: 4),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "Risks: ", style: TextStyle(fontWeight: FontWeight.bold, color: mutedColor)),
                      TextSpan(text: s.risk, style: TextStyle(color: mutedColor)),
                    ])),
                  ],
                ),
              );
            },
          ),
          const NoteCard(text: "Scores come from a transparent weighted average of the indicators above using your chosen priorities. They are rule-based demo estimates, not validated predictions."),
        ],
      ),
    );
  }

  Widget _metricRow(String title, int val, Color mutedColor, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title $val%', style: TextStyle(fontSize: 12, color: mutedColor)),
          const SizedBox(height: 2),
          CustomProgressBar(value: val.toDouble(), isWarning: isWarning),
        ],
      ),
    );
  }
}