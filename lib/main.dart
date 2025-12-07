import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; 

import 'package:depd_mvvm_2025/view/pages/main_wrapper.dart';
import 'package:depd_mvvm_2025/shared/style.dart'; 
import 'package:depd_mvvm_2025/viewmodel/international_viewmodel.dart';
import 'package:depd_mvvm_2025/viewmodel/home_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => InternationalViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter x RajaOngkir API',
        theme: ThemeData(
          // implementasi google fontnya
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
          
          colorScheme: ColorScheme.fromSeed(
            seedColor: Style.blue800, 
            primary: Style.blue800,
          ),

          scaffoldBackgroundColor: Style.grey50,

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Style.blue800),
              foregroundColor: WidgetStateProperty.all<Color>(Style.white),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(16),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Style.blue800),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Style.grey500),
            floatingLabelStyle: TextStyle(color: Style.blue800),
            hintStyle: TextStyle(color: Style.grey500),
            iconColor: Style.grey500,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Style.grey500),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Style.blue800, width: 2),
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainWrapper() 
        },
      ),
    );
  }
}