import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

// Package Peta & Kalkulasi Jarak GPS
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ==========================================
// TEMA WARNA KEBUDAYAAN JOGJA (BATIK SOGAN)
// ==========================================
const Color soganBrown = Color(0xFF3E2010);
const Color keratonGold = Color(0xFFC59B27);
const Color warmCream = Color(0xFFFAF6F0);
const Color jogjaTerracotta = Color(0xFFA63A1E);
const Color keratonGreen = Color(0xFF2E6F40);

const LatLng pusatYogyakarta = LatLng(-7.7956, 110.3695);
const double batasRadiusJogjaKm = 15.0;

void main() {
  runApp(const RentTrackApp());
}

// ==========================================
// PAINTER MOTIF BATIK KAWUNG JOGJA
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
    double r = 24.0, step = r;

    for (double x = -r; x < size.width + r * 2; x += step) {
      for (double y = -r; y < size.height + r * 2; y += step) {
        canvas.drawCircle(Offset(x, y), r, paintStroke);
        canvas.drawCircle(Offset(x + r / 2, y + r / 2), 2.5, paintFill);
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
// HELPER LOGIKA GEOFENCING & BIAYA
// ==========================================
class GPSHelper {
  static double hitungJarakDariJogja(double lat, double lng) => const Distance()
      .as(LengthUnit.Kilometer, pusatYogyakarta, LatLng(lat, lng));
  static bool isKeluarAreaJogja(double lat, double lng) =>
      hitungJarakDariJogja(lat, lng) > batasRadiusJogjaKm;
  static String formatRupiah(int nominal) =>
      'Rp ${nominal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
  String id, merk, plat, status;
  double lat, lng;
  int hargaHarian, hargaMingguan, hargaBulanan;
  String? imageBase64, paketSewa, tanggalSewa, jamSewa;
  int? lamaSewa;

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
    this.imageBase64,
    this.paketSewa,
    this.lamaSewa,
    this.tanggalSewa,
    this.jamSewa,
  });

  bool get isOutOfArea => GPSHelper.isKeluarAreaJogja(lat, lng);
  double get distanceKm => GPSHelper.hitungJarakDariJogja(lat, lng);

  DateTime? get waktuSelesai {
    if (status != 'Disewa' ||
        tanggalSewa == null ||
        jamSewa == null ||
        lamaSewa == null ||
        paketSewa == null)
      return null;
    try {
      final parts = tanggalSewa!.split('/');
      final timeParts = jamSewa!.split(':');
      final start = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      if (paketSewa == 'Harian') return start.add(Duration(days: lamaSewa!));
      if (paketSewa == 'Mingguan')
        return start.add(Duration(days: lamaSewa! * 7));
      if (paketSewa == 'Bulanan')
        return DateTime(
          start.year,
          start.month + lamaSewa!,
          start.day,
          start.hour,
          start.minute,
        );
    } catch (_) {}
    return null;
  }

  bool get isTerlambat {
    final selesai = waktuSelesai;
    return selesai != null ? DateTime.now().isAfter(selesai) : false;
  }

  String get tenggatWaktuStr {
    final selesai = waktuSelesai;
    return selesai != null
        ? '${selesai.day.toString().padLeft(2, '0')}/${selesai.month.toString().padLeft(2, '0')}/${selesai.year} - ${selesai.hour.toString().padLeft(2, '0')}:${selesai.minute.toString().padLeft(2, '0')}'
        : '-';
  }

  int get totalHargaSewa {
    if (status == 'Disewa' && paketSewa != null && lamaSewa != null) {
      if (paketSewa == 'Harian') return hargaHarian * lamaSewa!;
      if (paketSewa == 'Mingguan') return hargaMingguan * lamaSewa!;
      if (paketSewa == 'Bulanan') return hargaBulanan * lamaSewa!;
    }
    return hargaHarian > 0 ? hargaHarian : 0;
  }

  int get dendaKeluarArea => isOutOfArea ? (totalHargaSewa * 0.10).round() : 0;
  int get dendaTerlambat => isTerlambat ? (totalHargaSewa * 0.10).round() : 0;
  int get totalDenda => dendaKeluarArea + dendaTerlambat;

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
    'imageBase64': imageBase64,
    'paketSewa': paketSewa,
    'lamaSewa': lamaSewa,
    'tanggalSewa': tanggalSewa,
    'jamSewa': jamSewa,
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
    imageBase64: json['imageBase64'],
    paketSewa: json['paketSewa'],
    lamaSewa: json['lamaSewa'],
    tanggalSewa: json['tanggalSewa'],
    jamSewa: json['jamSewa'],
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
// HEADER ATAS DENGAN FITUR FOTO LOGO
// ==========================================
class JogjaTopHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const JogjaTopHeader({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  State<JogjaTopHeader> createState() => _JogjaTopHeaderState();
}

class _JogjaTopHeaderState extends State<JogjaTopHeader> {
  String? logoBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => logoBase64 = prefs.getString('app_logo'));
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Str = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_logo', base64Str);
      setState(() => logoBase64 = base64Str);
    }
  }

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
                      // --- FITUR KLIK UNTUK MENGGANTI LOGO ---
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: keratonGold.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: keratonGold, width: 1.5),
                            image: logoBase64 != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(logoBase64!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: logoBase64 == null
                              ? const Icon(
                                  Icons.storefront_rounded,
                                  color: keratonGold,
                                  size: 22,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (widget.actions != null) ...widget.actions!,
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
// SCREEN 1: PETA
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
    final int jumlahPelanggar = motorList.where((m) => m.isOutOfArea).length;

    return Scaffold(
      backgroundColor: warmCream,
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
                if (jumlahPelanggar > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: jogjaTerracotta,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: keratonGold, width: 1.5),
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
                              'AWAS! $jumlahPelanggar armada di luar batas aman 15 KM!',
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
}

// ==========================================
// SCREEN 2: DATA MOTOR
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
  final ImagePicker _picker = ImagePicker();

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
              if (motor.totalDenda > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: jogjaTerracotta.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚨 PERINGATAN PELANGGARAN',
                        style: TextStyle(
                          color: jogjaTerracotta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (motor.isOutOfArea)
                        Text(
                          '• Keluar Area DIY (10%): ${GPSHelper.formatRupiah(motor.dendaKeluarArea)}',
                          style: const TextStyle(
                            color: jogjaTerracotta,
                            fontSize: 12,
                          ),
                        ),
                      if (motor.isTerlambat)
                        Text(
                          '• Terlambat Pengembalian (10%): ${GPSHelper.formatRupiah(motor.dendaTerlambat)}',
                          style: const TextStyle(
                            color: jogjaTerracotta,
                            fontSize: 12,
                          ),
                        ),
                      const Divider(color: jogjaTerracotta),
                      Text(
                        'Total Denda: ${GPSHelper.formatRupiah(motor.totalDenda)}',
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
    String? tempImageBase64 = isEdit ? motor.imageBase64 : null;

    // Default Simulasi menyesuaikan dengan kondisi Edit
    bool simulasikanKeluarJogja = isEdit && motor.status == 'Disewa'
        ? motor.isOutOfArea
        : false;

    String selectedPaket = isEdit && motor.paketSewa != null
        ? motor.paketSewa!
        : 'Harian';
    final lamaSewaController = TextEditingController(
      text: isEdit && motor.lamaSewa != null ? motor.lamaSewa.toString() : '1',
    );

    String tanggalSewaStr = isEdit && motor.tanggalSewa != null
        ? motor.tanggalSewa!
        : '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
    String jamSewaStr = isEdit && motor.jamSewa != null
        ? motor.jamSewa!
        : '08:00';

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
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 30,
                        );
                        if (image != null) {
                          final bytes = await image.readAsBytes();
                          setDialogState(
                            () => tempImageBase64 = base64Encode(bytes),
                          );
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: soganBrown,
                          shape: BoxShape.circle,
                          border: Border.all(color: keratonGold, width: 2),
                          image: tempImageBase64 != null
                              ? DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(tempImageBase64!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: tempImageBase64 == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: keratonGold,
                                    size: 24,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Foto',
                                    style: TextStyle(
                                      color: keratonGold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: merkController,
                      decoration: const InputDecoration(
                        labelText: 'Merk Motor',
                      ),
                    ),
                    TextField(
                      controller: platController,
                      decoration: const InputDecoration(
                        labelText: 'Plat Nomor',
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

                    if (selectedStatus == 'Disewa') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Penyewaan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: soganBrown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedPaket,
                                    items: ['Harian', 'Mingguan', 'Bulanan']
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                      () => selectedPaket = val!,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Paket Sewa',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: lamaSewaController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Lama Sewa',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) => Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                                  primary: soganBrown,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                          ),
                                          child: child!,
                                        ),
                                      );
                                      if (date != null)
                                        setDialogState(
                                          () => tanggalSewaStr =
                                              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                                        );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tanggal Mulai',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                tanggalSewaStr,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: soganBrown,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.calendar_today,
                                                color: keratonGold,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null)
                                        setDialogState(
                                          () => jamSewaStr =
                                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                        );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jam Mulai',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                jamSewaStr,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: soganBrown,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.access_time,
                                                color: keratonGold,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // --- SIMULASI KELUAR AREA SEKARANG HANYA ADA DI MENU 'DISEWA' ---
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              activeColor: soganBrown,
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Simulasikan Keluar Area DIY (>15 km)',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: simulasikanKeluarJogja,
                              onChanged: (val) => setDialogState(
                                () => simulasikanKeluarJogja = val!,
                              ),
                            ),
                          ],
                        ),
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

                    int harian =
                        int.tryParse(
                          harianController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          ),
                        ) ??
                        0;
                    int mingguan =
                        int.tryParse(
                          mingguanController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          ),
                        ) ??
                        0;
                    int bulanan =
                        int.tryParse(
                          bulananController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          ),
                        ) ??
                        0;

                    // --- LOGIKA LOKASI: CEGAH TERSEDIA/PERAWATAN KELUAR AREA ---
                    double newLat, newLng;
                    final random = Random();

                    if (selectedStatus != 'Disewa' || !simulasikanKeluarJogja) {
                      // Harus di dalam area Jogja
                      if (isEdit && !motor!.isOutOfArea) {
                        newLat = motor.lat;
                        newLng = motor.lng; // Pertahankan jika sudah di dalam
                      } else {
                        // Reset koordinat ke dalam kota (Tugu)
                        newLat = -7.7956 + (random.nextDouble() - 0.5) * 0.04;
                        newLng = 110.3695 + (random.nextDouble() - 0.5) * 0.04;
                      }
                    } else {
                      // Disewa dan Disimulasikan Keluar Jogja
                      if (isEdit && motor!.isOutOfArea) {
                        newLat = motor.lat;
                        newLng = motor.lng; // Pertahankan jika sudah di luar
                      } else {
                        // Pindah paksa ke luar area
                        newLat = -7.5500 + (random.nextDouble() - 0.5) * 0.05;
                        newLng = 110.7500 + (random.nextDouble() - 0.5) * 0.05;
                      }
                    }
                    // ------------------------------------------------------------

                    if (isEdit) {
                      motor.merk = merkController.text;
                      motor.plat = platController.text;
                      motor.status = selectedStatus;
                      motor.lat = newLat;
                      motor.lng = newLng; // Update Lokasi
                      motor.hargaHarian = harian;
                      motor.hargaMingguan = mingguan;
                      motor.hargaBulanan = bulanan;
                      motor.imageBase64 = tempImageBase64;

                      if (selectedStatus == 'Disewa') {
                        motor.paketSewa = selectedPaket;
                        motor.lamaSewa =
                            int.tryParse(lamaSewaController.text) ?? 1;
                        motor.tanggalSewa = tanggalSewaStr;
                        motor.jamSewa = jamSewaStr;
                      } else {
                        motor.paketSewa = null;
                        motor.lamaSewa = null;
                        motor.tanggalSewa = null;
                        motor.jamSewa = null;
                      }
                    } else {
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
                          imageBase64: tempImageBase64,
                          paketSewa: selectedStatus == 'Disewa'
                              ? selectedPaket
                              : null,
                          lamaSewa: selectedStatus == 'Disewa'
                              ? (int.tryParse(lamaSewaController.text) ?? 1)
                              : null,
                          tanggalSewa: selectedStatus == 'Disewa'
                              ? tanggalSewaStr
                              : null,
                          jamSewa: selectedStatus == 'Disewa'
                              ? jamSewaStr
                              : null,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BatikKawungPainter(
                              color: keratonGold.withOpacity(0.15),
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
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: soganBrown,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: keratonGold,
                                      width: 1.5,
                                    ),
                                    image: motor.imageBase64 != null
                                        ? DecorationImage(
                                            image: MemoryImage(
                                              base64Decode(motor.imageBase64!),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: motor.imageBase64 == null
                                      ? const Icon(
                                          Icons.two_wheeler,
                                          color: keratonGold,
                                          size: 24,
                                        )
                                      : null,
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

                              if (motor.status == 'Disewa' &&
                                  motor.paketSewa != null)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50.withOpacity(
                                      0.9,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.orange.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.history_toggle_off,
                                        color: Colors.orange.shade800,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Disewa: ${motor.lamaSewa} ${motor.paketSewa}\nMulai : ${motor.tanggalSewa} - ${motor.jamSewa}\nBatas : ${motor.tenggatWaktuStr}',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Total Sewa',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            GPSHelper.formatRupiah(
                                              motor.totalHargaSewa,
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade900,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              if (motor.totalDenda > 0)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: jogjaTerracotta,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '🚨 Peringatan Pelanggaran!',
                                              style: TextStyle(
                                                color: jogjaTerracotta,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (motor.isOutOfArea)
                                              Text(
                                                '- Keluar Area DIY (+10%): ${GPSHelper.formatRupiah(motor.dendaKeluarArea)}',
                                                style: const TextStyle(
                                                  color: jogjaTerracotta,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            if (motor.isTerlambat)
                                              Text(
                                                '- Terlambat Mengembalikan (+10%): ${GPSHelper.formatRupiah(motor.dendaTerlambat)}',
                                                style: const TextStyle(
                                                  color: jogjaTerracotta,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Total Denda: ${GPSHelper.formatRupiah(motor.totalDenda)}',
                                              style: const TextStyle(
                                                color: jogjaTerracotta,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
