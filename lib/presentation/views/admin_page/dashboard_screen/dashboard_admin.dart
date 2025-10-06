import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/daily_graph.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/controllers/pengaduan_controller.dart';
import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
import 'package:sistem_pengaduan/presentation/views/admin_page/category_screen/widgets/category_grid_widget.dart';
import 'package:sistem_pengaduan/presentation/views/admin_page/dashboard_screen/widgets/graph_widget.dart';
import 'package:sistem_pengaduan/presentation/views/admin_page/status_screen/widgets/status_widget.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_admin_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/search_page/widgets/search_widget.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/skeleton_loading.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_confirm_dialog.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

import '../../../../data/services/pengaduan_service.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({Key? key}) : super(key: key);

  @override
  State<DashboardAdmin> createState() => _HomeViewState();
}

class _HomeViewState extends State<DashboardAdmin> {
  // --------------------------- DESIGN CONSTANTS ---------------------------
  static const double kHorizontalPadding = 24.0;
  static const double kVerticalSection = 24.0;
  static const double kBorderRadius = 16.0;
  static const Color kDarkGrey = Color(0xFF2D3748);
  static const Color kMediumGrey = Color(0xFF4A5568);
  static const Color kBackground = Color(0xFFF8F9FA);
  static const Color kAccentPrimary = Color(0xFF6366F1);
  static const Color kAccentSecondary = Color(0xFF8B5CF6);

// --------------------------- INITIALIZE DATA --------------------------

  @override
  void initState() {
    super.initState();
    _loadAllPengaduan();
    _refreshGraph();
  }

  Future<void> _refreshData() async {
    await _loadAllPengaduan();
    await _refreshGraph();
    setState(() {});
  }

  // --------------------------- LOAD ALL DATA ---------------------------

  List<Pengaduan>? _allPengaduan;

  final PengaduanController _controller = PengaduanController();

  Future<void> _loadAllPengaduan() async {
    _allPengaduan = await _controller.getAllPengaduan();
    print('Total pengaduan: ${_allPengaduan?.length ?? 0}');
    setState(() {});
  }

  // ------------------- ANIMATED GRAPH -------------------

  late Future<List<PengaduanDaily>> futurePengaduanGraph;

  Future<void> _refreshGraph() async {
    futurePengaduanGraph = PengaduanService().fetchDailyPengaduanCount();
  }

  // ------------------- SNACKBAR SESSION BREAK -------------------

  // void _showSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message)),
  //   );
  // }

  // ------------------- LOGOUT FUNCTION -------------------

  final UserController userController = UserController();

  // Method to show the logout confirmation dialog using the reusable modern dialog
  void _showLogoutConfirmationDialog() {
    ModernConfirmDialog.show(
      context: context,
      title: 'Konfirmasi Logout',
      content: 'Apakah Anda yakin ingin logout?',
      confirmText: 'Ya',
      cancelText: 'Tidak',
      isDanger: false,
    ).then((confirmed) {
      if (confirmed == true) {
        _logout();
      }
    });
  }

// Method to handle logout
  Future<void> _logout() async {
    try {
      await userController.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminLoginPage()),
        // Menghapus semua route dari stack
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle logout error
      print('Error during logout: $e');
      ModernSnackBar.showError(
        context,
        'Logout failed: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: kBackground,
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kHorizontalPadding,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------- HEADER -------------------
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Menu icon in modern container
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.dashboard_outlined,
                                color: kAccentPrimary,
                                size: 22,
                              ),
                            ),
                            // Title
                            Text(
                              "Dashboard Admin",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: kDarkGrey,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            // Logout button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showLogoutConfirmationDialog,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.logout_outlined,
                                    color: kMediumGrey,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search widget
                      SearchWidget(),
                      const SizedBox(
                          height:
                              kVerticalSection), // // -------------------- SLIDE CARDS --------------------

                      // AutoSlideCardsAdmin(pengaduanList: _allPengaduan ?? []),

                      // ------------------- TOTAL PENGADUAN -------------------
                      FutureBuilder<List<Pengaduan>>(
                        future: _controller.getAllPengaduan(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SkeletonTotalCount();
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            final totalPengaduan = snapshot.data!.length;
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [kAccentPrimary, kAccentSecondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    BorderRadius.circular(kBorderRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: kAccentPrimary.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.assessment_outlined,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Pengaduan',
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$totalPengaduan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 36,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      const SizedBox(height: kVerticalSection),

                      // ------------------- ANIMATED GRAPH -------------------
                      PengaduanChart(
                        futurePengaduanGraph: futurePengaduanGraph,
                      ),
                      const SizedBox(height: kVerticalSection),

                      // ------------------------  STATUS CATEGORY ------------------------
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kAccentPrimary, kAccentSecondary],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Status Category",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: kDarkGrey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PengaduanStatusCard(status: "PENDING"),
                      const SizedBox(height: 12),
                      PengaduanStatusCard(status: "PROGRESS"),
                      const SizedBox(height: 12),
                      PengaduanStatusCard(status: "DONE"),
                      const SizedBox(height: kVerticalSection),

                      // ------------------- LIST OF GRID -------------------
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kAccentPrimary, kAccentSecondary],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "List of Complaint",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: kDarkGrey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Pengaduan>>(
                        future: _controller.getAllPengaduan(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SkeletonCategoryGrid();
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return CategoryGrid(
                                pengaduanList: _allPengaduan ?? []);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
