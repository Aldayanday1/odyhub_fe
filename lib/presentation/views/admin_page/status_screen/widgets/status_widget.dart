import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';
import 'package:sistem_pengaduan/presentation/controllers/pengaduan_controller.dart';
import 'package:sistem_pengaduan/presentation/views/admin_page/status_screen/status_screen.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/skeleton_loading.dart';

class PengaduanStatusCard extends StatelessWidget {
  final String status;

  PengaduanStatusCard({required this.status});

  final PengaduanController _statusController = PengaduanController();

  Future<List<Pengaduan>> _loadPengaduanByStatus() {
    return _statusController.getPengaduanByStatus(status);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return Colors.orange;
      case "PROGRESS":
        return Colors.blue;
      case "DONE":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return "Pending";
      case "PROGRESS":
        return "Progress";
      case "DONE":
        return "Done";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _getStatusColor(status);
    return FutureBuilder<List<Pengaduan>>(
      future: _loadPengaduanByStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonStatusCard();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int itemCount = snapshot.data?.length ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PengaduanStatusPage(status: status),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      // Gradient accent bar
                      Container(
                        width: 8,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.9),
                              color.withOpacity(0.6)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Count and label
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$itemCount',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatStatus(status),
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Chevron
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.withOpacity(0.5),
                                size: 28,
                              ),
                            ],
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
      },
    );
  }
}
