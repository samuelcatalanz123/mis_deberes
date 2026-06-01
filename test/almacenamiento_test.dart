import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mis_deberes/models/deber.dart';
import 'package:mis_deberes/services/almacenamiento.dart';

void main() {
  test('guardar y cargar devuelve los mismos deberes', () async {
    SharedPreferences.setMockInitialValues({});
    final deberes = [
      Deber(id: '1', titulo: 'Ensayo', materia: 'Historia', fechaEntrega: DateTime(2026, 6, 10)),
    ];
    await guardarDeberes(deberes);
    final cargados = await cargarDeberes();
    expect(cargados.length, 1);
    expect(cargados.first.titulo, 'Ensayo');
    expect(cargados.first.materia, 'Historia');
  });

  test('cargar sin nada guardado devuelve lista vacía', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await cargarDeberes(), isEmpty);
  });
}
