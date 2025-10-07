import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/domain/model/user_profile.dart';
import 'package:sistem_pengaduan/presentation/controllers/pengaduan_controller.dart';
import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/widgets/card_category_widget.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/widgets/card_pengaduan.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/widgets/card_slider_widget.dart';
import 'package:sistem_pengaduan/presentation/views/search_page/widgets/search_widget.dart';
import 'package:sistem_pengaduan/presentation/views/user_profile.dart/user_profile_screen.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/skeleton_loading.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class HomeView extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const HomeView({Key? key, this.onMenuTap}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
// --------------------------- DESIGN CONSTANTS ---------------------------

  static const double kHorizontalPadding = 24.0;
  static const double kVerticalSection = 24.0;
  static const double kVerticalSmall = 12.0;

// --------------------------- INITIALIZE DATA ---------------------------

  late Future<UserProfile?> _userProfileFuture;
  bool _isContentReady =
      false; // true when images & other heavy elements are ready

  final UserController _usercontroller = UserController();

  @override
  void initState() {
    super.initState();
    // get all pengaduan
    _loadAllPengaduan();
    // get user Profile
    _userProfileFuture = _usercontroller.getUserProfile();
  }

  Future<void> _refreshData() async {
    // Reset readiness so skeletons show while reloading
    setState(() {
      _isContentReady = false;
    });

    await _loadAllPengaduan();

    setState(() {
      _userProfileFuture = _usercontroller.getUserProfile();
    });
  }

  // --------------------------- LOAD ALL DATA ---------------------------
  List<Pengaduan>? _allPengaduan;

  final PengaduanController _controller = PengaduanController();

  Future<void> _loadAllPengaduan() async {
    _allPengaduan = await _controller.getAllPengaduan();
    print('Total pengaduan: ${_allPengaduan?.length ?? 0}');

    // Pre-cache images (pengaduan images + profile image when available)
    try {
      // Precache all pengaduan images
      if (_allPengaduan != null && _allPengaduan!.isNotEmpty) {
        for (final p in _allPengaduan!) {
          if (p.gambar.isNotEmpty) {
            // ignore: use_build_context_synchronously
            precacheImage(NetworkImage(p.gambar), context).catchError((e) {
              // ignore individual image errors
            });
          }
        }
      }

      // Also attempt to precache profile image (if already available via future)
      _userProfileFuture.then((profile) {
        if (profile != null && profile.profileImage.isNotEmpty) {
          precacheImage(NetworkImage(profile.profileImage), context)
              .catchError((_) {});
        }
      }).catchError((_) {});
    } catch (e) {
      // swallow errors so load doesn't fail
    }

    // Small delay to allow precache futures to schedule; we keep skeleton until
    // next microtask frame when images are likely ready. If network is slow,
    // specific images will load later but main layout will be ready.
    Future.delayed(const Duration(milliseconds: 150)).then((_) {
      setState(() {
        _isContentReady = true;
      });
    });
  }

