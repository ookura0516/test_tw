import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/persons_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_person_screen.dart';
import 'screens/person_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PersonsProvider()),
      ],
      child: MaterialApp(
        title: '人間関係の距離感',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
          ),
          sliderTheme: const SliderThemeData(
            showValueIndicator: ShowValueIndicator.always,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                  builder: (_) => const HomeScreen());
            case '/add':
              return MaterialPageRoute(
                  builder: (_) => const AddEditPersonScreen());
            case '/edit':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) => AddEditPersonScreen(personId: id));
            case '/person':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) => PersonDetailScreen(personId: id));
            default:
              return MaterialPageRoute(builder: (_) => const HomeScreen());
          }
        },
      ),
    );
  }
}
