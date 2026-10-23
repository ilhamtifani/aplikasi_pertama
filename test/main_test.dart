import 'package:flutter/material.dart';

void main() {
  runApp(const RentTrackApp());
}

// Penyimpanan sementara selama aplikasi berjalan (belum memakai database).
// Data akan hilang saat aplikasi ditutup; jangan gunakan untuk produksi.
class RentTrackLocalStore {
  static String name = 'Dewi Wahyuni';
  static String email = 'dewi@renttrack.com';
  static String password = 'RentTrack123';
  static final List<Map<String, String>> motorcycles = [];
  static final List<Map<String, String>> customers = [];
  static final List<Map<String, String>> rentals = [];
}

// Status mode gelap dipakai bersama oleh seluruh aplikasi.
final ValueNotifier<bool> rentTrackDarkMode = ValueNotifier<bool>(false);

// Warna global agar helper widget yang tidak menerima BuildContext juga
// dapat mengikuti mode terang/gelap. ValueNotifier membangun ulang MaterialApp.
Color get rentTrackBackgroundColor =>
    rentTrackDarkMode.value ? const Color(0xFF101817) : const Color(0xFFF7F9FA);
Color get rentTrackSurfaceColor =>
    rentTrackDarkMode.value ? const Color(0xFF172321) : Colors.white;
Color get rentTrackCardColor =>
    rentTrackDarkMode.value ? const Color(0xFF172321) : Colors.white;
Color get rentTrackTextColor =>
    rentTrackDarkMode.value ? const Color(0xFFF0F5F4) : const Color(0xFF202B2A);
Color get rentTrackDividerColor =>
    rentTrackDarkMode.value ? const Color(0xFF33423F) : const Color(0xFFE1E8E6);

class RentTrackApp extends StatelessWidget {
  const RentTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: rentTrackDarkMode,
      builder: (context, isDark, _) {
        const seed = Color(0xFF00796B);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RentTrack',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF202B2A),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            cardColor: Colors.white,
            dividerColor: const Color(0xFFE1E8E6),
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
              surface: const Color(0xFF172321),
            ),
            scaffoldBackgroundColor: const Color(0xFF101817),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF172321),
              foregroundColor: Color(0xFFF0F5F4),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            cardColor: const Color(0xFF172321),
            dividerColor: const Color(0xFF33423F),
            listTileTheme: const ListTileThemeData(
              iconColor: Color(0xFF65C9B8),
              textColor: Color(0xFFF0F5F4),
            ),
            fontFamily: 'Roboto',
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

// ==========================================
// HALAMAN LOGIN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan kata sandi wajib diisi.');
      return;
    }
    if (email != RentTrackLocalStore.email.toLowerCase() ||
        password != RentTrackLocalStore.password) {
      _showMessage('Email atau kata sandi salah. Periksa akun demo.');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rentTrackSurfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.route, color: Color(0xFF00796B), size: 40),
              ),
              SizedBox(height: 24),
              Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Masuk ke akun RentTrack Anda. Akun demo: dewi@renttrack.com / RentTrack123',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 40),

              Text(
                'Email atau Username',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email Anda',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00796B),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00796B),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar sekarang',
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN REGISTRASI
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _confirmController.text.isEmpty) {
      _showMessage('Semua kolom wajib diisi.');
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _showMessage('Format email tidak valid.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Kata sandi minimal 8 karakter.');
      return;
    }
    if (password != _confirmController.text) {
      _showMessage('Konfirmasi kata sandi tidak sama.');
      return;
    }
    RentTrackLocalStore.name = name;
    RentTrackLocalStore.email = email;
    RentTrackLocalStore.password = password;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Akun demo berhasil dibuat. Data hanya tersimpan selama aplikasi berjalan.',
        ),
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rentTrackSurfaceColor,
      appBar: AppBar(
        backgroundColor: rentTrackSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: rentTrackTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Daftar untuk mengelola rental motor Anda.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 30),

              Text(
                'Nama Lengkap',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Misal: Dewi Wahyuni',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00796B),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Misal: dewi@contoh.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00796B),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Minimal 8 karakter',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00796B),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text(
                'Konfirmasi Kata Sandi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Ulangi kata sandi Anda',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00796B),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Daftar Akun',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN LUPA KATA SANDI
// ==========================================
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _codeSent = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Masukkan email yang valid.')));
      return;
    }
    if (email.toLowerCase() != RentTrackLocalStore.email.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak ditemukan pada akun demo ini.'),
        ),
      );
      return;
    }
    setState(() => _codeSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mode demo: gunakan kode 123456. Kode ini tidak dikirim melalui email.',
        ),
        backgroundColor: Color(0xFF00796B),
      ),
    );
  }

  void _resetPassword() {
    if (_codeController.text.trim() != '123456') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kode verifikasi tidak sesuai.')));
      return;
    }
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password minimal 8 karakter.')));
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konfirmasi password tidak sama.')),
      );
      return;
    }
    RentTrackLocalStore.password = _passwordController.text;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Berhasil'),
        content: Text('Password berhasil diperbarui. Silakan masuk kembali.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Kembali ke Login'),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rentTrackSurfaceColor,
      appBar: AppBar(
        backgroundColor: rentTrackSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: rentTrackTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lupa Kata Sandi',
          style: TextStyle(
            color: rentTrackTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.lock_reset, color: Color(0xFF00796B), size: 34),
            ),
            SizedBox(height: 20),
            Text(
              'Pulihkan akun Anda',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Masukkan email admin untuk mendapatkan kode verifikasi dan membuat password baru.',
              style: TextStyle(color: Colors.grey[600], height: 1.4),
            ),
            SizedBox(height: 28),
            Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoration(
                'admin@renttrack.com',
                Icons.email_outlined,
              ),
            ),
            SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _codeSent ? 'Kirim Ulang Kode' : 'Kirim Kode Verifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_codeSent) ...[
              SizedBox(height: 26),
              Text(
                'Kode Verifikasi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _decoration(
                  'Masukkan 6 digit kode',
                  Icons.verified_outlined,
                ).copyWith(counterText: ''),
              ),
              SizedBox(height: 12),
              Text(
                'Password Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration:
                    _decoration(
                      'Minimal 8 karakter',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                    ),
              ),
              SizedBox(height: 14),
              Text(
                'Konfirmasi Password Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: !_isConfirmVisible,
                decoration:
                    _decoration(
                      'Ulangi password baru',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isConfirmVisible = !_isConfirmVisible,
                        ),
                      ),
                    ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan Password Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MODEL DATA NOTIFIKASI
