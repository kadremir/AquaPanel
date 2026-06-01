class SessionService {
  // Kullanıcı bilgilerini hafızada tutacak değişkenler
  static dynamic userId;
  static String fullName = '';
  static String email = '';

  // Giriş yapıldığında session'ı başlatan metod
  static void setSession({
    required dynamic userId,
    required String fullName,
    required String email,
  }) {
    SessionService.userId = userId;
    SessionService.fullName = fullName;
    SessionService.email = email;
  }

  // Çıkış yapıldığında session'ı temizleyen metod
  static void clearSession() {
    userId = null;
    fullName = '';
    email = '';
  }

  // Kullanıcının giriş yapıp yapmadığını kontrol eden yardımcı metod
  static bool get isLoggedIn => userId != null;
}
