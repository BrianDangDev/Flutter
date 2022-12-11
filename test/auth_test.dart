import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapps/services/auth/auth_exceptions.dart';
import 'package:flutterapps/services/auth/auth_provider.dart';
import 'package:flutterapps/services/auth/auth_user.dart';

void main() {
  group('Mock Authenticator', () {
    final provider = MockAuthProvider();
    test('Should not to be initialized with ', () {
      expect(provider.isInitialized, false);
    });
    test(('Cannot log out if not initialezed '), () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be initialized', () async {
      await provider.initialize();
      expect(
        provider.isInitialized,
        true,
      );
    });
    test('user should be null after this', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be initialize less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider._initialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('Create user login function', () async {
      final badEmailUser = provider.createUSer(
        email: 'cdang@deakin.edu.au',
        password: '123111',
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final user = await provider.createUSer(email: 'brian', password: '123');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test('Log in user verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Log in and log out test', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _initialized = false;
  bool get isInitialized => _initialized;

  @override
  Future<AuthUser> createUSer({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _initialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'cdang@deakin.edu.au') throw UserNotFoundAuthException();
    if (password == '123123') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'cdang@deakin.edu.au');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(isEmailVerified: true, email: 'cdang@deakin.edu.au');
    _user = newUser;
  }
}
