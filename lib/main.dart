import 'package:api_buddy/model/enviroment_model.dart';
import 'package:api_buddy/model/request_model.dart';
import 'package:api_buddy/provider/enviroment_provider.dart';
import 'package:api_buddy/provider/request_provider.dart';
import 'package:api_buddy/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  // These are automatically generated when you import request_model.dart
  // and run: flutter pub run build_runner build
  Hive.registerAdapter(RequestModelAdapter());
  Hive.registerAdapter(EnvironmentModelAdapter());
  Hive.registerAdapter(HeaderModelAdapter());
  Hive.registerAdapter(AuthModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => EnvironmentProvider()),
      ],
      child: MaterialApp(
        title: 'API Tester',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}