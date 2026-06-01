// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final client = Supabase.instance.client;

  // ====================== AUTH ======================
  Future<Map<String, dynamic>?> login(String email, String password) async {
    return await client
        .from('users')
        .select()
        .eq('email', email.trim())
        .eq('password', password.trim())
        .maybeSingle();
  }

  // ====================== PROFILE ======================
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await client
        .from('profiles')
        .select()
        .eq('user_id', int.parse(userId.toString()))
        .maybeSingle();
  }

  // ====================== BILLS ======================
  Future<List<Map<String, dynamic>>> getBills(String userId) async {
    return await client
        .from('bills')
        .select('*, bill_taxes(*)')
        .eq('user_id', int.parse(userId.toString()))
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>?> getCurrentBill(String userId) async {
    return await client
        .from('bills')
        .select('*, bill_taxes(*)')
        .eq('user_id', int.parse(userId.toString()))
        .eq('is_paid', false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ====================== USAGE ======================
  Future<List<Map<String, dynamic>>> getWaterUsage(String userId) async {
    return await client
        .from('water_usage')
        .select()
        .eq('user_id', int.parse(userId.toString()))
        .order('month_number', ascending: false)
        .limit(6);
  }

  // ====================== ALERTS ======================
  Future<List<Map<String, dynamic>>> getLeakAlerts() async {
    return await client
        .from('alerts')
        .select()
        .eq('type', 'leak')
        .eq('is_active', true)
        .order('created_at', ascending: false);
  }

  // ====================== FAULTS ======================
  Future<List<Map<String, dynamic>>> getFaults(String userId) async {
    return await client
        .from('faults')
        .select()
        .eq('user_id', int.parse(userId.toString()))
        .order('created_at', ascending: false);
  }

  // ====================== ANNOUNCEMENTS ======================
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    return await client
        .from('announcements')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
  }
}
