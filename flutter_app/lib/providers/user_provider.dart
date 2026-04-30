import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    return ref.read(userServiceProvider).getUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(userServiceProvider).getUsers());
  }
}

final usersProvider =
    AsyncNotifierProvider<UsersNotifier, List<User>>(UsersNotifier.new);

final userByIdProvider = Provider.family<User?, int?>((ref, id) {
  if (id == null) return null;
  final users = ref.watch(usersProvider).value ?? [];
  try {
    return users.firstWhere((u) => u.id == id);
  } catch (_) {
    return null;
  }
});
