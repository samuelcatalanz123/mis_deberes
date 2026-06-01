import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/pantalla_principal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es'); // para formatear fechas en español
  runApp(const MisDeberesApp());
}

class MisDeberesApp extends StatelessWidget {
  const MisDeberesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Deberes',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PantallaPrincipal(),
      debugShowCheckedModeBanner: false,
    );
  }
}
