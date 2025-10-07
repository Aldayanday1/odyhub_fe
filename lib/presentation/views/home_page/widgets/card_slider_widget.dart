import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/views/detail_page/detail_screen.dart';

class AutoSlideCards extends StatefulWidget {
  final List<Pengaduan> pengaduanList;

  AutoSlideCards({required this.pengaduanList});

  @override
  _AutoSlideCardsState createState() => _AutoSlideCardsState();
}

class _AutoSlideCardsState extends State<AutoSlideCards> {
  late Timer _timer; // Timer untuk mengatur otomatisasi pergeseran halaman
  late PageController _pageController; // Pengendali halaman untuk PageView
  int _currentPage = 0; // Indeks halaman saat ini

  @override
  void initState() {
    super.initState();
    // Start at second card (index 1) if list has at least 2 items
    final initialPage = widget.pengaduanList.length >= 2 ? 1 : 0;
    _currentPage = initialPage;

    // Slightly smaller fraction so adjacent cards sit closer to the center
    _pageController = PageController(
      viewportFraction: 0.78,
      initialPage: initialPage,
    );

    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      // Jika halaman saat ini belum mencapai halaman terakhir, geser ke halaman berikutnya
      if (_currentPage < widget.pengaduanList.length - 1) {
        _currentPage++;
      } else {
        // Jika halaman saat ini adalah halaman terakhir, kembali ke halaman pertama
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.pengaduanList.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      // Dramatic zoom effect - center card larger, side cards smaller
                      value = (1 - (value.abs() * 0.95)).clamp(0.5, 1.0);
                    }

                    // Calculate scale and opacity for modern carousel effect
                    final scale = Curves.easeOutCubic.transform(value);
                    final opacity = 0.3 +
                        (value * 0.7); // More contrast between center and sides

                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: buildCard(widget.pengaduanList[index]),
                );
              },
            ),
          ),
          SizedBox(height: 5),
          buildIndicator(),
        ],
      ),
    );
  }

  Widget buildCard(Pengaduan pengaduan) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailView(pengaduan: pengaduan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          // tighten horizontal margin so neighboring cards are closer (lebih rapat)
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            // Shadow is now handled by AnimatedBuilder for dynamic effect
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with subtle overlay
                Image.network(
                  pengaduan.gambar,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.15),
                  colorBlendMode: BlendMode.darken,
                ),

                // // Gradient overlay for readability
                // Positioned.fill(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         colors: [
                //           Colors.transparent,
                //           Colors.black.withOpacity(0.3),
                //           Colors.black.withOpacity(0.8),
                //         ],
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         stops: const [0.0, 0.5, 1.0],
                //       ),
                //     ),
                //   ),
                // ),

                // Elegant frosted panel with rounded top corners
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      color: Colors.white.withOpacity(0.06),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // small author row
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  pengaduan.namaPembuat,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Title larger and cleaner
                          Text(
                            pengaduan.judul,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Location and date row
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.9)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pengaduan.alamat,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // const SizedBox(width: 8),
                              // Text(
                              //   pengaduan.dateMessage,
                              //   style: GoogleFonts.roboto(
                              //     fontSize: 11,
                              //     color: Colors.white.withOpacity(0.85),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.pengaduanList.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _currentPage == index ? 24.0 : 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            gradient: _currentPage == index
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: _currentPage == index ? null : const Color(0xFFD1D5DB),
            boxShadow: _currentPage == index
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}
