import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';

class ProjectService {
  final _db = Supabase.instance.client;

  Future<List<Project>> getProjects() async {
    final data = await _db.from('projects').select().order('created_at');
    return (data as List).map((j) => Project.fromJson(j)).toList();
  }

  Future<Project> createProject(Map<String, dynamic> data) async {
    final result = await _db.from('projects').insert(data).select().single();
    return Project.fromJson(result);
  }

  Future<Project> updateProject(int id, Map<String, dynamic> data) async {
    final result =
        await _db.from('projects').update(data).eq('id', id).select().single();
    return Project.fromJson(result);
  }

  Future<void> deleteProject(int id) async {
    await _db.from('projects').delete().eq('id', id);
  }
}
