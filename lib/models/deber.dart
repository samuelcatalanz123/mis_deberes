/// Qué tan urgente es un deber según su fecha de entrega.
enum Urgencia { atrasado, urgente, normal }

/// Un deber del colegio.
class Deber {
  final String id;
  String titulo;
  String materia;
  DateTime fechaEntrega;
  bool hecho;

  Deber({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.fechaEntrega,
    this.hecho = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'materia': materia,
        'fechaEntrega': fechaEntrega.toIso8601String(),
        'hecho': hecho,
      };

  factory Deber.fromJson(Map<String, dynamic> json) => Deber(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        materia: json['materia'] as String,
        fechaEntrega: DateTime.parse(json['fechaEntrega'] as String),
        hecho: json['hecho'] as bool,
      );

  /// Compara solo la fecha (sin la hora) contra [hoy].
  Urgencia urgencia(DateTime hoy) {
    final fecha = DateTime(fechaEntrega.year, fechaEntrega.month, fechaEntrega.day);
    final dia = DateTime(hoy.year, hoy.month, hoy.day);
    final manana = dia.add(const Duration(days: 1));
    if (fecha.isBefore(dia)) return Urgencia.atrasado;
    if (fecha == dia || fecha == manana) return Urgencia.urgente;
    return Urgencia.normal;
  }
}

/// Ordena la lista EN SITIO: pendientes primero por fecha ascendente, y los
/// deberes hechos al final.
void ordenarDeberes(List<Deber> deberes) {
  deberes.sort((a, b) {
    if (a.hecho != b.hecho) return a.hecho ? 1 : -1;
    return a.fechaEntrega.compareTo(b.fechaEntrega);
  });
}
