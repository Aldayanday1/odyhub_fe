import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sistem_pengaduan/config/api_config.dart';
import 'package:sistem_pengaduan/domain/model/status_laporan.dart';
import 'package:sistem_pengaduan/domain/model/user.dart';
import 'package:sistem_pengaduan/domain/model/user_profile.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // ----------------------- REGISTRASI --------------------------

  Future<String> registerUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return 'Registrasi berhasil. Silakan cek email Anda untuk kode OTP.';
    } else {
      throw (' ${response.body}');
    }
  }

  Future<String> verifyOtp(String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      body: {'otp': otp},
    );

    if (response.statusCode == 200) {
      return 'Verifikasi OTP berhasil. Silakan login.';
    } else {
      throw (' ${response.body}');
    }
  }

  // ----------------------- LOGIN USER --------------------------

  Future<String> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      return 'OTP telah dikirimkan ke email Anda. Silakan cek email Anda untuk kode OTP.';
    } else {
      throw (' ${response.body}');
    }
  }

  Future<String> loginWithOtp(String otp) async {
    final url = Uri.parse('$baseUrl/login-with-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String token = responseData['token'];

        // Simpan token JWT ke secure storage
        await secureStorage.write(key: 'jwt_token', value: token);

        // Cetak token ke konsol (console)
        print('Token JWT User: $token');

        // mengembalikan (return) nilai token, sehingga nilai token JWT ini dapat digunakan di tempat lain di aplikasi (misalnya untuk mengakses endpoint yang memerlukan otentikasi).
        return token;
      } else {
        var responseBody = jsonDecode(response.body);
        throw (responseBody['message']);
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  // ----------------------- LOGIN ADMIN --------------------------

  Future<String> loginAdmin(String nama, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'password': password}),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      String token = responseData['token'];

      // Simpan token JWT ke secure storage
      await secureStorage.write(key: 'jwt_token', value: token);

      // Cetak token ke konsol (console)
      print('Token JWT Admin: $token');

      return "Login berhasil";
    } else {
      var responseBody = jsonDecode(response.body);
      throw responseBody['message'];
    }
  }

  // ---------------- LOGOUT & BLACKLIST TOKEN ----------------

  Future<void> logout() async {
    String? token = await secureStorage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Hapus token dari secure storage setelah logout berhasil
      await secureStorage.delete(key: 'jwt_token');
      print('Get JWT from secureStorage (Token has been revoked): $token');
    } else {
      throw Exception('Gagal logout: ${response.body}');
    }
  }

  // ----------------------- GET USER PROFILE -----------------------

  Future<UserProfile?> getUserProfile() async {
    // Mendapatkan token dari secure storage
    String? token = await secureStorage.read(key: 'jwt_token');
    print('Get JWT from secureStorage (get user profile): $token');
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    // Melakukan GET request untuk mengambil profil pengguna
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // Memeriksa respons dari server
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data);
    } else if (response.statusCode == 401) {
      // Token tidak valid atau tidak ada, arahkan pengguna kembali ke halaman login
      await secureStorage.delete(key: 'jwt_token'); // Hapus token dari storage
      print('Token has been Revoked (expired): $secureStorage');
      throw Exception('Token tidak valid. Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat profil pengguna: ${response.body}');
    }
  }

  // ----------------------- UPDATE USER PROFILE -----------------------

  Future<String> updateUserProfile(
      String profileImagePath, String backgroundImagePath) async {
    // Mendapatkan token dari secure storage
    String? token = await secureStorage.read(key: 'jwt_token');
    print('Get JWT from secureStorage (update user profile): $token');
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    // Membuat request multipart untuk update profil pengguna
    var request =
        http.MultipartRequest('PUT', Uri.parse('$baseUrl/profile/update'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Menambahkan file gambar profil jika ada perubahan
    if (profileImagePath.isNotEmpty) {
      request.files.add(
          await http.MultipartFile.fromPath('profileImage', profileImagePath));
    }

    // Menambahkan file gambar latar belakang jika ada perubahan
    if (backgroundImagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
          'backgroundImage', backgroundImagePath));
    }

    // Melakukan request dan mengambil respons
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    // Memeriksa respons dari server
    if (response.statusCode == 200) {
      return 'Profil pengguna berhasil diperbarui.';
    } else if (response.statusCode == 400 &&
        responseData.body.contains('Tidak ada perubahan yang dilakukan')) {
      return 'Tidak ada perubahan yang dilakukan.';
    } else if (response.statusCode == 401) {
      // Token tidak valid atau tidak ada, arahkan pengguna kembali ke halaman login
      await secureStorage.delete(key: 'jwt_token'); // Hapus token dari storage
      print('Token has been Revoked (expired): $secureStorage');
      throw Exception('Token tidak valid. Silakan login kembali.');
    } else {
      throw Exception(
          'Gagal memperbarui profil pengguna: ${responseData.body}');
    }
  }

  // ------------------- UPDATE STATUS LAPORAN (ADMIN) -------------------

  Future<StatusLaporan> updateStatusLaporan(
      int pengaduanId, StatusLaporan statusLaporan,
      {File? gambar}) async {
    try {
      // Mengambil token dari secure storage
      final token = await secureStorage.read(key: 'jwt_token');
      print(
          'Get JWT from secureStorage (update status laporan - admin): $token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan di secure storage');
      }

      // Membuat multipart request untuk mendukung upload gambar
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/update-status/$pengaduanId'),
      );

      // Menambahkan header authorization
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Menambahkan field-field status laporan
      request.fields['statusBaru'] = statusLaporan.statusBaru;
      request.fields['tanggapan'] = statusLaporan.tanggapan;

      // Menambahkan gambar jika ada
      if (gambar != null) {
        request.files.add(
          await http.MultipartFile.fromPath('gambar', gambar.path),
        );
      }

      // Mengirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Status laporan berhasil diperbarui');
        print('Response body: ${response.body}');

        // Parse response JSON untuk mendapatkan StatusLaporan yang diupdate
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        StatusLaporan updatedStatusLaporan =
            StatusLaporan.fromJson(responseData);

        return updatedStatusLaporan;
      } else if (response.statusCode == 401) {
        // Token tidak valid atau tidak ada, arahkan pengguna kembali ke halaman login
        await secureStorage.delete(
            key: 'jwt_token'); // Hapus token dari storage
        print('Token has been Revoked (expired): $secureStorage');
        throw Exception('Token tidak valid. Silakan login kembali.');
      } else {
        print('Error updating status: ${response.body}');
        throw Exception('Gagal memperbarui status laporan: ${response.body}');
      }
    } catch (e) {
      print('Gagal memperbarui status laporan: $e');
      throw Exception('Gagal memperbarui status laporan: $e');
    }
  }

  // ------------ UPLOAD IMAGE (ADMIN) -----------------

  Future<String> uploadImage(int pengaduanId, File imageFile) async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan di secure storage');
      }

      final uri = Uri.parse('$baseUrl/upload-image/$pengaduanId');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        return responseString;
      } else {
        throw Exception('Gagal mengunggah gambar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  // ----------------------- CHECK STATUS OTP --------------------------

  Future<bool> checkOtpStatus(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check-otp-status?email=$email'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw ('Gagal memeriksa status OTP: ${response.body}');
    }
  }
}
