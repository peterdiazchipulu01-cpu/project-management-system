import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/task_service.dart';

final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

class TasksNotifier extends FamilyAsyncNotifier<List<Task>, int> {
  @override
  Future<List<Task>> build(int arg) async {
    return ref.read(taskServiceProvider).getTasks(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(taskServiceProvider).getTasks(arg));
  }
}

final tasksProvider =
    AsyncNotifierProvider.family<TasksNotifier, List<Task>, int>(
        TasksNotifier.new);
