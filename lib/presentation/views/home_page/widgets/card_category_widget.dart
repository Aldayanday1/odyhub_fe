import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThreeCardsRow extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryTap;
  final VoidCallback onReset;

  const ThreeCardsRow({
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.onReset,
  });

  @override
  State<ThreeCardsRow> createState() => _ThreeCardsRowState();
}

class _ThreeCardsRowState extends State<ThreeCardsRow> {
  String _lastSelectedCategory = '';

  void _handleCardTap(String category) {
    if (_lastSelectedCategory == category) {
      widget.onReset();
      _lastSelectedCategory = '';
    } else {
      widget.onCategoryTap(category);
      _lastSelectedCategory = category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildCard(
                "Infrastruktur",
                widget.selectedCategory == "Infrastruktur",
                () => _handleCardTap("Infrastruktur")),
            buildCard("Lingkungan", widget.selectedCategory == "Lingkungan",
                () => _handleCardTap("Lingkungan")),
            buildCard("Transportasi", widget.selectedCategory == "Transportasi",
                () => _handleCardTap("Transportasi")),
            buildCard("Keamanan", widget.selectedCategory == "Keamanan",
                () => _handleCardTap("Keamanan")),
            buildCard("Kesehatan", widget.selectedCategory == "Kesehatan",
                () => _handleCardTap("Kesehatan")),
            buildCard("Pendidikan", widget.selectedCategory == "Pendidikan",
                () => _handleCardTap("Pendidikan")),
            buildCard("Sosial", widget.selectedCategory == "Sosial",
                () => _handleCardTap("Sosial")),
            buildCard(
                "Perizinan dan Regulasi",
                widget.selectedCategory == "Izin",
                () => _handleCardTap("Izin")),
            buildCard("Birokrasi", widget.selectedCategory == "Birokrasi",
                () => _handleCardTap("Birokrasi")),
            buildCard("Lainnya", widget.selectedCategory == "Lainnya",
                () => _handleCardTap("Lainnya")),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String title, bool isSelected, VoidCallback onTap) {
    // Minimal pill: smaller height, tighter padding, optional icon
    final icon = _iconForCategory(title);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color:
                    isSelected ? Colors.transparent : const Color(0xFFF1F3F5),
                width: 1.0,
              ),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 16,
                      color:
                          isSelected ? Colors.white : const Color(0xFF5B6170)),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      color:
                          isSelected ? Colors.white : const Color(0xFF374151),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData? _iconForCategory(String title) {
    // Simple mapping for common categories; extend as needed
    final t = title.toLowerCase();
    if (t.contains('infrastruktur')) return Icons.account_tree_outlined;
    if (t.contains('lingkungan')) return Icons.nature_outlined;
    if (t.contains('transport')) return Icons.directions_bus_outlined;
    if (t.contains('keamanan')) return Icons.security_outlined;
    if (t.contains('kesehatan')) return Icons.local_hospital_outlined;
    if (t.contains('pendidikan')) return Icons.school_outlined;
    if (t.contains('sosial')) return Icons.people_outline;
    if (t.contains('izin') || t.contains('perizinan')) return Icons.rule_folder;
    if (t.contains('birokrasi')) return Icons.work_outline;
    return null; // default: no icon
  }
}
