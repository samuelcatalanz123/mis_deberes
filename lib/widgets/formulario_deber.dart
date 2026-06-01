import 'package:flutter/material.dart';
import '../models/deber.dart';

/// Muestra un diálogo para crear un deber. Devuelve el Deber creado, o null si
/// se cancela.
Future<Deber?> mostrarFormularioDeber(BuildContext context) {
  final tituloCtrl = TextEditingController();
  final materiaCtrl = TextEditingController();
  DateTime fecha = DateTime.now().add(const Duration(days: 1));

  return showDialog<Deber>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nuevo deber'),
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
                  Navigator.pop(
                    context,
                    Deber(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      titulo: tituloCtrl.text.trim(),
                      materia: materiaCtrl.text.trim().isEmpty
                          ? 'General'
                          : materiaCtrl.text.trim(),
                      fechaEntrega: fecha,
                    ),
                  );
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
