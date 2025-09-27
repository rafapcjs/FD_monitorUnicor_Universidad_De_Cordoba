import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/core/theme.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/dashboard_screen.dart';
import 'src/providers/auth_provider.dart';
import 'src/data/repositories/auth_repository.dart';
import 'src/data/network_service.dart';
import 'src/services/deep_link_service.dart';
import 'src/presentation/screens/reset_password_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DeepLinkService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authRepository: AuthRepository(
              networkService: NetworkService(),
            ),
          )..initializeAuth(),
        ),
      ],
      child: MaterialApp(
        title: 'IoT Monitorización Ambiental',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: DeepLinkService.navigatorKey,
        home: const AuthWrapper(),
        routes: {
          '/reset-password': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ResetPasswordScreen(token: args['token']);
          },
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.state) {
          case AuthState.loading:
          case AuthState.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthState.authenticated:
            return DashboardScreen(
              accessToken: authProvider.accessToken ?? '',
            );
          case AuthState.unauthenticated:
          case AuthState.error:
            return const LoginScreen();
        }
      },
    );
  }
}
