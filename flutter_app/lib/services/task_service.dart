import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskService {
  final _db = Supabase.instance.client;

  Future<List<Task>> getTasks(int projectId) async {
    final data = await _db
        .from('tasks')
        .select()
        .eq('project_id', projectId)
        .order('created_at');
    return (data as List).map((j) => Task.fromJson(j)).toList();
  }

  Future<Task> createTask(Map<String, dynamic> data) async {
    final result = await _db.from('tasks').insert(data).select().single();
    return Task.fromJson(result);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> data) async {
    final result =
        await _db.from('tasks').update(data).eq('id', id).select().single();
    return Task.fromJson(result);
  }

  Future<void> deleteTask(int id) async {
    await _db.from('tasks').delete().eq('id', id);
  }
}
