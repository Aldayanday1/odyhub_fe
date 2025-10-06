import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/controllers/pengaduan_controller.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/detail_page/detail_screen.dart';
import 'package:sistem_pengaduan/presentation/views/edit_page/edit_screen.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/home_screen.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/skeleton_loading.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_confirm_dialog.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class MyPengaduanPage extends StatefulWidget {
  const MyPengaduanPage({super.key});

  @override
  _MyPengaduanPageState createState() => _MyPengaduanPageState();
}

class _MyPengaduanPageState extends State<MyPengaduanPage> {
  // --------------------------- DESIGN CONSTANTS ---------------------------
  // static const double kHorizontalPadding = 20.0; // unused
  static const double kVerticalSection = 20.0;
  static const double kBorderRadius = 16.0;
  static const Color kDarkGrey = Color(0xFF2D3748);
  static const Color kMediumGrey = Color(0xFF4A5568);
  static const Color kLightGrey = Color(0xFF6B7280);
  static const Color kBackground = Color(0xFFF8F9FA);

  final PengaduanController _userController = PengaduanController();
  late Future<List<Pengaduan>> _pengaduanFuture;

  @override
  void initState() {
    super.initState();
    _pengaduanFuture = _userController.getMyPengaduan();
  }

  // ------------------- SNACKBAR SESSION BREAK -------------------

  void _showSnackBar(String message) {
    ModernSnackBar.showWarning(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      // floatingActionButton managed by MainNavigationScreen
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        // leading: IconButton(
        //   icon: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: kBackground,
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: const Icon(
        //       Icons.arrow_back_ios_new_rounded,
        //       color: kDarkGrey,
        //       size: 18,
        //     ),
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'Status Laporan Saya',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: kDarkGrey,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Pengaduan>>(
        future: _pengaduanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListView(itemCount: 5);
          } else if (snapshot.hasError) {
            // -------BREAK SESSION-------

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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_rounded,
                      size: 60,
                      color: kLightGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum Ada Laporan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: kDarkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laporan yang Anda buat akan muncul di sini',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: kLightGrey,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 85, left: 20, right: 20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Pengaduan pengaduan = snapshot.data![index];
                return buildPengaduanCard(context, pengaduan);
              },
            );
          }
        },
      ),
    );
  }

  Widget buildPengaduanCard(BuildContext context, Pengaduan pengaduan) {
    return Container(
      margin: const EdgeInsets.only(bottom: kVerticalSection),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailView(
                  pengaduan: pengaduan,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(kBorderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  spreadRadius: 0,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          pengaduan.gambar,
                          width: 90.0,
                          height: 90.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pengaduan.judul,
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: kDarkGrey,
                              height: 1.3,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            pengaduan.deskripsi,
                            style: GoogleFonts.roboto(
                              fontSize: 13.5,
                              color: kLightGrey,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16.0,
                                color: kMediumGrey,
                              ),
                              const SizedBox(width: 6.0),
                              Expanded(
                                child: Text(
                                  pengaduan.alamat,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12.5,
                                    color: kMediumGrey,
                                    letterSpacing: 0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.15),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPengaduan(
                                  pengaduan: pengaduan,
                                ),
                                settings: RouteSettings(arguments: pengaduan),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: kDarkGrey.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: kDarkGrey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Edit Laporan",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: kDarkGrey,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            bool? confirm = await ModernConfirmDialog.show(
                              context: context,
                              title: 'Konfirmasi',
                              content:
                                  'Anda yakin ingin menghapus laporan ini?',
                              confirmText: 'Hapus',
                              cancelText: 'Batal',
                              isDanger: true,
                            );

                            if (confirm == true) {
                              var result = await PengaduanController()
                                  .deletePengaduan(pengaduan.id);

                              if (result['success']) {
                                // Show success message first
                                ModernSnackBar.showSuccess(
                                  context,
                                  result['message'],
                                );
                                // Then navigate after short delay
                                Future.delayed(
                                    const Duration(milliseconds: 800), () {
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeView()),
                                    );
                                  }
                                });
                              } else {
                                ModernSnackBar.showError(
                                  context,
                                  result['message'],
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Hapus",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFFDC2626),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
