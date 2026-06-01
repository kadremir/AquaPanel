# AquaPanel - Su Tüketim Yönetim Paneli

## 📋 Genel Bakış

**AquaPanel**, Flutter ile geliştirilmiş, su abonelerinin tüketim verilerini, faturalarını ve tesisat durumlarını takip edebilecekleri modern bir mobil yönetim panelidir. Kullanıcılar, su tüketimlerini gerçek zamanlı izleyebilir, fatura geçmişine ulaşabilir ve olası sızıntı durumlarından anında haberdar olabilir.

---

## 🎯 Temel Özellikler

### 1. Kimlik Doğrulama (Authentication)
- E-posta/şifre ile güvenli giriş sistemi
- Supabase Authentication entegrasyonu
- Oturum yönetimi

### 2. Ana Sayfa
- Kişiselleştirilmiş karşılama ekranı (kullanıcı adına göre)
- **Güncel Fatura Özeti**: Son fatura tutarı, ödeme durumu, kullanım miktarı ve aylık değişim yüzdesi
- **Sızıntı Alarm Bildirimleri**: Aktif sızıntı alarmlarının konum ve açıklama detaylarıyla gösterimi
- **Arıza Takip Kartı**: Bildirilen arızaların durumu
- **Güvenli Ödeme Kartı**: Hızlı ödeme işlemleri için yönlendirme

### 3. Faturalar Ekranı
- Tüm fatura geçmişinin listelenmesi
- Ödenmiş/bekleyen fatura ayrımı
- Aylık tüketim miktarları (m³)
- Toplam borç ve yıllık toplam hesaplama
- Ödenmemiş faturalar için hızlı ödeme butonu

### 4. Kullanım İstatistikleri
- **Aylık Tüketim Grafiği**: Son 6 ayın karşılaştırmalı gösterimi
- **Detaylı Takip**: Güncel ayın tüketim, borç ve artış bilgileri
- **Oda Bazlı Dağılım**: Kullanımın alanlara göre analizi

### 5. Haberler & Duyurular
- **Kesinti Bildirimleri**: Planlı veya acil su kesintileri
- **Tasarruf İpuçları**: Su tasarrufu önerileri
- **Genel Duyurular**: Kurumsal haberler ve bilgilendirmeler
- Dinamik içerik yönetimi (Supabase announcements tablosu)

### 6. Profil Yönetimi
- Kullanıcı kişisel bilgileri
- Abonelik detayları (abone no, sayaç no, abonelik tarihi)
- Adres ve iletişim bilgileri
- Bildirim ayarları, güvenlik, destek menüleri
- Çıkış yapma fonksiyonu

---

## 🏗️ Teknik Mimari

### Kullanılan Teknolojiler

| Bileşen | Teknoloji |
|---------|-----------|
| **Framework** | Flutter (>=3.10.0) |
| **Dil** | Dart (>=3.0.0) |
| **Backend** | Supabase |
| **State Management** | StatefulWidget (setState) |
| **UI Kit** | Material Design 3 |

### Bağımlılıklar

```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.6
  supabase_flutter: ^2.12.4
  flutter_dotenv: ^5.1.0
```

### Proje Yapısı

```
lib/
├── main.dart                 # Uygulama başlangıç noktası, route tanımları
├── app_colors.dart           # Renk paleti ve tema sabitleri
├── screens/                  # Ekran bileşenleri
│   ├── login_screen.dart     # Giriş ekranı
│   ├── home_screen.dart      # Ana sayfa
│   ├── bills_screen.dart     # Faturalar listesi
│   ├── usage_screen.dart     # Kullanım istatistikleri
│   ├── news_screen.dart      # Duyurular ve haberler
│   └── profile_screen.dart   # Profil yönetimi
├── widgets/                  # Yeniden kullanılabilir UI bileşenleri
│   ├── auth/                 # Kimlik doğrulama widget'ları
│   ├── home/                 # Ana sayfa widget'ları
│   ├── news/                 # Haber widget'ları
│   ├── usage/                # Kullanım widget'ları
│   └── shared/               # Ortak widget'lar
└── services/                 # Servis katmanı
    └── database_service.dart # Supabase bağlantı yönetimi
```

