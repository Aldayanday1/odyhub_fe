import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:image_picker/image_picker.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/controllers/pengaduan_controller.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/main_navigation/main_navigation_screen.dart';
import 'package:sistem_pengaduan/presentation/views/map_page/map_static_edit.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class EditPengaduan extends StatefulWidget {
  final Pengaduan pengaduan;
  const EditPengaduan({Key? key, required this.pengaduan}) : super(key: key);

  @override
  State<EditPengaduan> createState() => _EditPengaduanState();
}

class _EditPengaduanState extends State<EditPengaduan> {
  // --------------------------- DESIGN CONSTANTS ---------------------------
  static const double kHorizontalPadding = 24.0;
  static const double kVerticalSection = 24.0;
  static const double kBorderRadius = 16.0;
  static const Color kDarkGrey = Color(0xFF2D3748);
  static const Color kMediumGrey = Color(0xFF4A5568);
  static const Color kLightGrey = Color(0xFF6B7280);
  static const Color kBackground = Color(0xFFF8F9FA);
  static const Color kAccentPrimary = Color(0xFF6366F1);
  static const Color kAccentSecondary = Color(0xFF8B5CF6);

  // -------- IMAGE PICKER --------
  File? _image;
  final _imagePicker = ImagePicker();

  // ----------- GET IMAGE -------------

  Future<void> getImage() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

// ----------- GET PHOTO -------------

  Future<void> takePhoto() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // ------------ VALIDATE TEXT ---------------

