import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deber.dart';
import '../services/almacenamiento.dart';
import '../widgets/formulario_deber.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  List<Deber> _deberes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await cargarDeberes();
    ordenarDeberes(lista);
    setState(() {
      _deberes = lista;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    ordenarDeberes(_deberes);
    await guardarDeberes(_deberes);
    setState(() {});
  }

  Future<void> _agregar() async {
    final nuevo = await mostrarFormularioDeber(context);
    if (nuevo != null) {
      _deberes.add(nuevo);
      await _guardar();
    }
  }

  Color _color(Deber d) {
    switch (d.urgencia(DateTime.now())) {
      case Urgencia.atrasado:
        return Colors.red;
      case Urgencia.urgente:
        return Colors.orange;
      case Urgencia.normal:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Deberes')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _deberes.isEmpty
              ? const Center(child: Text('No tienes deberes. ¡Agrega uno con +!'))
              : ListView.builder(
                  itemCount: _deberes.length,
                  itemBuilder: (context, i) {
                    final d = _deberes[i];
                    return ListTile(
                      leading: Checkbox(
                        value: d.hecho,
                        onChanged: (v) {
                          d.hecho = v ?? false;
                          _guardar();
                        },
                      ),
                      title: Text(
                        d.titulo,
                        style: TextStyle(
                          decoration:
                              d.hecho ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        '${d.materia}  ·  ${DateFormat('EEE d MMM', 'es').format(d.fechaEntrega)}',
                        style: TextStyle(
                          color: d.hecho ? Colors.grey : _color(d),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          _deberes.removeAt(i);
                          _guardar();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
