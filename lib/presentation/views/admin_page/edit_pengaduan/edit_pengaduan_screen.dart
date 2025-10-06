// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sistem_pengaduan/data/services/user_service.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/domain/model/status_laporan.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_admin_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/map_page/map_static_detail.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

const double kHorizontalPadding = 25.0;

class EditPengaduanAdmin extends StatefulWidget {
  final Pengaduan pengaduan;

  const EditPengaduanAdmin({
    Key? key,
    required this.pengaduan,
  }) : super(key: key);

  @override
  State<EditPengaduanAdmin> createState() => _EditPengaudanViewState();
}

class _EditPengaudanViewState extends State<EditPengaduanAdmin> {
  late StatusLaporan _statusLaporan;

  final _statusController = TextEditingController();
  final _tanggapanController = TextEditingController();

  final ApiService _service = ApiService();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage; // File untuk menyimpan gambar yang dipilih

  bool showMap =
      false; // State untuk menentukan apakah kartu peta harus ditampilkan

  // ------------ INITIALIZE DATA ---------------

  @override
  void initState() {
    super.initState();
    // Mendeklarasikan _statusLaporan dengan atau tanpa gambar
    _statusLaporan = StatusLaporan(
      id: widget.pengaduan.id,
      statusSebelumnya: widget.pengaduan.status ?? 'Pending',
      statusBaru: widget.pengaduan.status ?? 'Pending',
      tanggapan: widget.pengaduan.tanggapan ?? '',
      changedAt: DateTime.now(),
      gambar: widget.pengaduan.gambarTanggapan ?? '',
    );

    // Menginisialisasi nilai controller
    _statusController.text = _statusLaporan.statusBaru;
    _tanggapanController.text = _statusLaporan.tanggapan;

    print('🔍 Init StatusLaporan - Gambar: ${_statusLaporan.gambar}');
    print(
        '🔍 Init Pengaduan - GambarTanggapan: ${widget.pengaduan.gambarTanggapan}');
  }

