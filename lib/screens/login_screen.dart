import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/session_service.dart';
import '../services/supabase_service.dart'; // Yeni eklenen servis
import '../widgets/auth/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);

    try {
      // Doğrudan Supabase çağırmak yerine servisi kullanıyoruz
      final user = await SupabaseService().login(email, password);

      if (user == null) {
        throw 'E-posta veya şifre hatalı';
      }

      // SESSION OLUŞTUR
      SessionService.setSession(
        userId: user['id'],
        fullName: user['full_name'] ?? '',
        email: user['email'] ?? '',
      );

      if (!mounted) return;

      // Başarılı giriş mesajı (Mevcut kodunuzdan korundu)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hoş geldiniz, ${user['full_name']}',
          ),
        ),
      );

      Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      if (!mounted) return;

      // Mevcut hata gösterimi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Giriş başarısız: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 24),
                const Text(
                  'AquaPanel',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blueDeep,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Su yönetiminiz artık daha kolay',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 40),
                LoginForm(
                  onLogin: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.aqua,
            AppColors.blueBright,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueMid.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '💧',
          style: TextStyle(fontSize: 50),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kayıt sistemi yakında aktif olacak',
            ),
          ),
        );
      },
      child: RichText(
        text: const TextSpan(
          text: 'Hesabınız yok mu? ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
          children: [
            TextSpan(
              text: 'Kayıt Ol',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.blueBright,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
