import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

// Package Peta & Kalkulasi Jarak GPS
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const Color primaryColor = Color(0xFF00897B);

// Pusat Wilayah Yogyakarta (Tugu Jogja)
const LatLng pusatYogyakarta = LatLng(-7.7956, 110.3695);
const double batasRadiusJogjaKm = 15.0; // Radius batas aman dalam KM

void main() {
  runApp(const RentTrackApp());
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
  if (status == 'Tersedia') return Colors.green;
  if (status == 'Disewa') return Colors.orange;
  return Colors.red;
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
      title: 'RentTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Default buka tab Data Motor

  Widget _getSelectedScreen() {
    if (_selectedIndex == 0) return const PetaScreen();
    return const MotorScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Peta Armada'),
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),
            label: 'Data Motor',
          ),
        ],
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
    final int jumlahKeluarArea = motorList.where((m) => m.isOutOfArea).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live GPS Armada',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          color: Colors.blue.withOpacity(0.12),
                          borderColor: Colors.blue.shade700,
                          borderStrokeWidth: 2,
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
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: out ? Colors.red : Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: out
                                          ? Colors.red.shade700
                                          : Colors.grey,
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    motor.plat,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: out ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                Icon(
                                  out
                                      ? Icons.warning_amber_rounded
                                      : Icons.location_on,
                                  color: out
                                      ? Colors.red
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
                if (jumlahKeluarArea > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.red.shade700,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.report_problem,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'PERINGATAN: Ada $jumlahKeluarArea motor terdeteksi keluar dari wilayah Yogyakarta!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
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
          title: Text('${motor.merk} (${motor.plat})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${motor.status}'),
              Text(
                'Jarak dari Tugu Jogja: ${motor.distanceKm.toStringAsFixed(1)} KM',
              ),
            ],
          ),
          actions: [
            TextButton(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Live GPS: ${motor.plat}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                ? Colors.red
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🚨 DANGER: KELUAR AREA DIY',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Biaya Tambahan: ${GPSHelper.formatRupiah(motor.extraFee)}',
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
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

    // Inisialisasi controller untuk mengambil input harga
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
              title: Text(isEdit ? 'Edit Motor' : 'Tambah Motor'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

                    // Kolom Input Harga Sewa
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
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    if (!isEdit) ...[
                      const SizedBox(height: 8),
                      CheckboxListTile(
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
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (merkController.text.isEmpty ||
                        platController.text.isEmpty)
                      return;

                    // Mengambil data angka dari controller
                    int harian = int.tryParse(harianController.text) ?? 0;
                    int mingguan = int.tryParse(mingguanController.text) ?? 0;
                    int bulanan = int.tryParse(bulananController.text) ?? 0;

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
                  child: const Text('Simpan'),
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
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          GPSHelper.formatRupiah(price),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Motor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : motorList.isEmpty
          ? const Center(child: Text('Data motor kosong. Silakan tambah data.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: motorList.length,
              itemBuilder: (context, index) {
                final motor = motorList[index];
                final statusColor = getStatusColor(motor.status);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.motorcycle,
                              color: primaryColor,
                            ),
                          ),
                          title: Text(
                            motor.merk,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${motor.plat} • ${motor.distanceKm.toStringAsFixed(1)} KM dari Jogja',
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
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  motor.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (isAdmin)
                                IconButton(
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 22,
                                  ),
                                  tooltip: 'Lacak GPS',
                                  onPressed: () => _showLocationDialog(motor),
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () => _showFormDialog(motor: motor),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
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
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPriceInfo('Harian', motor.hargaHarian),
                              _buildPriceInfo('Mingguan', motor.hargaMingguan),
                              _buildPriceInfo('Bulanan', motor.hargaBulanan),
                            ],
                          ),
                        ),

                        if (motor.isOutOfArea)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Keluar Area Yogyakarta! Biaya Tambahan: ${GPSHelper.formatRupiah(motor.extraFee)}',
                                    style: const TextStyle(
                                      color: Colors.red,
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