  //---------- PICK IMAGE ---------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ModernSnackBar.showError(
        context,
        'Gagal memilih gambar: $e',
      );
    }
  }

  //---------- SHOW IMAGE SOURCE DIALOG ---------

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Pilih Sumber Gambar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _pickImage(ImageSource.camera);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt,
                                  color: Colors.blue, size: 28),
                              const SizedBox(height: 8),
                              Text('Kamera',
                                  style: TextStyle(color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _pickImage(ImageSource.gallery);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_library,
                                  color: Colors.green, size: 28),
                              const SizedBox(height: 8),
                              Text('Galeri',
                                  style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Preview saat ini:',
                        style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child:
                      Text('Batal', style: TextStyle(color: Colors.grey[800])),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //---------- HELPER METHOD FOR INFO ROW ---------

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Color.fromARGB(255, 60, 60, 60),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  //---------- UPDATE STATUS ADUAN ---------

  void _updateStatusLaporan() async {
    try {
      String newStatus = _statusController.text;
      String newResponse = _tanggapanController.text;

      if (_statusLaporan.statusBaru == newStatus &&
          _statusLaporan.tanggapan == newResponse &&
          _selectedImage == null) {
        ModernSnackBar.showWarning(
          context,
          'Tidak ada perubahan untuk disimpan.',
        );
        return;
      }

      _statusLaporan.statusBaru = newStatus;
      _statusLaporan.tanggapan = newResponse;

      print(
          'Mengirim permintaan update status laporan: ${_statusLaporan.toJson()}');

      // Panggil method untuk update status laporan dengan gambar dan dapatkan response
      StatusLaporan updatedStatusLaporan = await _service.updateStatusLaporan(
        _statusLaporan.id,
        _statusLaporan,
        gambar: _selectedImage,
      );

      print('Response dari backend: ${updatedStatusLaporan.toJson()}');
      print('URL Gambar tanggapan: ${updatedStatusLaporan.gambar}');

      // Update state untuk menampilkan perubahan status di UI
      setState(() {
        widget.pengaduan.status = updatedStatusLaporan.statusBaru;
        widget.pengaduan.tanggapan = updatedStatusLaporan.tanggapan;
        // Update gambarTanggapan dari response backend
        widget.pengaduan.gambarTanggapan = updatedStatusLaporan.gambar;
        // Update _statusLaporan dengan data terbaru
        _statusLaporan = updatedStatusLaporan;
        _selectedImage = null; // Reset selected image after successful upload
      });

      // Show success message after state update
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          ModernSnackBar.showSuccess(
            context,
            'Status laporan berhasil diperbarui',
          );
        }
      });
    } catch (e) {
      if (e.toString().contains('Token tidak valid')) {
        // ------- BREAK SESSION EDIT STATUS -------
        // Token tidak valid, arahkan pengguna ke halaman login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AdminLoginPage(),
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

  @override
  Widget build(BuildContext context) {
    // ----------- STATUS COLOR TEXT -----------

    Color statusColor;
    String statusText = widget.pengaduan.status ?? 'Pending';

    switch (statusText.toUpperCase()) {
      case 'PROGRESS':
        statusColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case 'DONE':
        statusColor = Colors.green;
        statusText = 'Done';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                // Modern gradient background
                Container(
                  height: 420,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 250, 250, 252),
                        Color.fromARGB(255, 240, 242, 248),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: kHorizontalPadding,
                      right: kHorizontalPadding,
                      top: 70.0,
                      bottom: 0.0),
                  child: Column(
                    children: [
                      // Modern header with back button
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_new_rounded),
                              iconSize: 18,
                              color: Color.fromARGB(255, 66, 66, 66),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Edit Pengaduan",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.0,
                                  color: Color.fromARGB(255, 40, 40, 40),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                      SizedBox(height: 25),
                      // Modern image card
                      Hero(
                        tag: 'unique_tag_3_${widget.pengaduan.id}',
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  widget.pengaduan.gambar,
                                  fit: BoxFit.cover,
                                ),
                                // Subtle gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.2),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kHorizontalPadding, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern title card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pengaduan.judul,
                          style: GoogleFonts.poppins(
                            fontSize: 22.0,
                            color: Color.fromARGB(255, 40, 40, 40),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Description section
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 240, 242, 248),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Deskripsi",
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 80, 80, 80),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Text(
                          widget.pengaduan.deskripsi,
                          style: GoogleFonts.roboto(
                            fontSize: 14.0,
                            color: Color.fromARGB(255, 80, 80, 80),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Modern info cards
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Category
                        _buildInfoRow(
                          Icons.category_rounded,
                          'Kategori',
                          widget.pengaduan.kategoriString,
                          Color.fromARGB(255, 100, 120, 255),
                        ),
                        Divider(height: 28, color: Colors.grey[200]),
                        // Location
                        _buildInfoRow(
                          Icons.location_on_rounded,
                          'Lokasi',
                          widget.pengaduan.alamat,
                          Color.fromARGB(255, 255, 100, 120),
                        ),
                        Divider(height: 28, color: Colors.grey[200]),
                        // Creator
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 120, 200, 150)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  widget.pengaduan.profileImagePembuat,
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dibuat oleh',
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    widget.pengaduan.namaPembuat,
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 60, 60, 60),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 28, color: Colors.grey[200]),
                        // Date
                        _buildInfoRow(
                          Icons.access_time_rounded,
                          'Waktu',
                          widget.pengaduan.dateMessage,
                          Color.fromARGB(255, 150, 100, 255),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Modern map section
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: kHorizontalPadding, vertical: 15),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showMap = !showMap;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 100, 150, 255)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.map_rounded,
                                    size: 20,
                                    color: Color.fromARGB(255, 100, 150, 255),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Lihat Peta Lokasi',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 60, 60, 60),
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              showMap
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        height: showMap ? 240 : 0,
                        child: showMap
                            ? ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                child: StaticMap(
                                  location: LatLng(
                                    widget.pengaduan.latitude,
                                    widget.pengaduan.longitude,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Modern status card (clean, matching other cards)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kHorizontalPadding, vertical: 16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Pengaduan',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Optional small status pill
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----------- TANGGAPAN ADMIN -----------

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: kHorizontalPadding, vertical: 20),
              child: Column(
                children: [
                  if (widget.pengaduan.tanggapan != null)
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/profile.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                              25), // Adjust the curve radius here
                                          bottomLeft: Radius.circular(
                                              25), // Adjust the curve radius here
                                          bottomRight: Radius.circular(
                                              25), // Adjust the curve radius here
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 9,
                                            offset: Offset(5, 5),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Petugas",
                                              style: GoogleFonts.roboto(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 66, 66, 66),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              widget.pengaduan.tanggapan!,
                                              style: GoogleFonts.roboto(
                                                fontSize: 12.5,
                                                color: Color.fromARGB(
                                                    255, 66, 66, 66),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            // Display uploaded image if exists
                                            if (_statusLaporan
                                                .gambar.isNotEmpty)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 5),
                                                  Text(
                                                    "Foto Tanggapan:",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      _statusLaporan.gambar,
                                                      width: double.infinity,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          width:
                                                              double.infinity,
                                                          height: 150,
                                                          color:
                                                              Colors.grey[300],
                                                          child: Center(
                                                            child: Icon(
                                                              Icons.error,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                          ],
                                        ),
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

                  // ----------- UPDATE FORM -----------

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                    padding: EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Edit Status & Tanggapan",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 40, 40, 40),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        // Status Label
                        Text(
                          'Status Pengaduan',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Modern dropdown container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _statusController.text,
                            items:
                                ['PENDING', 'PROGRESS', 'DONE'].map((status) {
                              Color statusColor;
                              switch (status) {
                                case 'PENDING':
                                  statusColor = Colors.orange;
                                  break;
                                case 'PROGRESS':
                                  statusColor = Colors.blue;
                                  break;
                                case 'DONE':
                                  statusColor = Colors.green;
                                  break;
                                default:
                                  statusColor = Colors.black;
                              }

                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: statusColor.withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      status.substring(0, 1) +
                                          status.substring(1).toLowerCase(),
                                      style: GoogleFonts.roboto(
                                        color: Color.fromARGB(255, 60, 60, 60),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _statusController.text = value!;
                              });
                            },
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[600]),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Tanggapan Label
                        Text(
                          'Tanggapan Admin',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Modern textarea container (styled like the upload image box)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText:
                                  "Masukkan tanggapan untuk pengaduan ini...",
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 13,
                                color: Colors.grey[400],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                            controller: _tanggapanController,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Color.fromARGB(255, 60, 60, 60),
                              fontWeight: FontWeight.normal,
                              height: 1.5,
                            ),
                            maxLines: 6,
                            minLines: 4,
                          ),
                        ),
                        SizedBox(height: 24),

                        // ----------- IMAGE UPLOAD SECTION -----------
                        Text(
                          'Upload Gambar Tanggapan (Opsional)',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Button to pick image
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _showImageSourceDialog,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedImage != null
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.grey[300]!,
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (_selectedImage != null
                                            ? Colors.green
                                            : Colors.grey[400]!)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _selectedImage != null
                                        ? Icons.check_circle_rounded
                                        : Icons.add_photo_alternate_rounded,
                                    color: _selectedImage != null
                                        ? Colors.green
                                        : Colors.grey[600],
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  _selectedImage != null
                                      ? 'Gambar Dipilih'
                                      : 'Pilih Gambar',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: _selectedImage != null
                                        ? Colors.green[700]
                                        : Color.fromARGB(255, 80, 80, 80),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Display selected image preview
                        if (_selectedImage != null) ...[
                          SizedBox(height: 20),
                          Center(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    height: 150,
                                    width: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 30),

                        // ----------- SUBMIT BUTTON -----------
                        Material(
                          elevation: 4,
                          shadowColor: Colors.blueAccent.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _updateStatusLaporan,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 49, 49, 49),
                                    Color.fromARGB(255, 63, 63, 63),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(Icons.save,
                                  //     color: Colors.white, size: 20),
                                  // SizedBox(width: 10),
                                  Text(
                                    'Simpan Perubahan',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
