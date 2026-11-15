import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme.dart';

/// Small pill showing whether screens show live API data or demo fallbacks.
class DataStatusChip extends StatelessWidget {
  final AppState state;
  const DataStatusChip({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFF9AAB9F) : AppTheme.lightMuted;
    final Color dot = switch (state.apiStatus) {
      ApiStatus.online => const Color(0xFF3E8E5A),
      ApiStatus.loading => const Color(0xFFC9892B),
      ApiStatus.offline => const Color(0xFFB5503C),
    };
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        Text('${state.location} · ${state.dataLabel}', style: TextStyle(color: muted, fontSize: 13)),
        if (state.apiStatus == ApiStatus.offline)
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 24)),
            onPressed: state.loadAll,
            child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double value;
  final bool isWarning;
  final bool isDanger;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.isWarning = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color barColor = isDark ? const Color(0xFF8FC3A0) : AppTheme.lightFg;
    if (isWarning) barColor = const Color(0xFFC9892B);
    if (isDanger) barColor = const Color(0xFFB5503C);

    return Container(
      height: 9,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF223028) : AppTheme.lightSg2,
        borderRadius: BorderRadius.circular(9),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (value / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }
}

class TagWidget extends StatelessWidget {
  final String text;
  final String type; // 'm' for medium, 'h' for high, '' for normal

  const TagWidget({super.key, required this.text, this.type = ''});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? const Color(0xFF223028) : AppTheme.lightSg2;
    Color fg = isDark ? const Color(0xFF8FC3A0) : AppTheme.lightFg;

    if (type == 'm') {
      bg = const Color(0xFFF1DEB6);
      fg = const Color(0xFF6A4A0C);
    } else if (type == 'h') {
      bg = const Color(0xFFF1CBC2);
      fg = const Color(0xFF7A2A1B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String text;

  const NoteCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF223028) : AppTheme.lightSg2,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFF4F7F9A), width: 4),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFE8EEE9) : AppTheme.lightInk),
      ),
    );
  }
}

class AppFooter extends StatelessWidget {
  final bool live;
  const AppFooter({super.key, this.live = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF2E3D33) : AppTheme.lightBorder)),
      ),
      child: Text(
        live
            ? 'FarmWise · built for NASA Space Apps Challenge · Figures come from NASA POWER, GPM, SMAP, MODIS, ISRIC SoilGrids and FAO data for the El-Zankalon study area. Decision support only: validate with soil tests and local agronomists.'
            : 'FarmWise · built for NASA Space Apps Challenge · All figures shown are labeled demonstration data, not live NASA measurements. Decision support only: validate with soil tests and local agronomists.',
        textAlign: TextAlign.center,
        style: TextStyle(color: isDark ? const Color(0xFF9AAB9F) : AppTheme.lightMuted, fontSize: 13),
      ),
    );
  }
}