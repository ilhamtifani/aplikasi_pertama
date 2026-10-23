import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

// Package Peta & Kalkulasi Jarak GPS
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ==========================================
// TEMA WARNA KEBUDAYAAN JOGJA (BATIK SOGAN)
// ==========================================
const Color soganBrown = Color(0xFF3E2010); // Cokelat Tua Sogan Keraton
const Color keratonGold = Color(0xFFC59B27); // Emas Ornamen Keraton
const Color warmCream = Color(0xFFFAF6F0); // Krem Kain Mori
const Color jogjaTerracotta = Color(0xFFA63A1E); // Merah Bata / Out of Bounds
const Color keratonGreen = Color(0xFF2E6F40); // Hijau Gedhong Kuning (Tersedia)

const LatLng pusatYogyakarta = LatLng(-7.7956, 110.3695); // Tugu Jogja
const double batasRadiusJogjaKm = 15.0;

void main() {
  runApp(const RentTrackApp());
}

// ==========================================
// PAINTER MOTIF BATIK KAWUNG JOGJA (ASLI)
// ==========================================
class BatikKawungPainter extends CustomPainter {
  final Color color;
  BatikKawungPainter({this.color = const Color(0x1AC59B27)});

  @override
  void paint(Canvas canvas, Size size) {
    final paintStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final paintFill = Paint()
      ..color = color.withOpacity(color.opacity * 0.8)
      ..style = PaintingStyle.fill;

    // Teknik rahasia membatik Kawung:
    // Menggambar lingkaran-lingkaran yang saling tumpang tindih dengan jarak
    // sejari-jari (r). Perpotongannya otomatis akan membentuk kelopak bunga.
    double r = 24.0;
    double step = r;

    for (double x = -r; x < size.width + r * 2; x += step) {
      for (double y = -r; y < size.height + r * 2; y += step) {
        // 1. Gambar lingkaran dasar (saling berpotongan)
        canvas.drawCircle(Offset(x, y), r, paintStroke);

        // 2. Isen-isen (Titik Cecek khas batik) tepat di tengah kelopak
        canvas.drawCircle(Offset(x + r / 2, y + r / 2), 2.5, paintFill);

        // 3. Aksen ketupat/bintang di titik temu antar kelopak
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 6.0, height: 6.0),
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawCircle(Offset(x, y), 1.5, paintFill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// HELPER LOGIKA GEOFENCING & GPS
// ==========================================
class GPSHelper {
  static double hitungJarakDariJogja(double lat, double lng) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, pusatYogyakarta, LatLng(lat, lng));
  }

  static bool isKeluarAreaJogja(double lat, double lng) {
    return hitungJarakDariJogja(lat, lng) > batasRadiusJogjaKm;
  }

  static int hitungBiayaTambahan(double lat, double lng) {
    double jarak = hitungJarakDariJogja(lat, lng);
    if (jarak <= batasRadiusJogjaKm) return 0;
    double kelebihanKm = jarak - batasRadiusJogjaKm;
    return 50000 + (kelebihanKm * 10000).round();
  }

  static String formatRupiah(int nominal) {
    return 'Rp ${nominal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

Color getStatusColor(String status) {
  if (status == 'Tersedia') return keratonGreen;
  if (status == 'Disewa') return Colors.orange.shade800;
  return jogjaTerracotta;
}

// ==========================================
// MODEL DATA MOTOR
// ==========================================
class Motor {
  String id;
  String merk;
  String plat;
  String status;
  double lat;
  double lng;
  int hargaHarian;
  int hargaMingguan;
  int hargaBulanan;

  Motor({
    required this.id,
    required this.merk,
    required this.plat,
    required this.status,
    required this.lat,
    required this.lng,
    this.hargaHarian = 0,
    this.hargaMingguan = 0,
    this.hargaBulanan = 0,
  });

  bool get isOutOfArea => GPSHelper.isKeluarAreaJogja(lat, lng);
  int get extraFee => GPSHelper.hitungBiayaTambahan(lat, lng);
  double get distanceKm => GPSHelper.hitungJarakDariJogja(lat, lng);

  Map<String, dynamic> toJson() => {
    'id': id,
    'merk': merk,
    'plat': plat,
    'status': status,
    'lat': lat,
    'lng': lng,
    'hargaHarian': hargaHarian,
    'hargaMingguan': hargaMingguan,
    'hargaBulanan': hargaBulanan,
  };

  factory Motor.fromJson(Map<String, dynamic> json) => Motor(
    id: json['id'],
    merk: json['merk'],
    plat: json['plat'],
    status: json['status'],
    lat: json['lat'] ?? -7.7956,
    lng: json['lng'] ?? 110.3695,
    hargaHarian: json['hargaHarian'] ?? 0,
    hargaMingguan: json['hargaMingguan'] ?? 0,
    hargaBulanan: json['hargaBulanan'] ?? 0,
  );
}

// ==========================================
// WIDGET UTAMA APP
// ==========================================
class RentTrackApp extends StatelessWidget {
  const RentTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentTrack Jogja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: warmCream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: soganBrown,
          primary: soganBrown,
          secondary: keratonGold,
          surface: warmCream,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ==========================================
// HEADER ATAS MELENGKUNG (APPBAR CUSTOM)
// ==========================================
class JogjaTopHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const JogjaTopHeader({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: soganBrown,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Stack(
          children: [
            // Corak Batik di Header
            Positioned.fill(
              child: CustomPaint(
                painter: BatikKawungPainter(
                  color: keratonGold.withOpacity(0.15),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: keratonGold.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: keratonGold, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.two_wheeler_rounded,
                          color: keratonGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MAIN SCREEN DENGAN BOTTOM NAVIGATION
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  Widget _getSelectedScreen() {
    if (_selectedIndex == 0) return const PetaScreen();
    return const MotorScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      // Navigasi Bawah
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: soganBrown,
          selectedItemColor: keratonGold,
          unselectedItemColor: Colors.amber.shade100.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Peta Armada',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.two_wheeler_outlined),
              activeIcon: Icon(Icons.two_wheeler),
              label: 'Data Motor',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 1: PETA DENGAN BATIK GEOMETRIS
// ==========================================
class PetaScreen extends StatefulWidget {
  const PetaScreen({super.key});

  @override
  State<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> {
  List<Motor> motorList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('data_motor');

    if (dataString != null) {
      final List decoded = jsonDecode(dataString);
      motorList = decoded.map((e) => Motor.fromJson(e)).toList();
    } else {
      motorList = [];
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final int jumlahKeluarArea = motorList.where((m) => m.isOutOfArea).length;

    return Scaffold(
      backgroundColor: warmCream,
      // AppBar Khusus untuk Peta (Dengan Tombol Refresh)
      appBar: JogjaTopHeader(
        title: "Peta Armada",
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: keratonGold,
              size: 28,
            ),
            onPressed: _loadData,
            tooltip: 'Segarkan Peta',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: soganBrown))
          : Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: pusatYogyakarta,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.renttrack.app',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: pusatYogyakarta,
                          radius: batasRadiusJogjaKm * 1000,
                          useRadiusInMeter: true,
                          color: keratonGold.withOpacity(0.15),
                          borderColor: soganBrown,
                          borderStrokeWidth: 2.5,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: motorList.map((motor) {
                        final bool out = motor.isOutOfArea;
                        return Marker(
                          point: LatLng(motor.lat, motor.lng),
                          width: 90,
                          height: 90,
                          child: GestureDetector(
                            onTap: () => _showDetailMotorPopup(motor),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: out ? jogjaTerracotta : soganBrown,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: keratonGold,
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    motor.plat,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  out
                                      ? Icons.warning_amber_rounded
                                      : Icons.location_on,
                                  color: out
                                      ? jogjaTerracotta
                                      : getStatusColor(motor.status),
                                  size: 38,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // NOTIFIKASI WARN OUT OF BOUNDS
                if (jumlahKeluarArea > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: jogjaTerracotta,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: keratonGold, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.gavel_rounded,
                            color: keratonGold,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AWAS! $jumlahKeluarArea armada di luar batas aman 15 KM!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // BOX LEGENDA KHAS JOGJA
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: warmCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: soganBrown.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.workspace_premium,
                              color: keratonGold,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Area Geofence DIY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: soganBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildLegend(soganBrown, 'Batas Aman Tugu (15 KM)'),
                        _buildLegend(keratonGreen, 'Tersedia'),
                        _buildLegend(Colors.orange.shade800, 'Disewa'),
                        _buildLegend(jogjaTerracotta, 'Out of Bounds (Denda)'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showDetailMotorPopup(Motor motor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: warmCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: keratonGold, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.two_wheeler, color: soganBrown),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${motor.merk} (${motor.plat})',
                  style: const TextStyle(
                    color: soganBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${motor.status}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Jarak Tugu Jogja: ${motor.distanceKm.toStringAsFixed(1)} KM',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: soganBrown,
                foregroundColor: keratonGold,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.brightness_1, color: color, size: 10),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 2: DATA MOTOR DENGAN BATIK CARD
// ==========================================
class MotorScreen extends StatefulWidget {
  const MotorScreen({super.key});

  @override
  State<MotorScreen> createState() => _MotorScreenState();
}

class _MotorScreenState extends State<MotorScreen> {
  List<Motor> motorList = [];
  bool isLoading = true;
  final bool isAdmin = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('data_motor');

    if (dataString != null) {
      final List decoded = jsonDecode(dataString);
      motorList = decoded.map((e) => Motor.fromJson(e)).toList();
    }
    setState(() => isLoading = false);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataString = jsonEncode(
      motorList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('data_motor', dataString);
    setState(() {});
  }

  void _showLocationDialog(Motor motor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: warmCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: keratonGold, width: 2),
          ),
          title: Text(
            'Live GPS: ${motor.plat}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: soganBrown,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 220,
                width: double.maxFinite,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: soganBrown, width: 1.5),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(motor.lat, motor.lng),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(motor.lat, motor.lng),
                          width: 60,
                          height: 60,
                          child: Icon(
                            motor.isOutOfArea
                                ? Icons.warning_amber_rounded
                                : Icons.location_on,
                            color: motor.isOutOfArea
                                ? jogjaTerracotta
                                : getStatusColor(motor.status),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (motor.isOutOfArea)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: jogjaTerracotta.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🚨 KELUAR BATAS AMAN DIY',
                        style: TextStyle(
                          color: jogjaTerracotta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Biaya Tambahan: ${GPSHelper.formatRupiah(motor.extraFee)}',
                        style: const TextStyle(
                          color: jogjaTerracotta,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: soganBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFormDialog({Motor? motor}) {
    final isEdit = motor != null;
    final merkController = TextEditingController(
      text: isEdit ? motor.merk : '',
    );
    final platController = TextEditingController(
      text: isEdit ? motor.plat : '',
    );

    final harianController = TextEditingController(
      text: isEdit && motor.hargaHarian > 0 ? motor.hargaHarian.toString() : '',
    );
    final mingguanController = TextEditingController(
      text: isEdit && motor.hargaMingguan > 0
          ? motor.hargaMingguan.toString()
          : '',
    );
    final bulananController = TextEditingController(
      text: isEdit && motor.hargaBulanan > 0
          ? motor.hargaBulanan.toString()
          : '',
    );

    String selectedStatus = isEdit ? motor.status : 'Tersedia';
    bool simulasikanKeluarJogja = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: warmCream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: keratonGold, width: 2),
              ),
              title: Text(
                isEdit ? 'Edit Data Motor' : 'Tambah Motor Baru',
                style: const TextStyle(
                  color: soganBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: merkController,
                      decoration: const InputDecoration(
                        labelText: 'Merk Motor',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: soganBrown),
                        ),
                      ),
                    ),
                    TextField(
                      controller: platController,
                      decoration: const InputDecoration(
                        labelText: 'Plat Nomor',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: soganBrown),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: harianController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Harian (Rp)',
                        prefixText: 'Rp ',
                      ),
                    ),
                    TextField(
                      controller: mingguanController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Mingguan (Rp)',
                        prefixText: 'Rp ',
                      ),
                    ),
                    TextField(
                      controller: bulananController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Bulanan (Rp)',
                        prefixText: 'Rp ',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['Tersedia', 'Disewa', 'Perawatan']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedStatus = val!),
                      decoration: const InputDecoration(
                        labelText: 'Status Armada',
                      ),
                    ),
                    if (!isEdit) ...[
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        activeColor: soganBrown,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Simulasikan Keluar Area DIY (>15 km)',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: simulasikanKeluarJogja,
                        onChanged: (val) =>
                            setDialogState(() => simulasikanKeluarJogja = val!),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: soganBrown,
                    foregroundColor: keratonGold,
                  ),
                  onPressed: () {
                    if (merkController.text.isEmpty ||
                        platController.text.isEmpty)
                      return;

                    String rawHarian = harianController.text.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    String rawMingguan = mingguanController.text.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    String rawBulanan = bulananController.text.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );

                    int harian = int.tryParse(rawHarian) ?? 0;
                    int mingguan = int.tryParse(rawMingguan) ?? 0;
                    int bulanan = int.tryParse(rawBulanan) ?? 0;

                    if (isEdit) {
                      motor.merk = merkController.text;
                      motor.plat = platController.text;
                      motor.status = selectedStatus;
                      motor.hargaHarian = harian;
                      motor.hargaMingguan = mingguan;
                      motor.hargaBulanan = bulanan;
                    } else {
                      final random = Random();
                      double newLat, newLng;
                      if (simulasikanKeluarJogja) {
                        newLat = -7.5500 + (random.nextDouble() - 0.5) * 0.05;
                        newLng = 110.7500 + (random.nextDouble() - 0.5) * 0.05;
                      } else {
                        newLat = -7.7956 + (random.nextDouble() - 0.5) * 0.04;
                        newLng = 110.3695 + (random.nextDouble() - 0.5) * 0.04;
                      }

                      motorList.add(
                        Motor(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          merk: merkController.text,
                          plat: platController.text,
                          status: selectedStatus,
                          lat: newLat,
                          lng: newLng,
                          hargaHarian: harian,
                          hargaMingguan: mingguan,
                          hargaBulanan: bulanan,
                        ),
                      );
                    }
                    _saveData();
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan Data'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPriceInfo(String label, int price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          GPSHelper.formatRupiah(price),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: soganBrown,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmCream,
      // AppBar Khusus untuk Data Motor (Tanpa ikon refresh)
      appBar: const JogjaTopHeader(title: "Inventaris Motor"),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnTambahMotor',
        onPressed: () => _showFormDialog(),
        backgroundColor: soganBrown,
        child: const Icon(Icons.add, color: keratonGold),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: soganBrown))
          : motorList.isEmpty
          ? const Center(
              child: Text(
                'Data motor kosong. Silakan tambah data.',
                style: TextStyle(color: soganBrown),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              itemCount: motorList.length,
              itemBuilder: (context, index) {
                final motor = motorList[index];
                final statusColor = getStatusColor(motor.status);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: keratonGold.withOpacity(0.5),
                      width: 1.2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        // Corak batik tipis di sudut kartu
                        Positioned(
                          top: 0,
                          right: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(14),
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 60,
                              child: CustomPaint(
                                painter: BatikKawungPainter(
                                  color: keratonGold.withOpacity(0.12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: soganBrown,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: keratonGold,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.two_wheeler,
                                    color: keratonGold,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  motor.merk,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: soganBrown,
                                  ),
                                ),
                                subtitle: Text(
                                  '${motor.plat} • ${motor.distanceKm.toStringAsFixed(1)} KM dari Tugu',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: statusColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        motor.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (isAdmin)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.location_on,
                                          color: keratonGreen,
                                          size: 22,
                                        ),
                                        tooltip: 'Lacak GPS Live',
                                        onPressed: () =>
                                            _showLocationDialog(motor),
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _showFormDialog(motor: motor),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: jogjaTerracotta,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        motorList.removeAt(index);
                                        _saveData();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(height: 1, color: Colors.black12),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildPriceInfo(
                                      'Harian',
                                      motor.hargaHarian,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Colors.black12,
                                    ),
                                    _buildPriceInfo(
                                      'Mingguan',
                                      motor.hargaMingguan,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Colors.black12,
                                    ),
                                    _buildPriceInfo(
                                      'Bulanan',
                                      motor.hargaBulanan,
                                    ),
                                  ],
                                ),
                              ),

                              if (motor.isOutOfArea)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: jogjaTerracotta.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: jogjaTerracotta.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: jogjaTerracotta,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Keluar Area DIY! Denda Tambahan: ${GPSHelper.formatRupiah(motor.extraFee)}',
                                          style: const TextStyle(
                                            color: jogjaTerracotta,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
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
              },
            ),
    );
  }
}
