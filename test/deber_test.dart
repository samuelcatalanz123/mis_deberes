import 'package:flutter_test/flutter_test.dart';
import 'package:mis_deberes/models/deber.dart';

void main() {
  test('toJson y fromJson devuelven el mismo deber', () {
    final d = Deber(
      id: '1',
      titulo: 'Ensayo',
      materia: 'Historia',
      fechaEntrega: DateTime(2026, 6, 10),
      hecho: false,
    );
    final copia = Deber.fromJson(d.toJson());
    expect(copia.id, d.id);
    expect(copia.titulo, d.titulo);
    expect(copia.materia, d.materia);
    expect(copia.fechaEntrega, d.fechaEntrega);
    expect(copia.hecho, d.hecho);
  });

  test('urgencia: atrasado, urgente y normal', () {
    final hoy = DateTime(2026, 6, 8);
    Deber con(DateTime f) =>
        Deber(id: 'x', titulo: 't', materia: 'm', fechaEntrega: f);

    expect(con(DateTime(2026, 6, 7)).urgencia(hoy), Urgencia.atrasado);
    expect(con(DateTime(2026, 6, 8)).urgencia(hoy), Urgencia.urgente); // hoy
    expect(con(DateTime(2026, 6, 9)).urgencia(hoy), Urgencia.urgente); // mañana
    expect(con(DateTime(2026, 6, 20)).urgencia(hoy), Urgencia.normal);
  });

  test('ordenarDeberes: pendientes por fecha, hechos al final', () {
    final a = Deber(id: 'a', titulo: 'a', materia: 'm', fechaEntrega: DateTime(2026, 6, 10));
    final b = Deber(id: 'b', titulo: 'b', materia: 'm', fechaEntrega: DateTime(2026, 6, 5));
    final c = Deber(id: 'c', titulo: 'c', materia: 'm', fechaEntrega: DateTime(2026, 6, 1), hecho: true);
    final lista = [a, b, c];
    ordenarDeberes(lista);
    expect(lista.map((d) => d.id).toList(), ['b', 'a', 'c']);
  });
}
