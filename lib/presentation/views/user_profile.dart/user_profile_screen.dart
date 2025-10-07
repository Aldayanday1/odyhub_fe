import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sistem_pengaduan/domain/model/user_profile.dart';
import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
import 'package:sistem_pengaduan/presentation/controllers/pengaduan_controller.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/skeleton_loading.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController _userController = UserController();
  late Future<UserProfile?> _userProfileFuture;

  // ------------------- FILE IMAGE PICKER  -------------------

  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  File? _backgroundImage;
  // stats
  int _totalLaporan = 0;
  int _progressLaporan = 0;
  int _selesaiLaporan = 0;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _userController.getUserProfile();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final controller = PengaduanController();
      List<Pengaduan> list = await controller.getMyPengaduan();
      int total = list.length;
      int progress = list
          .where((p) => (p.status ?? '').toUpperCase() == 'PROGRESS')
          .length;
      int done =
          list.where((p) => (p.status ?? '').toUpperCase() == 'DONE').length;
      setState(() {
        _totalLaporan = total;
        _progressLaporan = progress;
        _selesaiLaporan = done;
      });
    } catch (_) {
      // ignore errors silently for stats
    }
  }

  // ------------------- PICK PROFILE IMAGE -------------------

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
      });
    }
  }

  // ------------------- UPDATE PROFILE -------------------

  Future<void> _updateProfile() async {
    try {
      String message = await _userController.updateUserProfile(
          _profileImage, _backgroundImage);
      ModernSnackBar.showSuccess(context, message);
    } catch (e) {
      if (e.toString().contains('Token tidak valid')) {
        // -------BREAK SESSION UPDATE PROFILE-------
        // Token tidak valid, arahkan pengguna ke halaman login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
            settings: RouteSettings(
              arguments: 'Session habis, silakan login kembali',
            ),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        ModernSnackBar.showError(context, 'Error: $e');
      }
    }
  }

  // ------------------- SNACKBAR SESSION BREAK -------------------

  void _showSnackBar(String message) {
    ModernSnackBar.showWarning(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserProfile?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          // memperbarui tampilan sesuai dengan status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SkeletonProfileHeader(),
                  SizedBox(height: 50),
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // -------BREAK SESSION PROFILE-------
            // Jika error karena token tidak valid, arahkan ke halaman login
            if (snapshot.error.toString().contains('Token tidak valid')) {
              Future.microtask(
                () {
                  _showSnackBar('Session habis, silakan login kembali');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              );
              return SizedBox.shrink(); // Mengembalikan widget kosong sementara
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Profil tidak ditemukan'));
          } else {
            UserProfile userProfile = snapshot.data!;

            // Modern profile layout
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFF),
              // floatingActionButton managed by MainNavigationScreen
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top header with background image
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 220 + MediaQuery.of(context).padding.top,
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: _backgroundImage != null
                                  ? FileImage(_backgroundImage!)
                                      as ImageProvider
                                  : (userProfile.backgroundImage.isNotEmpty
                                      ? NetworkImage(
                                          userProfile.backgroundImage)
                                      : const AssetImage(
                                              'assets/profile_bg_placeholder.png')
                                          as ImageProvider),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.28),
                                  BlendMode.darken),
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),

                        // Edit background button
                        Positioned(
                          top: 50,
                          right: 22,
                          child: Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _pickBackgroundImage,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Profile avatar card overlapping
                        Positioned(
                          bottom: -48,
                          left: 24,
                          right: 24,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 44,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                              as ImageProvider
                                          : NetworkImage(
                                              userProfile.profileImage),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickProfileImage,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.12),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userProfile.nama,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userProfile.email,
                                        style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .report_gmailerrorred_outlined,
                                                  size: 14,
                                                  color: Color(0xFF6366F1),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Lihat Laporan Saya',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 64),

                    // Stats & quick actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard('Total', _totalLaporan, Colors.indigo),
                          _buildStatCard(
                              'Progress', _progressLaporan, Colors.orange),
                          _buildStatCard('Done', _selesaiLaporan, Colors.green),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Editable details card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Akun',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nama',
                              style: GoogleFonts.roboto(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: userProfile.nama,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Email',
                              style: GoogleFonts.roboto(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: userProfile.email,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _updateProfile,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF6366F1),
                                      side: BorderSide(
                                          color: const Color(0xFF6366F1)
                                              .withOpacity(0.15)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text('Simpan',
                                        style: GoogleFonts.poppins()),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color accent) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.assignment_turned_in_outlined,
                  color: accent, size: 18),
            ),
            const SizedBox(height: 8),
            Text('$value',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