  String? _validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kolom ini tidak boleh kosong';
    }
    return null;
  }

  // ------------ INITIALIZE DATA ---------------

  final _formKey = GlobalKey<FormState>();

  // terkait dengan id pengaduan dengan settingan default -> 0
  int _idPengaduan = 0;
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();
  Kategori? selectedKategori;
  bool _isDataInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataInitialized) {
      _initializeData();
      _isDataInitialized = true;
    }
  }

  @override
  void didUpdateWidget(EditPengaduan oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeData();
  }

  void _initializeData() {
    var arguments = ModalRoute.of(context)?.settings.arguments;
    Pengaduan? pengaduan;

    if (arguments is Pengaduan) {
      pengaduan = arguments;
    } else {
      pengaduan = widget.pengaduan;
    }

    _idPengaduan = pengaduan.id;
    _judul.text = pengaduan.judul;
    _deskripsi.text = pengaduan.deskripsi;
    selectedKategori = pengaduan.kategori;
    if (_image == null) {
      // Hindari menimpa gambar yang sudah dipilih pengguna
      _image = File(pengaduan.gambar);
    }
    _alamat = pengaduan.alamat;
    _selectedLocation = LatLng(pengaduan.latitude, pengaduan.longitude);
  }

  //--------- CHANGES LOCATION MAPS ---------

  String? _alamat;
  LatLng? _selectedLocation;

  void _onLocationChanged(LatLng location, String address) {
    setState(() {
      _selectedLocation = location;
      _alamat = address;
    });
  }

  //---------- UPDATE PENGADUAN ---------

  Future<void> _updatePengaduan() async {
    print('🔵 DEBUG: Button pressed, _updatePengaduan called');

    // Validasi kategori
    if (selectedKategori == null) {
      print('🔴 DEBUG: selectedKategori is null');
      ModernSnackBar.showError(context, 'Silakan pilih kategori pengaduan.');
      return;
    }
    print('✅ DEBUG: selectedKategori: ${selectedKategori!.displayName}');

    // Validasi lokasi
    if (_alamat == null || _selectedLocation == null) {
      print(
          '🔴 DEBUG: Location invalid - alamat: $_alamat, location: $_selectedLocation');
      ModernSnackBar.showError(
          context, 'Silakan pilih lokasi kejadian di peta.');
      return;
    }
    print('✅ DEBUG: Location valid - alamat: $_alamat');

    // Validasi form (skip jika tidak ada Form widget)
    bool formIsValid = _formKey.currentState?.validate() ?? true;
    print('🔵 DEBUG: Form validation: $formIsValid');

    if (!formIsValid) {
      print('🔴 DEBUG: Form validation failed');
      ModernSnackBar.showError(
          context, 'Mohon lengkapi semua field yang diperlukan.');
      return;
    }

    try {
      // Cek apakah ada perubahan
      bool isImageChanged =
          _image != null && _image!.path != widget.pengaduan.gambar;
      bool isDataChanged = _judul.text != widget.pengaduan.judul ||
          _deskripsi.text != widget.pengaduan.deskripsi ||
          selectedKategori != widget.pengaduan.kategori ||
          _alamat != widget.pengaduan.alamat ||
          _selectedLocation?.latitude != widget.pengaduan.latitude ||
          _selectedLocation?.longitude != widget.pengaduan.longitude;

      print(
          '🔵 DEBUG: isImageChanged: $isImageChanged, isDataChanged: $isDataChanged');

      if (!isImageChanged && !isDataChanged) {
        print('⚠️ DEBUG: No changes detected');
        ModernSnackBar.showWarning(
            context, 'Tidak ada perubahan yang dilakukan.');
        return;
      }

      DateTime now = DateTime.now();

      // IMPORTANT: Don't send empty string for gambar if image not changed!
      // Use original image path instead
      var pengaduan = Pengaduan(
        id: _idPengaduan,
        judul: _judul.text,
        deskripsi: _deskripsi.text,
        alamat: _alamat!,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        gambar: widget.pengaduan.gambar, // Keep original path
        kategori: selectedKategori!,
        createdAt: widget.pengaduan.createdAt,
        updatedAt: now,
        namaPembuat: '',
        profileImagePembuat: '',
        status: '',
        tanggapan: '',
        gambarTanggapan: '',
      );

      print('🔵 DEBUG: Sending update request...');
      print('🔵 DEBUG: Pengaduan ID: ${pengaduan.id}');
      print('🔵 DEBUG: Judul: ${pengaduan.judul}');
      print('🔵 DEBUG: Sending image file: ${isImageChanged ? "YES" : "NO"}');

      var result = await PengaduanController().updatePengaduan(
        pengaduan,
        isImageChanged ? _image : null,
      );

      print('🔵 DEBUG: Response received');
      print('🔵 DEBUG: Success: ${result['success']}');
      print('🔵 DEBUG: Message: ${result['message']}');

      if (result['success']) {
        print('✅ DEBUG: Update successful, navigating to home...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(initialIndex: 0),
            settings: RouteSettings(arguments: result['message']),
          ),
        );
      } else if (result['message'] ==
          'Token tidak valid. Silakan login kembali.') {
        print('🔴 DEBUG: Token invalid, redirecting to login...');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
            settings: RouteSettings(
                arguments: 'Session habis, silakan login kembali'),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        print('🔴 DEBUG: Update failed: ${result['message']}');
        ModernSnackBar.showError(context, result['message']);
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Exception occurred: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      ModernSnackBar.showError(context, 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO / HEADER (refactored) - Full screen
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background image with gentle overlay
                Container(
                  height: 250 + topPadding,
                  padding: EdgeInsets.only(top: topPadding),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28)),
                    color: kAccentPrimary.withOpacity(0.06),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28)),
                    child: _image != null
                        ? (_image!.path.startsWith('http')
                            ? Image.network(
                                _image!.path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 250,
                              )
                            : Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 250,
                              ))
                        : Container(
                            color: kAccentPrimary.withOpacity(0.06),
                          ),
                  ),
                ),

                // Gradient overlay to tone down the image
                Positioned.fill(
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(28)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.18),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Back button (lighter, sits above image)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: kDarkGrey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                // Frosted title card overlapping image and form
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kAccentPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_square,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Laporan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: kDarkGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Perbarui informasi laporan Anda',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  color: kMediumGrey,
                                ),
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
            const SizedBox(height: 38),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kHorizontalPadding,
                vertical: kVerticalSection,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------- INFO BOX -----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kAccentPrimary.withOpacity(0.1),
                          kAccentSecondary.withOpacity(0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(
                        color: kAccentPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            color: kAccentPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Ubah informasi laporan sesuai kebutuhan Anda',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: kMediumGrey,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kVerticalSection),

                  // ----------- TEXTFIELD JUDUL ----------------
                  Text(
                    "Judul Laporan",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: kDarkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Masukkan judul laporan",
                        hintStyle: GoogleFonts.roboto(
                          fontSize: 14,
                          color: kLightGrey,
                        ),
                        prefixIcon: Icon(
                          Icons.title_rounded,
                          color: kMediumGrey,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: _judul,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: kDarkGrey,
                        fontWeight: FontWeight.w400,
                      ),
                      validator: _validateText,
                    ),
                  ),
                  const SizedBox(height: kVerticalSection),

                  // ----------- TEXTFIELD DESKRIPSI ----------------
                  Text(
                    "Deskripsi Laporan",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: kDarkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText:
                            "Jelaskan detail permasalahan yang dilaporkan",
                        hintStyle: GoogleFonts.roboto(
                          fontSize: 14,
                          color: kLightGrey,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Icon(
                            Icons.description_outlined,
                            color: kMediumGrey,
                            size: 20,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: _deskripsi,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: kDarkGrey,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      validator: _validateText,
                      maxLines: 4,
                      minLines: 4,
                    ),
                  ),
                  const SizedBox(height: kVerticalSection),

                  // ----------- CATEGORY DROPDOWN ----------------
                  Text(
                    "Kategori Laporan",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: kDarkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Kategori>(
                        isExpanded: true,
                        hint: Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              color: kMediumGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Pilih kategori laporan",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: kLightGrey,
                              ),
                            ),
                          ],
                        ),
                        value: selectedKategori,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: kMediumGrey,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: kDarkGrey,
                          fontWeight: FontWeight.w400,
                        ),
                        onChanged: (Kategori? newValue) {
                          setState(() {
                            selectedKategori = newValue;
                          });
                        },
                        items: Kategori.values
                            .map<DropdownMenuItem<Kategori>>((Kategori value) {
                          return DropdownMenuItem<Kategori>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  color: kMediumGrey,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  value.displayName,
                                  style: GoogleFonts.roboto(
                                    color: kDarkGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: kVerticalSection),

                  // ----------- MAPS ----------------
                  Text(
                    "Lokasi Kejadian",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: kDarkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(kBorderRadius),
                          ),
                          child: Container(
                            height: 200,
                            child: _selectedLocation != null
                                ? StaticMapEdit(
                                    location: _selectedLocation!,
                                    onLocationChanged: _onLocationChanged,
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                      color: kAccentPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        if (_alamat != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: kAccentPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _alamat!,
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: kDarkGrey,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kVerticalSection),

                  // ----------- GAMBAR ----------------
                  Text(
                    "Foto Pendukung",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: kDarkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_image != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(kBorderRadius),
                            child: _image!.path.startsWith('http')
                                ? Image.network(
                                    _image!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 250,
                                  )
                                : Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 250,
                                  ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _image = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_image == null)
                    Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: kLightGrey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Tidak ada gambar yang dipilih",
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: kLightGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ----------- IMAGE BUTTONS -----------
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: getImage,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: kBackground,
                                borderRadius:
                                    BorderRadius.circular(kBorderRadius),
                                border: Border.all(
                                  color: kDarkGrey.withOpacity(0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: kDarkGrey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Galeri",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: kDarkGrey,
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
                            onTap: takePhoto,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: kBackground,
                                borderRadius:
                                    BorderRadius.circular(kBorderRadius),
                                border: Border.all(
                                  color: kDarkGrey.withOpacity(0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: kDarkGrey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Kamera",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: kDarkGrey,
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
                  const SizedBox(height: kVerticalSection),

                  // ----------- BUTTON UPDATE -----------
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _updatePengaduan,
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kAccentPrimary, kAccentSecondary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(kBorderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: kAccentPrimary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Simpan Perubahan",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
    );
  }
}

class BottomHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height); // Ubah jarak di sini
    path.arcToPoint(
      Offset(size.width, size.height), // Ubah jarak di sini
      radius: Radius.circular(size.width * 2),
      clockwise: true,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
