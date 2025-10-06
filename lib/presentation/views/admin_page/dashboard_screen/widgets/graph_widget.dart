import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/daily_graph.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_admin_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/skeleton_loading.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class PengaduanChart extends StatefulWidget {
  const PengaduanChart({Key? key, required this.futurePengaduanGraph})
      : super(key: key);

  final Future<List<PengaduanDaily>> futurePengaduanGraph;

  @override
  _PengaduanChartState createState() => _PengaduanChartState();
}

class _PengaduanChartState extends State<PengaduanChart> {
  // ------------------- SNACKBAR SESSION BREAK -------------------

  void _showSnackBar(String message) {
    ModernSnackBar.showWarning(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PengaduanDaily>>(
      future: widget.futurePengaduanGraph,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonChartLoading();
        } else if (snapshot.hasError) {
          // ------- BREAK SESSION GRAPH -------
          // Jika error karena token tidak valid, arahkan ke halaman login
          if (snapshot.error.toString().contains('Token tidak valid')) {
            Future.microtask(
              () {
                _showSnackBar('Session habis, silakan login kembali');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            );
            return SizedBox.shrink(); // Mengembalikan widget kosong sementara
          }
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return _buildChart(snapshot.data!);
        }
      },
    );
  }

  Widget _buildChart(List<PengaduanDaily> pengaduanList) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 209, 223, 255).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(10, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "Data Per Hari",
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 13,
                          color: const Color.fromARGB(255, 87, 87, 87),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: LineChart(
                            _buildLineChartData(pengaduanList),
                            swapAnimationDuration:
                                const Duration(milliseconds: 250),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(List<PengaduanDaily> pengaduanList) {
    return LineChartData(
      // ------------ GARIS VERTIKAL DAN HORIZONTAL GRAFIK ----------

      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,

        // ---- HORIZONTAL LINE -----
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xffe7e8ec),
          strokeWidth: 1,
        ),

        // ---- VERTICAL LINE -----
        getDrawingVerticalLine: (value) => FlLine(
          color: const Color(0xffe7e8ec),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          getTitles: (value) {
            if (value.toInt() % 5 == 0) {
              return value.toInt().toString();
            }
            return '';
          },
          margin: 8,
        ),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'Mon';
              case 1:
                return 'Tue';
              case 2:
                return 'Wed';
              case 3:
                return 'Thu';
              case 4:
                return 'Fri';
              case 5:
                return 'Sat';
              case 6:
                return 'Sun';
            }
            return '';
          },
          margin: 20,
        ),
        rightTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          getTitles: (value) => value.toInt().toString(),
          margin: 8,
        ),
        topTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          getTitles: (value) => value.toInt().toString(),
          margin: 35,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Color(0xffe7e8ec), width: 1),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: pengaduanList
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()))
              .toList(),
          isCurved: true,
          colors: [Colors.blueAccent],
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: Colors.blueAccent,
              strokeWidth: 1,
              strokeColor: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: [Colors.blueAccent.withOpacity(0.2)],
          ),
        ),
      ],
    );
  }
}
