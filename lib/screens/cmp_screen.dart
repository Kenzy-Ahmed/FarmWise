import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../widgets/custom_widgets.dart';

class CmpScreen extends StatelessWidget {
  final AppState state;
  const CmpScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final st = state.strategies;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;

    final rows = [
      ["Water demand (lower is better)", "w"],
      ["Soil improvement", "soil"],
      ["Climate resilience", "cl"],
      ["Nitrogen fixing", "N"],
      ["Erosion reduction", "ero"],
      ["Income potential (rough)", "inc"],
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Compare strategies", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  DataColumn(label: Text('', style: TextStyle(color: textColor))),
                  ...st.map((s) => DataColumn(label: Text(s.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)))),
                ],
                rows: [
                  ...rows.map((r) {
                    String metricKey = r[1];
                    return DataRow(
                      cells: [
                        DataCell(Text(r[0], style: TextStyle(color: textColor))),
                        ...st.map((s) {
                          int val = _getMetricValue(s, metricKey);
                          return DataCell(
                            SizedBox(
                              width: 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$val%', style: TextStyle(color: textColor)),
                                  CustomProgressBar(value: val.toDouble(), isWarning: metricKey == 'w'),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                  DataRow(
                    cells: [
                      DataCell(Text('Crop sequence', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                      ...st.map((s) => DataCell(Text(s.sequence.join(' → '), style: TextStyle(color: textColor)))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const NoteCard(text: "Trade-offs: the soil health strategy builds the most nitrogen and organic matter but uses more water than the climate strategy. The climate strategy saves water and handles heat best, but its soil gains are smaller and its market may be narrower. Neither is best everywhere."),
        ],
      ),
    );
  }int _getMetricValue(Strategy s, String key) {
    switch (key) {
      case 'w': return s.waterDemand;
      case 'soil': return s.soilBenefit;
      case 'cl': return s.climateSuitability;
      case 'N': return s.nitrogenPotential;
      case 'ero': return s.erosionReduction;
      case 'inc': return s.incomePotential;
      default: return 0;
    }
  }
}