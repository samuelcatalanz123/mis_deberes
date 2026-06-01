import 'package:flutter/material.dart';
import '../models/deber.dart';

/// Muestra un diálogo para crear o editar un deber.
///
/// - Si [deber] es null: crea uno nuevo y lo devuelve.
/// - Si [deber] tiene un valor: precarga sus datos, le aplica los cambios y
///   devuelve el MISMO deber actualizado.
///
/// Devuelve null si se cancela.
Future<Deber?> mostrarFormularioDeber(BuildContext context, {Deber? deber}) {
  final editando = deber != null;
  final tituloCtrl = TextEditingController(text: deber?.titulo ?? '');
  final materiaCtrl = TextEditingController(text: deber?.materia ?? '');
  DateTime fecha = deber?.fechaEntrega ?? DateTime.now().add(const Duration(days: 1));

  return showDialog<Deber>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(editando ? 'Editar deber' : 'Nuevo deber'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  TextField(
                    controller: materiaCtrl,
                    decoration: const InputDecoration(labelText: 'Materia'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Entrega: ${fecha.day}/${fecha.month}/${fecha.year}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final elegida = await showDatePicker(
                            context: context,
                            initialDate: fecha,
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (elegida != null) setState(() => fecha = elegida);
                        },
                        child: const Text('Elegir fecha'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tituloCtrl.text.trim().isEmpty) return; // título obligatorio
                  final titulo = tituloCtrl.text.trim();
                  final materia = materiaCtrl.text.trim().isEmpty
                      ? 'General'
                      : materiaCtrl.text.trim();
                  if (editando) {
                    // Editar: actualizamos el mismo deber.
                    deber.titulo = titulo;
                    deber.materia = materia;
                    deber.fechaEntrega = fecha;
                    Navigator.pop(context, deber);
                  } else {
                    // Nuevo: creamos uno con id propio.
                    Navigator.pop(
                      context,
                      Deber(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        titulo: titulo,
                        materia: materia,
                        fechaEntrega: fecha,
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}
