import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deber.dart';

const _clave = 'deberes';

/// Carga los deberes guardados en el teléfono. Devuelve [] si no hay nada.
Future<List<Deber>> cargarDeberes() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_clave);
  if (raw == null) return [];
  final lista = jsonDecode(raw) as List<dynamic>;
  return lista.map((e) => Deber.fromJson(e as Map<String, dynamic>)).toList();
}

/// Guarda toda la lista de deberes como JSON.
Future<void> guardarDeberes(List<Deber> deberes) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = jsonEncode(deberes.map((d) => d.toJson()).toList());
  await prefs.setString(_clave, raw);
}
