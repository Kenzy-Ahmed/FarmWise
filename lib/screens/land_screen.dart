import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/app_state.dart';

class LandScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onNavigateToRot;

  const LandScreen({super.key, required this.state, required this.onNavigateToRot});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final mutedColor = isDark ? const Color(0xFF9AAB9F) : const Color(0xFF5D6B62);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;
    final chipBg = isDark ? const Color(0xFF223028) : const Color(0xFFE3EBDF);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Land analysis", style: GoogleFonts.bricolageGrotesque(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(state.layers.length, (index) {
                bool selected = state.activeLayer == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(state.layers[index]),
                    selected: selected,
                    selectedColor: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C),
                    labelStyle: TextStyle(
                      color: selected 
                          ? (isDark ? const Color(0xFF10221A) : Colors.white) 
                          : textColor, 
                      fontSize: 12,
                    ),
                    backgroundColor: cardBg,
                    onSelected: (_) => state.setLayer(index),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTapUp: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localOffset = box.globalToLocal(details.globalPosition);
              state.addPoint(localOffset);
            },
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: CustomPaint(
                painter: MapPainter(layer: state.activeLayer, points: state.fieldPoints, isDark: isDark),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Click map to outline field", style: TextStyle(color: mutedColor, fontSize: 12)),
              TextButton(
                onPressed: () => state.clearPoints(),
                child: Text("Clear field", style: TextStyle(color: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C), fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Location", textColor),
                TextFormField(
                  initialValue: state.location,
                  onChanged: state.updateLocation,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(borderColor),
                ),
                _buildLabel("Field area (hectares)", textColor),
                TextFormField(
                  initialValue: state.area,
                  keyboardType: TextInputType.number,
                  onChanged: state.updateArea,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(borderColor),
                ),
                _buildLabel("Soil type", textColor),
                DropdownButtonFormField<String>(
                  value: state.soilType,
                  dropdownColor: cardBg,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(borderColor),
                  items: ["Clay loam", "Sandy", "Silty", "Loam", "Not sure"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: textColor))))
                      .toList(),
                  onChanged: (val) { if (val != null) state.updateSoil(val); },
                ),
                _buildLabel("Current rotation", textColor),
                TextFormField(
                  initialValue: state.rotation,
                  onChanged: state.updateRotation,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(borderColor),
                ),
                _buildLabel("Irrigation and water", textColor),
                TextFormField(
                  initialValue: state.irrigation,
                  onChanged: state.updateIrrigation,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(borderColor),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C),
                      foregroundColor: isDark ? const Color(0xFF10221A) : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onNavigateToRot,
                    child: const Text("Get rotation advice", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  InputDecoration _inputDecoration(Color borderColor) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
    );
  }
}

class MapPainter extends CustomPainter {
  final int layer;
  final List<Offset> points;
  final bool isDark;

  MapPainter({required this.layer, required this.points, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    int cols = 12;
    int rows = 8;
    double cellW = size.width / cols;
    double cellH = size.height / rows;

    List<double> hues = [210, 25, 200, 100, 12, 40];
    double h = hues[layer];for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        double v = (sin(x * 1.3 + layer) * cos(y * 0.9 + layer * 2) + 1) / 2;
        double lightness = isDark ? (0.2 + v * 0.2) : (0.85 - v * 0.5);
        HSLColor hsl = HSLColor.fromAHSL(1.0, h, isDark ? 0.3 : 0.45, lightness.clamp(0.1, 0.9));

        Paint paint = Paint()..color = hsl.toColor();
        canvas.drawRect(Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH), paint);
      }
    }

    if (points.isNotEmpty) {
      Paint polyPaint = Paint()
        ..color = (isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C)).withOpacity(0.35)
        ..style = PaintingStyle.fill;
      Paint strokePaint = Paint()
        ..color = isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      Path path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();

      canvas.drawPath(path, polyPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}