### Veritabanı Tabloları

AquaPanel, Supabase üzerinde aşağıdaki tabloları kullanır:

| Tablo | Açıklama |
|-------|----------|
| `profiles` | Kullanıcı profil bilgileri (full_name, subscriber_no, address, vb.) |
| `bills` | Fatura kayıtları (amount, usage_m³, is_paid, due_date, month_name) |
| `water_usage` | Aylık su tüketim verileri (month_number, usage_m³, debt_amount) |
| `announcements` | Duyurular ve haberler (type: outage/tip/news, is_active) |
| `alerts` | Acil durum alarmları (type: leak, location, is_active) |

---

## 🎨 Tasarım Sistemi

### Renk Paleti

**Ana Renkler (Mavi Tonları)**
- `blueDeep` (#0A2463) - Koyu lacivert, başlıklar ve gradient başlangıç
- `blueMid` (#1565C0) - Orta mavi, vurgu elemanları
- `blueBright` (#1E88E5) - Parlak mavi, gradient bitiş
- `aqua` (#26C6DA) - Turkuaz, aksan rengi

**Arka Planlar**
- `softBg` (#F5F7FA) - Ana arka plan
- `border` (#E8ECF2) - Kenarlık ve ayırıcı çizgiler

**Metin Renkleri**
- `textPrimary` (#1A2340) - Ana metin
- `textMuted` (#8A95A8) - İkincil/açıklama metinleri

**Durum Renkleri**
- `greenSave` (#22C55E) - Başarılı/ödenmiş
- `yellowWarn` (#F59E0B) - Uyarı/bekliyor
- `redAlert` (#EF444E) - Hata/alis/borç

### UI Bileşenleri

- **GradientHeader**: Ekran başlıkları için gradient arka planlı header
- **AppCard**: Gölgeli, yuvarlak köşeli içerik kartları
- **BillHeroCard**: Ana sayfada öne çıkan fatura özeti
- **LeakAlertBanner**: Sızıntı alarmları için uyarı kartı
- **StatusBadge**: Ödeme durumu gösteren badge'ler

---

## 🔧 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Supabase hesabı

### Adımlar

1. **Bağımlılıkları yükle:**
   ```bash
   flutter pub get
   ```

2. **Çevre değişkenlerini yapılandır:**
   `assets/.env` dosyasını oluşturun:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   DATABASE_HOST=db.your-project.supabase.co
   DATABASE_PORT=5432
   DATABASE_NAME=postgres
   DATABASE_USER=postgres
   DATABASE_PASSWORD=your-password
   ```

3. **Uygulamayı çalıştır:**
   ```bash
   flutter run
   ```

---

## 📱 Ekran Görüntüleri (Özellikler)

| Ekran | Özellikler |
|-------|------------|
| **Giriş** | E-posta/şifre formu, şifremi unuttum, kayıt yönlendirmesi |
| **Ana Sayfa** | Kullanıcı karşılama, fatura özeti, sızıntı alarmı, hızlı işlemler |
| **Faturalar** | Fatura listesi, özet kartları (toplam borç, yıllık toplam), ödeme butonu |
| **Kullanım** | 6 aylık grafik, detaylı takip, oda bazlı dağılım |
| **Haberler** | Kesinti bildirimleri, tasarruf ipuçları, duyurular |
| **Profil** | Kişisel bilgiler, abonelik detayları, ayarlar menüsü |

---

## 🔐 Güvenlik

- Supabase Authentication ile güvenli kullanıcı yönetimi
- Environment değişkenleri ile hassas bilgilerin korunması
- Oturum tabanlı erişim kontrolü
- SQL injection koruması (Supabase ORM)

---

## 👨‍💻 Geliştirici

**Proje Adı:** AquaPanel  
**Sürüm:** 1.0.0+1  
**Framework:** Flutter  
**Backend:** Supabase  
**Lisans:** Proprietary  
---

*Bu dokümantasyon 2026-04-24 tarihinde oluşturulmuştur.*
