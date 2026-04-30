import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class UserService {
  final _db = Supabase.instance.client;

  Future<List<User>> getUsers() async {
    final data = await _db.from('users').select().order('name');
    return (data as List).map((j) => User.fromJson(j)).toList();
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final result = await _db.from('users').insert(data).select().single();
    return User.fromJson(result);
  }
}