// ==========================================
class AppNotification {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  const AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}

// ==========================================
// HALAMAN NOTIFIKASI
// ==========================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Set<int> _readNotifications = {};

  static const List<AppNotification> notifications = [
    AppNotification(
      title: 'Motor keluar area',
      message: 'Yamaha NMAX AB 6820 FZ terdeteksi keluar area geofence.',
      time: '10 menit lalu',
      icon: Icons.location_off,
      color: Colors.orange,
    ),
    AppNotification(
      title: 'Pengembalian hari ini',
      message: 'Honda Vario AB 2341 KY harus dikembalikan pukul 09.00.',
      time: '35 menit lalu',
      icon: Icons.assignment_return,
      color: Colors.blue,
    ),
    AppNotification(
      title: 'Pembayaran diterima',
      message: 'Pembayaran RT-261001 sebesar Rp255.000 sudah lunas.',
      time: '1 jam lalu',
      icon: Icons.payments,
      color: Colors.green,
    ),
    AppNotification(
      title: 'Servis motor',
      message:
          'Yamaha Fazzio AB 8931 JK dijadwalkan servis hari ini pukul 13.00.',
      time: '2 jam lalu',
      icon: Icons.build,
      color: Colors.deepOrange,
    ),
    AppNotification(
      title: 'Penyewaan baru',
      message: 'Penyewaan baru dari Nadia Putri untuk Honda Beat.',
      time: '3 jam lalu',
      icon: Icons.receipt_long,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rentTrackBackgroundColor,
      appBar: AppBar(
        backgroundColor: rentTrackSurfaceColor,
        surfaceTintColor: rentTrackSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: rentTrackTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: rentTrackTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(
                () => _readNotifications.addAll(
                  List<int>.generate(notifications.length, (index) => index),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi ditandai sudah dibaca.'),
                  backgroundColor: Color(0xFF00796B),
                ),
              );
            },
            child: Text(
              'Tandai semua',
              style: TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _readNotifications.add(index)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _readNotifications.contains(index)
                    ? rentTrackCardColor
                    : rentTrackDarkMode.value
                    ? const Color(0xFF203631)
                    : const Color(0xFFEAF7F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: notification.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(notification.icon, color: notification.color),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          notification.time,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
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

// ==========================================
// PROFIL / PENGATURAN ADMIN
// ==========================================
class ProfileSettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileSettingsScreen({super.key, required this.onLogout});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notifications = true;
  bool _gpsWarning = true;
  bool _darkMode = rentTrackDarkMode.value;

  bool get _isDark => _darkMode;
  Color get _background =>
      _isDark ? const Color(0xFF101817) : const Color(0xFFF7F9FA);
  Color get _card => _isDark ? const Color(0xFF172321) : Colors.white;
  Color get _primaryText =>
      _isDark ? const Color(0xFFF0F5F4) : const Color(0xFF202B2A);
  Color get _secondaryText =>
      _isDark ? const Color(0xFFB0BFBB) : const Color(0xFF737C7A);
  Color get _border =>
      _isDark ? const Color(0xFF33423F) : const Color(0xFFE6EAE9);
  Color get _teal =>
      _isDark ? const Color(0xFF65C9B8) : const Color(0xFF00796B);

  BoxDecoration _panelDecoration() => BoxDecoration(
    color: _card,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: _border),
  );

  void _showEditProfile() {
    final nameController = TextEditingController(
      text: RentTrackLocalStore.name,
    );
    final emailController = TextEditingController(
      text: RentTrackLocalStore.email,
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profil', style: TextStyle(color: _primaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: _primaryText),
              decoration: InputDecoration(labelText: 'Nama lengkap'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              style: TextStyle(color: _primaryText),
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              if (name.isEmpty ||
                  !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama dan email yang valid wajib diisi.'),
                  ),
                );
                return;
              }
              RentTrackLocalStore.name = name;
              RentTrackLocalStore.email = email;
              Navigator.pop(dialogContext);
              nameController.dispose();
              emailController.dispose();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berhasil diperbarui.')),
              );
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar dari akun?', style: TextStyle(color: _primaryText)),
        content: Text(
          'Anda akan kembali ke halaman login.',
          style: TextStyle(color: _secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: _teal,
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: _teal, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: _primaryText,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _secondaryText, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _isDark
            ? const Color(0xFF172321)
            : const Color(0xFFEAF3F2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil & Pengaturan',
          style: TextStyle(color: _primaryText, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _panelDecoration(),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: _isDark
                      ? const Color(0xFF24433D)
                      : const Color(0xFFE0F2F1),
                  child: Text(
                    'DW',
                    style: TextStyle(
                      color: _teal,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Dewi Wahyuni',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Administrator RentTrack',
                  style: TextStyle(color: _secondaryText),
                ),
                SizedBox(height: 4),
                Text(
                  'dewi@renttrack.com',
                  style: TextStyle(color: _secondaryText, fontSize: 12),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _showEditProfile,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _border),
                    ),
                    child: Text('Edit Profil', style: TextStyle(color: _teal)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferensi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
                SizedBox(height: 8),
                _switchTile(
                  'Notifikasi',
                  'Terima pemberitahuan aktivitas rental',
                  _notifications,
                  (v) => setState(() => _notifications = v),
                  Icons.notifications_none,
                ),
                _switchTile(
                  'Peringatan GPS',
                  'Beritahu jika motor keluar area',
                  _gpsWarning,
                  (v) => setState(() => _gpsWarning = v),
                  Icons.gps_fixed,
                ),
                _switchTile(
                  'Mode Gelap',
                  'Tampilan gelap aplikasi',
                  _darkMode,
                  (v) {
                    setState(() => _darkMode = v);
                    rentTrackDarkMode.value = v;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v
                              ? 'Mode gelap diaktifkan.'
                              : 'Mode terang diaktifkan.',
                        ),
                      ),
                    );
                  },
                  Icons.dark_mode_outlined,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: _panelDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.security_outlined, color: _teal),
                  title: Text(
                    'Keamanan',
                    style: TextStyle(color: _primaryText),
                  ),
                  subtitle: Text(
                    'Ubah password dan keamanan akun',
                    style: TextStyle(color: _secondaryText),
                  ),
                  trailing: Icon(Icons.chevron_right, color: _secondaryText),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                ),
                Divider(height: 1, color: _border),
                ListTile(
                  leading: Icon(Icons.info_outline, color: _teal),
                  title: Text(
                    'Tentang RentTrack',
                    style: TextStyle(color: _primaryText),
                  ),
                  subtitle: Text(
                    'Versi aplikasi 1.0.0',
                    style: TextStyle(color: _secondaryText),
                  ),
                  trailing: Icon(Icons.chevron_right, color: _secondaryText),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'RentTrack',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Aplikasi manajemen rental motor.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ==========================================
// KONTROL NAVIGASI BAWAH & ATAS (DASHBOARD)
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BerandaScreen(),
    const PetaScreen(),
    const MotorScreen(),
    const SewaScreen(),
    const PelangganScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = rentTrackDarkMode.value;
    final barColor = isDark ? const Color(0xFF172321) : Colors.white;
    final mainTextColor = isDark ? const Color(0xFFF0F5F4) : Colors.black87;
    return Scaffold(
      backgroundColor: rentTrackBackgroundColor,
      appBar: AppBar(
        backgroundColor: barColor,
        surfaceTintColor: barColor,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.route, color: Color(0xFF00796B), size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RentTrack',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainTextColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Yogyakarta Pusat',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFB0BFBB)
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: mainTextColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileSettingsScreen(onLogout: _logout),
                ),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE0F2F1),
              child: Text(
                'DW',
                style: TextStyle(
                  color: Color(0xFF00796B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: barColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: isDark
              ? const Color(0xFF65C9B8)
              : const Color(0xFF00796B),
          unselectedItemColor: isDark ? const Color(0xFF9AA9A5) : Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          elevation: 0,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Peta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.two_wheeler_outlined),
              activeIcon: Icon(Icons.two_wheeler),
              label: 'Motor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Sewa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Pelanggan',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. HALAMAN BERANDA / DASHBOARD
// ==========================================
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Selasa, 6 Oktober 2026',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Text(
            'Selamat pagi, Dewi 👋',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Pantau rental Anda, di mana pun.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3942),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pendapatan · Oktober 2026',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Rp12.850.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '18,4% dari periode sebelumnya',
                      style: TextStyle(color: Color(0xFF4CAF50)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: CustomPaint(painter: SimpleChartPainter()),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '01 Okt',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      '06 Okt',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total armada',
                  '24 motor',
                  '4 tersedia · 2 perawatan',
                  Icons.two_wheeler,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Sewa aktif',
                  '18',
                  '75% armada digunakan',
                  Icons.vpn_key_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE0B2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFE65100),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Motor keluar area',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '09.38',
                      style: TextStyle(color: Colors.orange[900], fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'AB 6820 FZ · Yamaha NMAX 155',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Rizky Maulana berada di Jl. Parangtritis, Bantul, 1,2 km di luar Zona Yogyakarta.',
                  style: TextStyle(color: Colors.grey[800], height: 1.4),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tinjau lokasi',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.orange[900],
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rentTrackCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Icon(icon, color: const Color(0xFF00796B), size: 18),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF00BFA5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    var path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.4,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 1.2,
      size.width * 0.8,
      size.height * 0.2,
    );
    path.quadraticBezierTo(size.width * 0.9, 0, size.width, size.height * 0.6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 2. HALAMAN PETA / GPS TRACKING
// ==========================================
class PetaScreen extends StatefulWidget {
  const PetaScreen({super.key});

  @override
  State<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> {
  bool isGpsTracking = true;
  bool geofencingAktif = true;
  bool sudahDitangani = false;
  String kendaraan = 'AB 6820 FZ · Yamaha NMAX 155';

  static const Color _teal = Color(0xFF087F73);

  static const Color _border = Color(0xFFE1E8EA);
  static const Color _orange = Color(0xFFB87520);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: rentTrackBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GPS Tracking',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: rentTrackTextColor,
              ),
            ),
            SizedBox(height: 5),
            Text(
              isGpsTracking
                  ? '18 motor disewa · pembaruan setiap 30 detik'
                  : 'Telusuri perjalanan dan titik GPS motor',
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
            ),
            SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFF1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _buildTab('GPS Tracking', true),
                  _buildTab('Riwayat Lokasi', false),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (isGpsTracking) _buildGpsTracking() else _buildRiwayatLokasi(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool gpsTab) {
    final bool active = isGpsTracking == gpsTab;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => setState(() => isGpsTracking = gpsTab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? const [BoxShadow(color: Color(0x10000000), blurRadius: 5)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? _teal : Colors.blueGrey.shade500,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGpsTracking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _chip('17 dalam area', const Color(0xFFE3F5EE), _teal),
            _chip('1 keluar area', const Color(0xFFFFF1DF), _orange),
            Text(
              '10.00 WIB',
              style: TextStyle(color: Colors.blueGrey, fontSize: 11),
            ),
          ],
        ),
        SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: _cardDecoration(context),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: kendaraan,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey),
              items: const [
                DropdownMenuItem(
                  value: 'AB 6820 FZ · Yamaha NMAX 155',
                  child: Text(
                    'AB 6820 FZ · Yamaha NMAX 155',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                DropdownMenuItem(
                  value: 'AB 2341 KY · Honda Vario 160',
                  child: Text(
                    'AB 2341 KY · Honda Vario 160',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                DropdownMenuItem(
                  value: 'AB 3157 XY · Honda PCX 160',
                  child: Text(
                    'AB 3157 XY · Honda PCX 160',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => kendaraan = value);
              },
            ),
          ),
        ),
        SizedBox(height: 18),
        _buildPeta(),
        SizedBox(height: 20),
        _buildDetailMotor(),
        SizedBox(height: 20),
        _buildGeofencing(),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _outlineButton(
                context: context,
                icon: Icons.refresh,
                label: 'Perbarui lokasi',
                onPressed: () => _showMessage(
                  'Tampilan diperbarui. Data GPS masih berupa contoh.',
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _outlineButton(
                context: context,
                icon: Icons.check_circle_outline,
                label: sudahDitangani ? 'Sudah ditangani' : 'Tandai ditangani',
                onPressed: () {
                  setState(() => sudahDitangani = !sudahDitangani);
                  _showMessage(
                    sudahDitangani
                        ? 'Peringatan ditandai telah ditangani.'
                        : 'Status penanganan diubah.',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeta() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: SizedBox(
        height: 335,
        width: double.infinity,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _RentTrackMapPainter()),
            ),
            Center(
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF31968A),
                    width: 1.6,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: rentTrackCardColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Zona Yogyakarta · 12 km',
                  style: TextStyle(
                    color: _teal,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(left: 150, top: 170, child: _GpsMarker(color: _teal)),
            Positioned(right: 95, top: 135, child: _GpsMarker(color: _teal)),
            Positioned(left: 95, bottom: 105, child: _GpsMarker(color: _teal)),
            Positioned(
              right: 115,
              bottom: 38,
              child: _GpsMarker(color: _orange),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Material(
                color: rentTrackCardColor,
                borderRadius: BorderRadius.circular(12),
                child: IconButton(
                  onPressed: () =>
                      _showMessage('Lokasi terakhir kendaraan ditampilkan.'),
                  icon: Icon(Icons.my_location, color: _teal),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: rentTrackCardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: _teal, size: 9),
                    SizedBox(width: 5),
                    Text('Dalam area', style: TextStyle(fontSize: 10)),
                    SizedBox(width: 12),
                    Icon(Icons.circle, color: _orange, size: 9),
                    SizedBox(width: 5),
                    Text('Keluar area', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMotor() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AB 6820 FZ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: rentTrackTextColor,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Yamaha NMAX 155 · RT-261002',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _chip('Keluar area', const Color(0xFFFFF1DF), _orange),
            ],
          ),
          Divider(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, color: _teal, size: 25),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jl. Parangtritis, Bantul',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '-7.9098, 110.3680 · akurasi ±5 m',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 23),
          Row(
            children: [
              Expanded(child: _infoColumn('Kecepatan', '28 km/jam')),
              Expanded(child: _infoColumn('GPS terakhir', '09.59 WIB')),
              _chip('Terhubung', const Color(0xFFE3F5EE), _teal),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: _orange, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keluar batas sejak 09.38 WIB',
                        style: TextStyle(
                          color: Color(0xFFAD6818),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '1,2 km di luar area · belum ditangani',
                        style: TextStyle(
                          color: Color(0xFFAD6818),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Rizky Maulana',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            '0813-8821-4506',
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12),
          ),
          SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _showMessage(
                      'Hubungkan fitur telepon untuk menghubungi penyewa.',
                    ),
                    icon: Icon(Icons.phone, size: 17),
                    label: Text(
                      'Hubungi penyewa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => isGpsTracking = false),
                    icon: Icon(Icons.route, color: _teal, size: 17),
                    label: Text(
                      'Riwayat lokasi',
                      style: TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeofencing() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: _teal, size: 25),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Geofencing ${geofencingAktif ? 'aktif' : 'nonaktif'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Zona Yogyakarta · radius 12 km',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _dialogGeofencing,
                child: Text(
                  'Atur',
                  style: TextStyle(color: _teal, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pusat: Kantor RentTrack, Gedongtengen.',
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _dialogGeofencing() {
    bool statusSementara = geofencingAktif;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Pengaturan Geofencing'),
          content: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Geofencing aktif'),
            subtitle: Text('Radius zona 12 km'),
            value: statusSementara,
            activeThumbColor: _teal,
            onChanged: (value) => setDialogState(() => statusSementara = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => geofencingAktif = statusSementara);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatLokasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat perjalanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'AB 6820 FZ · Yamaha NMAX 155',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 7),
              Text(
                '09 Oktober 2026 · 08.00–10.00 WIB',
                style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: const _RentTrackMapPainter(),
              child: Center(child: Icon(Icons.route, color: _teal, size: 45)),
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Urutan titik lokasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        _timelineItem(
          '08.10 WIB',
          'Kantor RentTrack, Gedongtengen',
          'Titik awal perjalanan',
          Icons.flag_outlined,
          false,
        ),
        _timelineItem(
          '08.22 WIB',
          'Jl. Jenderal Sudirman, Yogyakarta',
          'Motor bergerak',
          Icons.navigation,
          false,
        ),
        _timelineItem(
          '08.38 WIB',
          'Jl. Malioboro, Yogyakarta',
          'Titik perjalanan',
          Icons.location_on_outlined,
          false,
        ),
        _timelineItem(
          '09.58 WIB',
          'Jl. Parangtritis, Bantul',
          'Lokasi terakhir',
          Icons.location_on,
          true,
        ),
        SizedBox(height: 12),
        _outlineButton(
          context: context,
          icon: Icons.arrow_back,
          label: 'Kembali ke GPS Tracking',
          onPressed: () => setState(() => isGpsTracking = true),
        ),
      ],
    );
  }

  Widget _timelineItem(
    String waktu,
    String lokasi,
    String keterangan,
    IconData icon,
    bool terakhir,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F5EE),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _teal, size: 18),
              ),
              if (!terakhir)
                Expanded(child: Container(width: 2, color: _border)),
            ],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22, top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    waktu,
                    style: TextStyle(
                      fontSize: 11,
                      color: _teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    lokasi,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    keterangan,
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 11,
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

  Widget _chip(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        '• $label',
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: rentTrackTextColor,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
    color: rentTrackCardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: rentTrackDividerColor),
  );

  Widget _outlineButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 47,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17, color: _teal),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _teal,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: rentTrackSurfaceColor,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: const BorderSide(color: _border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// Penanda motor pada peta
class _GpsMarker extends StatelessWidget {
  final Color color;
  const _GpsMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.navigation, color: Colors.white, size: 17),
    );
  }
}

// Ilustrasi peta lokal tanpa package tambahan
class _RentTrackMapPainter extends CustomPainter {
  const _RentTrackMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFE9EDE4);
    final building = Paint()..color = const Color(0xFFD9E1D5);
    final park = Paint()..color = const Color(0xFFCBE3C7);
    final road = Paint()
      ..color = const Color(0xFFF9F4E7)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    final roadEdge = Paint()
      ..color = const Color(0xFFE4DABF)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final river = Paint()
      ..color = const Color(0xFFB7DFE7)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Offset.zero & size, background);

    final blockWidth = size.width / 5;
    final blockHeight = size.height / 7;
    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 5; col++) {
        final rect = Rect.fromLTWH(
          col * blockWidth + 5,
          row * blockHeight + 5,
          blockWidth - 11,
          blockHeight - 11,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          building,
        );
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .16,
          size.height * .65,
          size.width * .15,
          size.height * .12,
        ),
        const Radius.circular(5),
      ),
      park,
    );

    final riverPath = Path()
      ..moveTo(size.width * .78, -10)
      ..cubicTo(
        size.width * .64,
        size.height * .25,
        size.width * .85,
        size.height * .45,
        size.width * .64,
        size.height * .72,
      )
      ..lineTo(size.width * .75, size.height + 10);
    canvas.drawPath(riverPath, river);

    final roads = <Path>[
      Path()
        ..moveTo(0, size.height * .34)
        ..lineTo(size.width, size.height * .34),
      Path()
        ..moveTo(0, size.height * .72)
        ..lineTo(size.width, size.height * .72),
      Path()
        ..moveTo(size.width * .49, 0)
        ..lineTo(size.width * .49, size.height),
      Path()
        ..moveTo(0, size.height * .52)
        ..lineTo(size.width * .30, size.height * .52),
    ];
    for (final path in roads) {
      canvas.drawPath(path, road);
      canvas.drawPath(path, roadEdge);
    }

    _drawLabel(canvas, 'SLEMAN', Offset(size.width * .39, size.height * .15));
    _drawLabel(
      canvas,
      'YOGYAKARTA',
      Offset(size.width * .32, size.height * .61),
    );
    _drawLabel(canvas, 'BANTUL', Offset(size.width * .60, size.height * .85));
    _drawLabel(
      canvas,
      'Gondokusuman',
      Offset(size.width * .65, size.height * .43),
    );
    _drawLabel(
      canvas,
      'Jl. Ring Road Utara',
      Offset(size.width * .05, size.height * .28),
      small: true,
    );
    _drawLabel(
      canvas,
      'Jl. Parangtritis',
      Offset(size.width * .53, size.height * .76),
      small: true,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String label,
    Offset position, {
    bool small = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: const Color(0xFF829087),
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _RentTrackMapPainter oldDelegate) => false;
}

// ==========================================
// 3. HALAMAN DATA MOTOR
// ==========================================
class MotorScreen extends StatelessWidget {
  const MotorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Motor',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '24 motor · 8 model dalam armada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // MENGARAH KE FORM MOTOR BARU
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormMotorScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('4', 'Tersedia')),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('18', 'Disewa')),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('2', 'Perawatan')),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari motor, plat, atau kode...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.tune, color: Colors.grey),
              filled: true,
              fillColor: rentTrackSurfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua (24)', true),
                _buildFilterChip('Tersedia (4)', false),
                _buildFilterChip('Disewa (18)', false),
                _buildFilterChip('Perawatan (2)', false),
              ],
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Armada rental',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    'Terbaru',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    Icons.arrow_downward,
                    color: Colors.green[700],
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildMotorCard(
            'Honda Vario 160',
            'AB 2341 KY · 2024',
            'MTR-001',
            'Rp85.000',
            'Disewa',
            'Terhubung',
            '20 Okt 2026',
            false,
            false,
          ),
          SizedBox(height: 12),
          _buildMotorCard(
            'Yamaha NMAX 155',
            'AB 6820 FZ · 2024',
            'MTR-002',
            'Rp120.000',
            'Disewa',
            'Keluar area',
            '18 Okt 2026',
            true,
            false,
          ),
          SizedBox(height: 12),
          _buildMotorCard(
            'Honda Beat',
            'AB 3087 MN · 2023',
            'MTR-005',
            'Rp65.000',
            'Tersedia',
            'Terhubung',
            '16 Okt 2026',
            false,
            true,
          ),
          SizedBox(height: 12),
          _buildMotorCard(
            'Yamaha Fazzio',
            'AB 8931 JK · 2025',
            'MTR-007',
            'Rp80.000',
            'Perawatan',
            'Tidak aktif',
            'Hari ini - 13.00',
            false,
            false,
            isMaintenance: true,
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.build, color: Color(0xFFE65100), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perawatan hari ini',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Fazzio · ganti oli & pemeriksaan rem',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      ),
                      Text(
                        'Bengkel Mitra Jogja · 13.00 WIB',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Menampilkan 4 dari 24 motor',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: rentTrackSurfaceColor,
              ),
              child: Text(
                'Muat motor lainnya',
                style: TextStyle(
                  color: Color(0xFF00796B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: rentTrackCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00796B) : rentTrackCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : rentTrackTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMotorCard(
    String name,
    String plate,
    String code,
    String price,
    String status1,
    String status2,
    String serviceDate,
    bool isAlert,
    bool isAvailable, {
    bool isMaintenance = false,
  }) {
    Color s1Text = Colors.blue.shade700;
    Color s1Bg = Colors.blue.shade50;
    if (isAvailable) {
      s1Text = Colors.green.shade700;
      s1Bg = Colors.green.shade50;
    }
    if (isMaintenance) {
      s1Text = Colors.orange.shade700;
      s1Bg = Colors.orange.shade50;
    }

    Color s2Text = Colors.green.shade700;
    Color s2Bg = Colors.green.shade50;
    if (isAlert) {
      s2Text = Colors.orange.shade700;
      s2Bg = Colors.orange.shade50;
    }
    if (isMaintenance) {
      s2Text = Colors.grey.shade700;
      s2Bg = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rentTrackCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.two_wheeler, color: Color(0xFF00796B)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      plate,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip(status1, s1Text, s1Bg),
              SizedBox(width: 8),
              _buildStatusChip(status2, s2Text, s2Bg),
              SizedBox(width: 8),
              Text(code, style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Per 24 jam',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Servis berikutnya',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        serviceDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isMaintenance
                              ? Colors.orange[800]
                              : rentTrackTextColor,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN PENYEWAAN
// ==========================================
class SewaScreen extends StatelessWidget {
  const SewaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penyewaan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola transaksi dan jadwal rental',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // MENGARAH KE FORM PENYEWAAN BARU
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormSewaScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: rentTrackCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '18',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sewa aktif',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: rentTrackCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '4 motor',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kembali hari ini',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.orange[800]),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pembayaran tertunda',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rp1.275.000',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange[900],
                        ),
                      ),
                      Text(
                        '3 transaksi perlu ditindaklanjuti',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.orange[800]),
              ],
            ),
          ),
          SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              hintText: 'Cari transaksi, pelanggan, plat...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.tune, color: Colors.grey),
              filled: true,
              fillColor: rentTrackSurfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: rentTrackCardColor,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '01-31 Oktober 2026',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                Icon(Icons.calendar_today, color: Colors.grey, size: 18),
              ],
            ),
          ),
          SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua (36)', false),
                _buildFilterChip('Aktif (18)', true),
                _buildFilterChip('Terjadwal (2)', false),
                _buildFilterChip('Selesai (16)', false),
              ],
            ),
          ),
          SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Penyewaan aktif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    'Terbaru',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    Icons.arrow_downward,
                    color: Colors.green[700],
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          _buildSewaCard(
            'RT-261001',
            'Andi Pratama',
            'Honda Vario 160 · AB 2341 KY',
            '05 Okt · 09.00 -> 08 Okt · 09.00',
            'Rp255.000',
            'Lunas',
            Colors.green,
          ),
          SizedBox(height: 12),
          _buildSewaCard(
            'RT-261002',
            'Rizky Maulana',
            'Yamaha NMAX 155 · AB 6820 FZ',
            '04 Okt · 10.00 -> 07 Okt · 10.00',
            'Rp360.000',
            'Lunas',
            Colors.green,
          ),
          SizedBox(height: 12),
          _buildSewaCard(
            'RT-261003',
            'Siti Rahmawati',
            'Honda Scoopy · AB 5192 XX',
            '05 Okt · 08.00 -> 06 Okt · 18.00',
            'Rp150.000',
            'DP Rp75.000',
            Colors.orange,
          ),
          SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: rentTrackSurfaceColor,
              ),
              child: Text(
                'Lihat 15 penyewaan lainnya',
                style: TextStyle(
                  color: Color(0xFF00796B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rentTrackCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengambilan berikutnya',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '13.00',
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nadia Putri',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Honda Beat · AB 3087 MN',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Terjadwal',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2 pengambilan hari ini',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          'Lihat kalender',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00796B) : rentTrackCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : rentTrackTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSewaCard(
    String id,
    String name,
    String motor,
    String date,
    String price,
    String status,
    MaterialColor statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rentTrackCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF00796B)),
                    SizedBox(width: 4),
                    Text(
                      'Aktif',
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          Text(motor, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Color(0xFF00796B)),
              SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor.shade700),
                    SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. HALAMAN PELANGGAN
// ==========================================
class PelangganScreen extends StatelessWidget {
  const PelangganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pelanggan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kontak, identitas, dan riwayat sewa',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // MENGARAH KE FORM TAMBAH PELANGGAN
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormPelangganScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _buildSummaryCard('128', 'Pelanggan')),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('18', 'Aktif menyewa')),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('42', 'Kembali')),
            ],
          ),
          SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama, telepon, atau email...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.tune, color: Colors.grey),
              filled: true,
              fillColor: rentTrackSurfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua (128)', true),
                _buildFilterChip('Aktif (18)', false),
                _buildFilterChip('Verifikasi (2)', false),
              ],
            ),
          ),
          SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar pelanggan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    'Nama A-Z',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    Icons.arrow_downward,
                    color: Colors.green[700],
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          _buildExpandedPelangganCard(
            context,
          ), // Me-pass context untuk navigasi
          SizedBox(height: 12),
          _buildCollapsedPelangganCard(
            'Rizky Maulana',
            'RM',
            '0813-8821-4506',
            '4 kali sewa · Rp1.440.000',
            'Aktif menyewa',
            Colors.teal,
          ),
          SizedBox(height: 12),
          _buildCollapsedPelangganCard(
            'Siti Rahmawati',
            'SR',
            '0857-1120-3396',
            '3 kali sewa · Rp450.000',
            'Aktif menyewa',
            Colors.teal,
          ),
          SizedBox(height: 12),
          _buildCollapsedPelangganCard(
            'Nadia Putri',
            'NP',
            '0819-2234-5678',
            '1 kali sewa · Rp130.000',
            'Perlu tinjauan',
            Colors.orange,
          ),
          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: rentTrackSurfaceColor,
              ),
              child: Text(
                'Muat pelanggan lainnya',
                style: TextStyle(
                  color: Color(0xFF00796B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data identitas hanya dapat diakses administrator yang berwenang.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: rentTrackCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00796B) : rentTrackCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : rentTrackTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildExpandedPelangganCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rentTrackCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE0F2F1),
                child: Text(
                  'AP',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Andi Pratama',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'PLG-001 · 5 kali sewa',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.expand_less, color: Color(0xFF00796B)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip(
                'Aktif menyewa',
                Colors.teal.shade700,
                Colors.teal.shade50,
              ),
              SizedBox(width: 8),
              _buildStatusChip(
                'Terverifikasi',
                Colors.green.shade700,
                Colors.green.shade50,
              ),
            ],
          ),
          SizedBox(height: 20),

          _buildContactRow(Icons.phone_outlined, '0812-3456-7890'),
          SizedBox(height: 12),
          _buildContactRow(Icons.email_outlined, 'andi.pratama@gmail.com'),
          SizedBox(height: 12),
          _buildContactRow(
            Icons.location_on_outlined,
            'Jl. Kaliurang Km 5, Sleman, DIY',
          ),
          SizedBox(height: 16),

          Row(
            children: [
              _buildStatusChip(
                'KTP valid',
                Colors.green.shade700,
                Colors.green.shade50,
              ),
              SizedBox(width: 8),
              _buildStatusChip(
                'SIM C valid',
                Colors.green.shade700,
                Colors.green.shade50,
              ),
              SizedBox(width: 12),
              Text(
                'NIK **** 0021',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sewa berjalan - RT-261001',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Honda Vario 160 · AB 2341 KY',
                  style: TextStyle(color: rentTrackTextColor, fontSize: 13),
                ),
                Text(
                  'Kembali 08 Okt · 09.00 WIB',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp255.000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusChip('Lunas', Colors.black87, Colors.white),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.phone_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Hubungi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // MENGARAH KE FORM EDIT PELANGGAN
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormPelangganScreen(
                          isEdit: true,
                          initialName: 'Andi Pratama',
                          initialPhone: '081234567890',
                          initialEmail: 'andi.pratama@gmail.com',
                          initialKtp: '3404012345670001',
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF00796B),
                    size: 18,
                  ),
                  label: Text(
                    'Edit profil',
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedPelangganCard(
    String name,
    String initials,
    String phone,
    String subtitle,
    String status,
    MaterialColor statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rentTrackCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE0F2F1),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              _buildStatusChip(
                status,
                statusColor.shade700,
                statusColor.shade50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[800], fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. FORM TAMBAH / EDIT MOTOR
// ==========================================
class FormMotorScreen extends StatefulWidget {
  const FormMotorScreen({super.key});

  @override
  State<FormMotorScreen> createState() => _FormMotorScreenState();
}

class _FormMotorScreenState extends State<FormMotorScreen> {
  String _statusMotor = 'Tersedia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rentTrackSurfaceColor,
      appBar: AppBar(
        backgroundColor: rentTrackSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: rentTrackTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Motor Baru',
          style: TextStyle(
            color: rentTrackTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel('Merk & Model Motor'),
            _buildTextField('Misal: Honda Vario 160'),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('Plat Nomor'),
                      _buildTextField('Misal: AB 1234 XY'),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('Kode Unit'),
                      _buildTextField('Misal: MTR-008'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            _buildInputLabel('Harga Sewa (Per 24 Jam)'),
            _buildTextField('Misal: 85000', isNumber: true, prefixText: 'Rp '),
            SizedBox(height: 16),

            _buildInputLabel('Status Awal'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusMotor,
                  isExpanded: true,
                  items: ['Tersedia', 'Perawatan', 'Disewa'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _statusMotor = newValue!),
                ),
              ),
            ),
            SizedBox(height: 40),

            _buildSaveButton(context, 'Simpan Data Motor'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. FORM TAMBAH / EDIT PELANGGAN
// ==========================================
class FormPelangganScreen extends StatefulWidget {
  final bool isEdit;
  final String? initialName;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialKtp;

  const FormPelangganScreen({
    super.key,
    this.isEdit = false,
    this.initialName,
    this.initialPhone,
    this.initialEmail,
    this.initialKtp,
  });

  @override
  State<FormPelangganScreen> createState() => _FormPelangganScreenState();
}

class _FormPelangganScreenState extends State<FormPelangganScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _ktpController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _ktpController = TextEditingController(text: widget.initialKtp ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rentTrackSurfaceColor,
      appBar: AppBar(
        backgroundColor: rentTrackSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: rentTrackTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Edit Profil Pelanggan' : 'Tambah Pelanggan Baru',
          style: TextStyle(
            color: rentTrackTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel('Nama Lengkap (Sesuai KTP)'),
            _buildTextFieldController(
              _nameController,
              'Misal: Budi Santoso',
              Icons.person_outline,
            ),
            SizedBox(height: 16),

            _buildInputLabel('Nomor Induk Kependudukan (NIK)'),
            _buildTextFieldController(
              _ktpController,
              '16 Digit NIK KTP',
              Icons.credit_card,
              isNumber: true,
            ),
            SizedBox(height: 16),

            _buildInputLabel('Nomor WhatsApp / HP'),
            _buildTextFieldController(
              _phoneController,
              'Misal: 08123456789',
              Icons.phone_outlined,
              isNumber: true,
            ),
            SizedBox(height: 16),

            _buildInputLabel('Email (Opsional)'),
            _buildTextFieldController(
              _emailController,
              'Misal: budi@gmail.com',
              Icons.email_outlined,
            ),
            SizedBox(height: 16),

            _buildInputLabel('Alamat Lengkap'),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat sesuai KTP/Domisili',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF00796B),
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            _buildSaveButton(
              context,
              widget.isEdit ? 'Simpan Perubahan' : 'Simpan Pelanggan',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 8. FORM BUAT PENYEWAAN BARU
// ==========================================
class FormSewaScreen extends StatefulWidget {
  const FormSewaScreen({super.key});

  @override
  State<FormSewaScreen> createState() => _FormSewaScreenState();
}

class _FormSewaScreenState extends State<FormSewaScreen> {
  String? _selectedPelanggan;
  String? _selectedMotor;
  String _statusPembayaran = 'Lunas';
  DateTime? _tglMulai;
  DateTime? _tglSelesai;

  Future<void> _pilihTanggal(BuildContext context, bool isMulai) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: const Color(0xFF00796B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isMulai)
          _tglMulai = picked;
        else
          _tglSelesai = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih Tanggal';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rentTrackSurfaceColor,
      appBar: AppBar(
        backgroundColor: rentTrackSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: rentTrackTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Penyewaan Baru',
          style: TextStyle(
            color: rentTrackTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel('Pilih Pelanggan'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('Pilih dari daftar pelanggan'),
                  value: _selectedPelanggan,
                  isExpanded: true,
                  items:
                      [
                        'Andi Pratama',
                        'Rizky Maulana',
                        'Siti Rahmawati',
                        'Nadia Putri',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedPelanggan = newValue),
                ),
              ),
            ),
            SizedBox(height: 16),

            _buildInputLabel('Pilih Motor (Hanya Tersedia)'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('Pilih unit motor'),
                  value: _selectedMotor,
                  isExpanded: true,
                  items:
                      [
                        'Honda Beat (AB 3087 MN)',
                        'Yamaha NMAX (AB 1122 CC)',
                        'Honda Vario (AB 3344 DD)',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedMotor = newValue),
                ),
              ),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('Tanggal Mulai'),
                      GestureDetector(
                        onTap: () => _pilihTanggal(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_tglMulai),
                                style: TextStyle(
                                  color: _tglMulai == null
                                      ? Colors.grey
                                      : rentTrackTextColor,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFF00796B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('Tanggal Kembali'),
                      GestureDetector(
                        onTap: () => _pilihTanggal(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_tglSelesai),
                                style: TextStyle(
                                  color: _tglSelesai == null
                                      ? Colors.grey
                                      : rentTrackTextColor,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFF00796B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            _buildInputLabel('Total Harga Keseluruhan'),
            _buildTextField('0', isNumber: true, prefixText: 'Rp '),
            SizedBox(height: 16),

            _buildInputLabel('Status Pembayaran'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusPembayaran,
                  isExpanded: true,
                  items: ['Lunas', 'DP (Uang Muka)', 'Belum Bayar'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _statusPembayaran = newValue!),
                ),
              ),
            ),
            SizedBox(height: 40),

            _buildSaveButton(context, 'Buat Pesanan Sewa'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGET BANTUAN UNTUK FORM (Agar kode tidak berulang)
// ---------------------------------------------------------
Widget _buildInputLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      label,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );
}

Widget _buildTextField(
  String hint, {
  bool isNumber = false,
  String? prefixText,
}) {
  return TextField(
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
      ),
    ),
  );
}

Widget _buildTextFieldController(
  TextEditingController controller,
  String hint,
  IconData icon, {
  bool isNumber = false,
}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
      ),
    ),
  );
}

Widget _buildSaveButton(BuildContext context, String text) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Batal',
            style: TextStyle(
              color: rentTrackTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$text Berhasil!'),
                backgroundColor: const Color(0xFF00796B),
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: const Color(0xFF00796B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ],
  );
}