// --------------------------- CATEGORY ---------------------------

  String _selectedCategory = "";

  Future<List<Pengaduan>> _getFutureByCategory() async {
    if (_selectedCategory.isEmpty) {
      return _allPengaduan ?? [];
    }
    Kategori selectedKategori =
        Kategori.fromString(_selectedCategory.toUpperCase());
    return _allPengaduan
            ?.where((pengaduan) => pengaduan.kategori == selectedKategori)
            .toList() ??
        [];
  }

  void _loadKategori(String category) {
    setState(() {
      _selectedCategory = category;
      print('Kategori dipilih: $_selectedCategory');
    });
  }

  void _resetCategory() {
    setState(() {
      _selectedCategory = '';
      print('Kategori direset');
    });
  }

  // ------------------- SNACKBAR SESSION BREAK -------------------

  void _showSnackBar(String message) {
    ModernSnackBar.showWarning(context, message);
  }

  @override
  Widget build(BuildContext context) {
    // Get safe area padding for full screen display
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: Padding(
              padding: EdgeInsets.only(
                left: kHorizontalPadding,
                right: kHorizontalPadding,
                top: topPadding + kVerticalSmall, // Status bar + small spacing
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------- TOP BAR (menu/title/avatar) -------------------
                    FutureBuilder<UserProfile?>(
                      future: _userProfileFuture,
                      builder: (context, snapshot) {
                        // While waiting, show a small skeleton for the header
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SkeletonProfileHeader();
                        } else if (snapshot.hasError) {
                          // Handle token invalid -> force login
                          if (snapshot.error
                              .toString()
                              .contains('Token tidak valid')) {
                            Future.microtask(() {
                              _showSnackBar(
                                  'Session habis, silakan login kembali');
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                                (Route<dynamic> route) => false,
                              );
                            });
                            return const SizedBox.shrink();
                          }
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final UserProfile? userProfile = snapshot.data;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onMenuTap,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/menu_bar.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Home Page",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (userProfile != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfilePage(),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: const Color(0xFFE8EAED),
                                    backgroundImage: NetworkImage(
                                      userProfile?.profileImage ?? '',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Modern Search - outside of the welcome card
                    SizedBox(
                      width: double.infinity,
                      child: const SearchWidget(),
                    ),

                    const SizedBox(height: 20),

                    // ------------------- WELCOME CARD (compact) -------------------
                    FutureBuilder<UserProfile?>(
                      future: _userProfileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SkeletonProfileHeader();
                        } else if (snapshot.hasError) {
                          return const SizedBox.shrink();
                        } else if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userProfile = snapshot.data!;

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                const Color(0xFFF8F9FF),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: kVerticalSmall),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome Back",
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userProfile.nama,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // ---------------------- SLIDE CARDS ----------------------

                    // Subtitle + icon above slider (gives context and visual weight)
                    Container(
                      margin: const EdgeInsets.only(
                          top: 2, bottom: kVerticalSmall / 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(Icons.star,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sorotan Hari Ini',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Item teratas dan update terbaru',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // optional small quick action
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.08)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.trending_up,
                                      size: 16, color: Color(0xFF6366F1)),
                                  const SizedBox(width: 6),
                                  Text('Lihat',
                                      style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          color: Color(0xFF6366F1))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // const SizedBox(height: kVerticalSmall),
                    // Keep skeleton slider until content (images) are ready
                    (!_isContentReady || _allPengaduan == null)
                        ? const Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: SkeletonSliderLoading(),
                          )
                        : AutoSlideCards(pengaduanList: _allPengaduan ?? []),
                    const SizedBox(height: kVerticalSection),

                    // ------------------- SELECTED CARD ROW -------------------

                    ThreeCardsRow(
                      selectedCategory: _selectedCategory,
                      onCategoryTap: _loadKategori,
                      onReset: _resetCategory,
                    ),

                    // ------------------- LIST OF CATEGORY SECTION -------------------

                    Container(
                      margin: const EdgeInsets.only(
                          top: kVerticalSection, bottom: kVerticalSmall),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Recent Reports",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(), // <-- push the button to the right
                          InkWell(
                            onTap: () {
                              // TODO: handle "View All" tap
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "View All",
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<List<Pengaduan>>(
                      future: _getFutureByCategory(),
                      builder: (context, snapshot) {
                        // While waiting for data OR while images aren't ready,
                        // show the list skeleton to avoid flicker
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !_isContentReady) {
                          return const SkeletonListView(itemCount: 4);
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 80, bottom: 180),
                              child: Container(
                                child: Text(
                                  "Maaf, Tidak Tersedia.",
                                  style: GoogleFonts.roboto(
                                    fontSize: 13.5,
                                    color: Color.fromARGB(255, 66, 66, 66),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 100.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(top: 10),
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                Pengaduan pengaduan = snapshot.data![index];
                                return buildPengaduanCard(context, pengaduan);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ------------------- FLOATING BUTTON -------------------

        // floatingActionButton managed by MainNavigationScreen
      ],
    );
  }
}
