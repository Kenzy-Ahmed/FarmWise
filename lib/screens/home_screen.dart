import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  final VoidCallback onScrollToHow;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onScrollToHow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8EEE9) : const Color(0xFF1C2A22);
    final mutedColor = isDark ? const Color(0xFF9AAB9F) : const Color(0xFF5D6B62);
    final borderColor = isDark ? const Color(0xFF2E3D33) : const Color(0xFFDFDFD3);
    final cardBg = Theme.of(context).cardColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1F3D2C),
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2318), Color(0xFF1F3D2C)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grow smarter. Protect your soil. Adapt to climate change.',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'FarmWise turns NASA Earth observations into simple crop rotation choices. It supports your experience; it never replaces it.',
                  style: TextStyle(color: Color(0xFFE6EFE7), fontSize: 15),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F1EA),
                        foregroundColor: const Color(0xFF1F3D2C),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => onNavigate(2),
                      child: const Text('Analyze my land', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onScrollToHow,
                      child: const Text('Explore how it works', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,children: [
                _featureCard("NASA Earth observation insights", "Satellite readings explained in plain words.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _featureCard("Soil health monitoring", "See moisture, greenness and erosion risk.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _featureCard("Climate risk analysis", "Drought, heat and heavy rain, ranked.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _featureCard("Crop rotation recommendations", "Three strategies, with trade-offs shown.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _featureCard("Interactive field mapping", "Outline your field and switch data layers.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
              ],
            );
          }),
          const SizedBox(height: 36),
          Text("How it works", style: GoogleFonts.bricolageGrotesque(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _stepCard("1. Select your location", "Enter your region and outline your field.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _stepCard("2. Analyze conditions", "See soil, water and climate indicators.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
                _stepCard("3. Explore rotation strategies", "Compare options against your priorities.", constraints.maxWidth, cardBg, borderColor, textColor, mutedColor),
              ],
            );
          }),
          const SizedBox(height: 36),
          Text("NASA datasets behind it", style: GoogleFonts.bricolageGrotesque(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          _datasetCard("SMAP", "Soil moisture", "Shows how much water is in the top soil, so you can time planting and spot early drought.", "Favors deep-rooted or drought-tolerant crops where moisture runs low.", cardBg, borderColor, textColor, mutedColor, isDark),
          _datasetCard("ECOSTRESS", "Land surface temperature, evapotranspiration", "Shows how hot plants are and how fast they lose water.", "Flags heat and water stress before leaves show damage.", cardBg, borderColor, textColor, mutedColor, isDark),
          _datasetCard("GPM", "Rainfall", "Rain measured from space every few hours.", "Tells us which seasons are dry and where cover crops can use rain.", cardBg, borderColor, textColor, mutedColor, isDark),
          _datasetCard("Landsat / MODIS", "Vegetation greenness (NDVI)", "Greenness of crops over years.", "Reveals bare-field periods and weak-growth patches.", cardBg, borderColor, textColor, mutedColor, isDark),
          _datasetCard("NASA POWER", "Weather history", "Temperature, sunshine and rain records.", "Sets growing seasons and frost or heat windows.", cardBg, borderColor, textColor, mutedColor, isDark),
          _datasetCard("GRACE-FO", "Groundwater and water storage", "Changes in total water stored underground.", "Warns if irrigation water is declining long-term.", cardBg, borderColor, textColor, mutedColor, isDark),
          _datasetCard("SRTM", "Elevation and slope", "Terrain shape.", "Steeper land needs erosion-reducing crops.", cardBg, borderColor, textColor, mutedColor, isDark),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF223028) : const Color(0xFFE3EBDF),borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: Color(0xFF4F7F9A), width: 4)),
            ),
            child: Text(
              'Honest status: no live NASA API is connected yet. Every number is demonstration data. The data layer is built to be swapped for real SMAP, GPM and POWER requests.',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(String title, String subtitle, double maxWidth, Color cardBg, Color borderColor, Color textColor, Color mutedColor) {
    double itemWidth = maxWidth > 600 ? (maxWidth - 24) / 3 : maxWidth;
    return Container(
      width: itemWidth,
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
          Text(subtitle, style: TextStyle(color: mutedColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _stepCard(String title, String subtitle, double maxWidth, Color cardBg, Color borderColor, Color textColor, Color mutedColor) {
    double itemWidth = maxWidth > 600 ? (maxWidth - 24) / 3 : maxWidth;
    return Container(
      width: itemWidth,
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
          Text(subtitle, style: TextStyle(color: mutedColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _datasetCard(String title, String tag, String desc, String forRot, Color cardBg, Color borderColor, Color textColor, Color mutedColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF223028) : const Color(0xFFE3EBDF),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(tag, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF8FC3A0) : const Color(0xFF1F3D2C))),
          ),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: mutedColor, fontSize: 13)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "For rotations: ", style: TextStyle(fontWeight: FontWeight.bold, color: mutedColor)),
                TextSpan(text: forRot, style: TextStyle(color: mutedColor)),
              ],
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}