import 'package:audio_app/app/app_bloc_provider.dart';
import 'package:audio_app/app/dependency_injection.dart';
import 'package:flutter/material.dart';


import 'app/app.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  setupDependencyInjection();
  
  // Request storage permissions at app startup
  await PermissionService.requestAllPermissions();
  
  // Run the app
  runApp(MultiBlocProvider(providers: appProviders, child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Color(0xFF111827),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
