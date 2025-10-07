import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/data/services/pengaduan_service.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/views/detail_page/detail_screen.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_confirm_dialog.dart';

class SearchPage extends StatefulWidget {
  final PengaduanService pengaduanService;

  SearchPage({required this.pengaduanService});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Pengaduan> _searchResult = [];
  List<Pengaduan> _searchHistory = [];

  // keyboard akan muncul secara otomatis saat halaman dimuat
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchFocusNode.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSearchHistory();
  }

//  memuat riwayat pencarian dari penyimpanan lokal (SharedPreferences) saat aplikasi dimulai.
  void _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('search_history');
    if (historyJson != null) {
      setState(() {
        _searchHistory = (jsonDecode(historyJson) as List)
            .map((item) => Pengaduan.fromJson(item))
            .toList();
      });
    }
  }

  void _saveSearchHistory(List<Pengaduan> searchHistory) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final historyJson =
        jsonEncode(searchHistory.map((item) => item.toJson()).toList());
    prefs.setString('search_history', historyJson);
  }

  Future<void> _clearSearchHistory() async {
    bool confirm =
        await _showConfirmationDialog('Ingin menghapus semua riwayat?');
    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
      setState(() {
        _searchHistory.clear();
      });
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    bool? result = await ModernConfirmDialog.show(
      context: context,
      title: 'Konfirmasi',
      content: message,
      confirmText: 'Ya',
      cancelText: 'Tidak',
    );
    return result ?? false; // If null, return false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // translucent appbar so content sits under the gradient
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Pencarian', style: TextStyle(letterSpacing: 0.2)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFf6f8ff),
              Color(0xFFfafbff),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 12,
          ),
          child: Column(
            children: [
              // modern glass-like search bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Icon(Icons.search, color: Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        focusNode: _searchFocusNode,
                        controller: _searchController,
                        onChanged: (query) => _performSearch(query),
                        onSubmitted: (query) => _performSearch(query),
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          hintText: 'Cari laporan, lokasi, atau kata kunci...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                            _searchResult.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () => _performSearch(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // content area
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _searchResult.isNotEmpty
                      ? ListView.separated(
                          key: const ValueKey('results'),
                          itemCount: _searchResult.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final pengaduan = _searchResult[index];
                            return GestureDetector(
                              onTap: () {
                                _addToSearchHistory(pengaduan);
                                _navigateToDetailPage(pengaduan);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      pengaduan.gambar,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 64,
                                        height: 64,
                                        color: Colors.grey[200],
                                        child: Icon(Icons.image_not_supported,
                                            color: Colors.grey[400]),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    pengaduan.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      pengaduan.alamat,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                          color: Colors.grey[600]),
                                    ),
                                  ),
                                  trailing: Icon(Icons.chevron_right,
                                      color: Colors.grey[500]),
                                ),
                              ),
                            );
                          },
                        )
                      : SingleChildScrollView(
                          key: const ValueKey('history'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildSearchHistory(),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return [];
    }
    return [
      SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Riwayat Pencarian',
                style: GoogleFonts.poppins(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 66, 66, 66),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_searchHistory.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: _clearSearchHistory,
              ),
          ],
        ),
      ),
      ..._searchHistory
          .map(
            (pengaduan) => Dismissible(
              key: Key(pengaduan.id.toString()),
              background: Container(
                color: const Color.fromARGB(255, 196, 196, 196),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await _showConfirmationDialog(
                    'Ingin menghapus item ini?');
              },
              onDismissed: (direction) {
                setState(() {
                  _searchHistory.removeWhere((item) => item.id == pengaduan.id);
                  _saveSearchHistory(_searchHistory);
                });
              },
              child: InkWell(
                onTap: () {
                  _navigateToDetailPage(pengaduan);
                },
                child: ListTile(
                  title: Text(
                    pengaduan.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 33, 33, 33),
                    ),
                  ),
                  subtitle: Text(
                    pengaduan.alamat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 117, 117, 117),
                    ),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      pengaduan.gambar,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ];
  }

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      _searchPengaduan(query);
    } else {
      setState(() {
        _searchResult.clear();
      });
    }
  }

  Future<void> _searchPengaduan(String query) async {
    try {
      List<Pengaduan> pengaduanData =
          await widget.pengaduanService.searchPengaduan(query);
      setState(() {
        _searchResult = pengaduanData;
      });
    } catch (e) {
      print('Failed to search pengaduan');
    }
  }

  void _addToSearchHistory(Pengaduan pengaduan) {
    setState(() {
      _searchHistory.removeWhere((item) => item.id == pengaduan.id);
      _searchHistory.insert(0, pengaduan);
      _saveSearchHistory(_searchHistory);
    });
  }

  void _navigateToDetailPage(Pengaduan pengaduan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailView(
                pengaduan: pengaduan,
              )),
    );
  }
}
