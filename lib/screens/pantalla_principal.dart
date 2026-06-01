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
  String _filtro = 'todos'; // 'todos' | 'pendientes' | 'hechos'

  /// Los deberes que se muestran según el filtro elegido.
  List<Deber> get _visibles {
    switch (_filtro) {
      case 'pendientes':
        return _deberes.where((d) => !d.hecho).toList();
      case 'hechos':
        return _deberes.where((d) => d.hecho).toList();
      default:
        return _deberes;
    }
  }

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

  Future<void> _editar(Deber d) async {
    final editado = await mostrarFormularioDeber(context, deber: d);
    if (editado != null) {
      // El deber se actualizó en sitio; solo guardamos y reordenamos.
      await _guardar();
    }
  }

  // Pide confirmación antes de borrar, para no perder un deber por accidente.
  Future<void> _confirmarBorrar(Deber d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar deber?'),
        content: Text('Se eliminará "${d.titulo}". Esto no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      _deberes.remove(d);
      await _guardar();
    }
  }

  // Asigna un color fijo a cada materia (siempre el mismo para la misma
  // materia) eligiéndolo de una paleta según el nombre.
  Color _colorMateria(String materia) {
    const paleta = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.indigo,
      Colors.deepOrange,
    ];
    return paleta[materia.hashCode.abs() % paleta.length];
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

  // Barra con los tres filtros (Todos / Pendientes / Hechos).
  Widget _barraFiltros() {
    Widget chip(String valor, String etiqueta) {
      return ChoiceChip(
        label: Text(etiqueta),
        selected: _filtro == valor,
        onSelected: (_) => setState(() => _filtro = valor),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        children: [
          chip('todos', 'Todos'),
          chip('pendientes', 'Pendientes'),
          chip('hechos', 'Hechos'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cuántos deberes faltan por entregar (no hechos).
    final pendientes = _deberes.where((d) => !d.hecho).length;
    final titulo = pendientes == 0
        ? 'Mis Deberes'
        : 'Mis Deberes · $pendientes pendiente${pendientes == 1 ? '' : 's'}';

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _barraFiltros(),
                Expanded(
                  child: _visibles.isEmpty
                      ? Center(
                          child: Text(_deberes.isEmpty
                              ? 'No tienes deberes. ¡Agrega uno con +!'
                              : 'No hay deberes en este filtro.'),
                        )
                      : ListView.builder(
                          itemCount: _visibles.length,
                          itemBuilder: (context, i) {
                            final d = _visibles[i];
                            return ListTile(
                      onTap: () => _editar(d),
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
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _colorMateria(d.materia).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              d.materia,
                              style: TextStyle(
                                color: _colorMateria(d.materia),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEE d MMM', 'es').format(d.fechaEntrega),
                            style: TextStyle(color: d.hecho ? Colors.grey : _color(d)),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmarBorrar(d),
                      ),
                    );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
