import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../services/project_service.dart';

final projectServiceProvider =
    Provider<ProjectService>((ref) => ProjectService());

class ProjectsNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    return ref.read(projectServiceProvider).getProjects();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(projectServiceProvider).getProjects());
  }
}

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<Project>>(
        ProjectsNotifier.new);

final selectedProjectIdProvider = StateProvider<int?>((ref) => null);

final selectedProjectProvider = Provider<Project?>((ref) {
  final id = ref.watch(selectedProjectIdProvider);
  final projects = ref.watch(projectsProvider).value ?? [];
  if (id == null) return null;
  try {
    return projects.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
