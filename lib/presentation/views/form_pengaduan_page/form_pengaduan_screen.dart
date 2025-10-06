import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/controllers/pengaduan_controller.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/main_navigation/main_navigation_screen.dart';
import 'package:sistem_pengaduan/presentation/views/map_page/map_screen.dart';
import 'package:sistem_pengaduan/presentation/views/map_page/map_static_form.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class FormPengaduan extends StatefulWidget {
  const FormPengaduan({Key? key}) : super(key: key);

  @override
  State<FormPengaduan> createState() => _FormPengaduanState();
}

class _FormPengaduanState extends State<FormPengaduan> {
  // --------------------------- DESIGN CONSTANTS ---------------------------
  // static const double kHorizontalPadding = 24.0; // unused
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

  // ----------- VALIDATE TEXT -------------

  String? _validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kolom ini tidak boleh kosong';
    }
    return null;
  }

  // ----------- NAV TO MAPSCREEN -------------

  String? _alamat;
  LatLng? _selectedLocation;

  void _navigateToMapScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          onLocationSelected: (selectedLocation, selectedAddress) {
            setState(() {
              _selectedLocation = selectedLocation;
              _alamat = selectedAddress;
            });
          },
          currentLocation: _selectedLocation,
          currentAddress: _alamat,
        ),
      ),
    );
  }

  // ----------- ADD PENGADUAN -------------

  final _formKey = GlobalKey<FormState>();

  final int _idPengaduan = 0;
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();
  Kategori? selectedKategori;

  Future<void> _addPengaduan() async {
    List<String> missingData = [];

    if (_judul.text.isEmpty &&
        _deskripsi.text.isEmpty &&
        _alamat == null &&
        selectedKategori == null &&
        _image == null) {
      ModernSnackBar.showWarning(
        context,
        'Tidak ada data yang diisi',
      );
    } else {
      if (_judul.text.isEmpty) {
        missingData.add('Judul');
      }
      if (_deskripsi.text.isEmpty) {
        missingData.add('Deskripsi');
      }
      if (_alamat == null) {
        missingData.add('Alamat');
      }
      if (selectedKategori == null) {
        missingData.add('Kategori');
      }
      if (_image == null) {
        missingData.add('Gambar');
      }

      if (missingData.isNotEmpty) {
        String missingDataMessage = 'Harap isi data ';
        missingDataMessage += missingData.join(', ');
        ModernSnackBar.showWarning(
          context,
          missingDataMessage,
        );
      } else {
        DateTime now = DateTime.now();
        var result = await PengaduanController().addPengaduan(
          Pengaduan(
            id: _idPengaduan,
            judul: _judul.text,
            alamat: _alamat!,
            gambar: _image?.path ?? '',
            deskripsi: _deskripsi.text,
            kategori: selectedKategori!,
            latitude: _selectedLocation?.latitude ?? 0.0,
            longitude: _selectedLocation?.longitude ?? 0.0,
            createdAt: now,
            updatedAt: now,
            namaPembuat: '',
            profileImagePembuat: '',
            status: '',
            tanggapan: '',
          ),
          _image,
        );

        if (result['success']) {
          _judul.clear();
          _deskripsi.clear();
          setState(() {
            _image = null;
            _alamat = null;
            selectedKategori = null;
          });

          // Navigate first, then show SnackBar in the new screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          ).then((_) {
            // Show SnackBar after navigation completes
            Future.delayed(const Duration(milliseconds: 100), () {
              if (context.mounted) {
                ModernSnackBar.showSuccess(
                  context,
                  result['message'],
                );
              }
            });
          });

          // -------BREAK SESSION-------
        } else if (result['message'] ==
            'Token tidak valid. Silakan login kembali.') {
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
          ModernSnackBar.showError(
            context,
            result['message'],
          );
        }
      }
    }
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
            "Buat Laporan Baru",
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
        body: SingleChildScrollView(
            child: Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 108, left: 24, right: 24),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ----------- INFO SECTION -----------
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
                        Icons.info_outline_rounded,
                        color: kAccentPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Lengkapi formulir di bawah untuk membuat laporan pengaduan baru',
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
                    hintText: "Jelaskan detail permasalahan yang dilaporkan",
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
                              value.toString().split('.').last,
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

              // ---------------- MAPS ----------------
              Text(
                "Lokasi Kejadian",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: kDarkGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_alamat != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _navigateToMapScreen,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(kBorderRadius),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(kBorderRadius),
                              ),
                              child: Container(
                                height: 200,
                                child:
                                    StaticMapForm(location: _selectedLocation!),
                              ),
                            ),
                          ),
                        ),
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
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToMapScreen,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        border: Border.all(
                          color: kDarkGrey.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: kDarkGrey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _alamat == null ? "Pilih Lokasi" : "Ubah Lokasi",
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
                          child: Image.file(
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
                Row(
                  children: [
                    // ----------- BUTTON SELECT IMAGE -----------
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

                    // ----------- BUTTON TAKE PHOTO -----------
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

                // ----------- BUTTON SAVE DATA -----------
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addPengaduan,
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
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Kirim Laporan",
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
              ]),
            ]),
          ),
          // floatingActionButton: FloatingButton(),
        )));
  }
}
