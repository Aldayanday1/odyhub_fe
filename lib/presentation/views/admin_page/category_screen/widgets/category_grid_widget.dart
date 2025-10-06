import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/views/admin_page/category_screen/category_screen.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.pengaduanList});

  final List<Pengaduan> pengaduanList;

  void _navigateToCategoryPage(BuildContext context, Kategori category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          category: category,
          pengaduanList: pengaduanList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = Kategori.values;

    // Per-category accents (icon + color)
    final Map<Kategori, Map<String, dynamic>> accents = {
      Kategori.INFRASTRUKTUR: {
        'color': Color(0xFF6EE7B7),
        'icon': Icons.location_city_outlined,
      },
      Kategori.LINGKUNGAN: {
        'color': Color(0xFF60A5FA),
        'icon': Icons.eco_outlined,
      },
      Kategori.TRANSPORTASI: {
        'color': Color(0xFFFDBA74),
        'icon': Icons.directions_bus_outlined,
      },
      Kategori.KEAMANAN: {
        'color': Color(0xFFFB7185),
        'icon': Icons.shield_outlined,
      },
      Kategori.KESEHATAN: {
        'color': Color(0xFF60F0D2),
        'icon': Icons.health_and_safety_outlined,
      },
      Kategori.PENDIDIKAN: {
        'color': Color(0xFFA78BFA),
        'icon': Icons.school_outlined,
      },
      Kategori.SOSIAL: {
        'color': Color(0xFFFDE68A),
        'icon': Icons.people_outline,
      },
      Kategori.IZIN: {
        'color': Color(0xFF93C5FD),
        'icon': Icons.assignment_ind_outlined,
      },
      Kategori.BIROKRASI: {
        'color': Color(0xFFD1FAE5),
        'icon': Icons.account_balance_outlined,
      },
      Kategori.LAINNYA: {
        'color': Color.fromARGB(255, 251, 207, 232),
        'icon': Icons.more_horiz,
      },
    };

    final Map<Kategori, int> categoryCounts = {};
    for (var category in categories) {
      categoryCounts[category] = pengaduanList
          .where((pengaduan) => pengaduan.kategori == category)
          .length;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final count = categoryCounts[category] ?? 0;
          final accent = accents[category] ??
              {'color': Color(0xFF6366F1), 'icon': Icons.label_outline};
          final Color accentColor = accent['color'] as Color;
          final IconData accentIcon = accent['icon'] as IconData;

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _navigateToCategoryPage(context, category),
              child: Stack(
                children: [
                  // Decorative soft shape top-right
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            accentColor.withOpacity(0.18),
                            Colors.transparent
                          ],
                        ),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor,
                                    accentColor.withOpacity(0.75)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                accentIcon,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const Spacer(),
                            // count badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.08)),
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category.displayName,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
