// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_booking/firebase_options.dart';
import 'package:flutter_booking/services/auth_service.dart';
import 'views/auth/login_page.dart';
import 'views/auth/signup_page.dart';
import 'views/home/home_page.dart';
import 'views/resources/resources_page.dart';
import 'views/resources/resource_detail_page.dart';
import 'views/calendar/booking_page.dart';
import 'views/calendar/my_reservations_page.dart';
import 'views/admin/admin_page.dart';
import 'models/resource_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterBooking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const AuthWrapper());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupPage());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/resources':
            return MaterialPageRoute(builder: (_) => const ResourcesPage());
          case '/resource_detail':
            final resource = settings.arguments as ResourceModel;
            return MaterialPageRoute(
              builder: (_) => ResourceDetailPage(resource: resource),
            );
          case '/booking':
            final resource = settings.arguments as ResourceModel;
            return MaterialPageRoute(
              builder: (_) => BookingPage(resource: resource),
            );
          case '/my_reservations':
            return MaterialPageRoute(builder: (_) => const MyReservationsPage());
          case '/admin':
            return MaterialPageRoute(builder: (_) => const AdminPage());
          default:
            return MaterialPageRoute(builder: (_) => const AuthWrapper());
        }
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const HomePage();
          }
          return const LoginPage();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}