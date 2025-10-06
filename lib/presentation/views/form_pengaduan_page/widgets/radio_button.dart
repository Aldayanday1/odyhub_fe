import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/domain/model/pengaduan.dart';

class RadioButton extends StatefulWidget {
  final Kategori? selectedKategori;
  final Function(Kategori?) onKategoriSelected;

  const RadioButton({
    Key? key,
    required this.selectedKategori,
    required this.onKategoriSelected,
  }) : super(key: key);

  @override
  _RadioButtonState createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 8),
        _buildRadioButton(
          title: 'Infrastruktur',
          value: Kategori.INFRASTRUKTUR,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Lingkungan',
          value: Kategori.LINGKUNGAN,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Transportasi',
          value: Kategori.TRANSPORTASI,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Keamanan',
          value: Kategori.KEAMANAN,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Kesehatan',
          value: Kategori.KESEHATAN,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Pendidikan',
          value: Kategori.PENDIDIKAN,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Sosial',
          value: Kategori.SOSIAL,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Izin',
          value: Kategori.IZIN,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Birokrasi',
          value: Kategori.BIROKRASI,
        ),
        SizedBox(height: 20), // Jarak antara RadioListTile
        _buildRadioButton(
          title: 'Lainnya',
          value: Kategori.LAINNYA,
        ),
      ],
    );
  }

  Widget _buildRadioButton({
    required String title,
    required Kategori value,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(50),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            widget.onKategoriSelected(value);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                Radio<Kategori>(
                  value: value,
                  groupValue: widget.selectedKategori,
                  onChanged: (selectedValue) {
                    widget.onKategoriSelected(selectedValue);
                  },
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Color.fromARGB(255, 66, 66, 66),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
