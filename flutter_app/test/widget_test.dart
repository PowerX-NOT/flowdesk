import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_desk/domain/entities/user_entity.dart';
import 'package:flow_desk/domain/repositories/auth_repository.dart';
import 'package:flow_desk/presentation/providers/app_providers.dart';
import 'package:flow_desk/main.dart';

void main() {
  testWidgets('FlowDesk app builds (unauthenticated smoke test)', (WidgetTester tester) async {
    final fakeAuthRepo = _FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Force router/initial auth checks to behave deterministically.
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
        ],
        child: const FlowDeskApp(),
      ),
    );

    await tester.pumpAndSettle();

    // On unauthenticated start we should end up on the auth/login flow.
    expect(find.text('Welcome back'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<String> login({required String email, required String password}) async =>
      Future.value('fake-access-token');

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<bool> refreshSessionIfNeeded() async => false;
}
