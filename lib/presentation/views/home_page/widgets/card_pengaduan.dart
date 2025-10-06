import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/views/detail_page/detail_screen.dart';

Widget buildPengaduanCard(BuildContext context, Pengaduan pengaduan) {
  // ----------- STATUS COLOR & GRADIENT -----------

  List<Color> statusGradient;
  Color statusColor;
  String statusText = pengaduan.status ?? 'PENDING';

  switch (statusText.toUpperCase()) {
    case 'PROGRESS':
      statusGradient = [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      statusColor = const Color(0xFF3B82F6);
      break;
    case 'DONE':
      statusGradient = [const Color(0xFF10B981), const Color(0xFF059669)];
      statusColor = const Color(0xFF10B981);
      break;
    default:
      statusGradient = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      statusColor = const Color(0xFFF59E0B);
      statusText = 'PENDING';
  }

  return Material(
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
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                        height: 115.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ------------- TITLE -------------

                        Padding(
                          padding: const EdgeInsets.only(right: 35),
                          child: Text(
                            pengaduan.judul,
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              letterSpacing: 0.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ------------- DESCRIPTION -------------

                        Padding(
                          padding: const EdgeInsets.only(right: 35.0),
                          child: Text(
                            pengaduan.deskripsi,
                            style: GoogleFonts.roboto(
                              fontSize: 13.0,
                              color: const Color(0xFF6B7280),
                              height: 1.4,
                              letterSpacing: 0.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ------------- LOCATION -------------

                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: statusColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 35),
                                child: Text(
                                  pengaduan.alamat,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12.5,
                                    color: const Color(0xFF6B7280),
                                    letterSpacing: 0.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //------------- CREATED BY -------------
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  pengaduan.profileImagePembuat,
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dibuat oleh: ${pengaduan.namaPembuat}',
                                style: GoogleFonts.roboto(
                                  fontSize: 11.5,
                                  color: const Color(0xFF9CA3AF),
                                  letterSpacing: 0.1,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: statusGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
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
