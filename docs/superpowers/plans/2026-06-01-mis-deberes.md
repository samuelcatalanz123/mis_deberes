# "Mis Deberes" — Plan de Implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir una app móvil Flutter para apuntar deberes del colegio (título, materia, fecha de entrega), verlos ordenados por urgencia, marcarlos como hechos y que se guarden en el teléfono.

**Architecture:** App Flutter de una sola persona, sin servidor. La lógica pura (modelo, orden, urgencia) se prueba con `flutter test`. La persistencia usa `shared_preferences` (la lista se guarda como JSON). La UI usa `setState`.

**Tech Stack:** Flutter, Dart, shared_preferences, intl.

---

## Estructura de archivos

- `pubspec.yaml` — dependencias (shared_preferences, intl).
- `lib/models/deber.dart` — clase `Deber` (toJson/fromJson), enum `Urgencia`, función `ordenarDeberes`.
- `lib/services/almacenamiento.dart` — `cargarDeberes()` / `guardarDeberes()`.
- `lib/widgets/formulario_deber.dart` — diálogo para crear un deber nuevo.
- `lib/screens/pantalla_principal.dart` — la lista + acciones.
- `lib/main.dart` — arranque de la app.
- `test/deber_test.dart` — tests del modelo, urgencia y orden.
- `test/almacenamiento_test.dart` — tests de guardado/carga.

---

### Task 0: Crear el proyecto Flutter

**Files:**
- Create: todo el esqueleto Flutter en `/Users/mqr93ea/Repos/mis_deberes`

- [ ] **Step 1: Crear el proyecto en la carpeta existente**

Run:
```bash
cd /Users/mqr93ea/Repos/mis_deberes
flutter create --project-name mis_deberes --platforms web .
```
Expected: crea `lib/`, `pubspec.yaml`, `web/`, etc. (No borra `docs/`.)

- [ ] **Step 2: Agregar dependencias**

Run:
```bash
cd /Users/mqr93ea/Repos/mis_deberes
flutter pub add shared_preferences intl
```
Expected: `pubspec.yaml` lista `shared_preferences` e `intl`; `flutter pub get` corre solo.

- [ ] **Step 3: Verificar que el proyecto compila**

Run: `flutter analyze`
Expected: "No issues found!" (o solo avisos del contador de ejemplo).

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: scaffold proyecto Flutter + deps (shared_preferences, intl)"
```

---

### Task 1: Modelo `Deber` (JSON + urgencia)

**Files:**
- Create: `lib/models/deber.dart`
- Test: `test/deber_test.dart`

- [ ] **Step 1: Escribir el test que falla**

```dart
// test/deber_test.dart
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
}
```

- [ ] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/deber_test.dart`
Expected: FAIL — `Deber` no existe todavía.

- [ ] **Step 3: Escribir el modelo**

```dart
// lib/models/deber.dart

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
```

- [ ] **Step 4: Correr el test para verlo pasar**

Run: `flutter test test/deber_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/models/deber.dart test/deber_test.dart
git commit -m "feat: modelo Deber con JSON y urgencia"
```

---

### Task 2: Orden de la lista

**Files:**
- Modify: `test/deber_test.dart` (agregar un test)

- [ ] **Step 1: Agregar el test de orden**

Agrega este `test(...)` dentro del `main()` de `test/deber_test.dart`:
```dart
  test('ordenarDeberes: pendientes por fecha, hechos al final', () {
    final a = Deber(id: 'a', titulo: 'a', materia: 'm', fechaEntrega: DateTime(2026, 6, 10));
    final b = Deber(id: 'b', titulo: 'b', materia: 'm', fechaEntrega: DateTime(2026, 6, 5));
    final c = Deber(id: 'c', titulo: 'c', materia: 'm', fechaEntrega: DateTime(2026, 6, 1), hecho: true);
    final lista = [a, b, c];
    ordenarDeberes(lista);
    expect(lista.map((d) => d.id).toList(), ['b', 'a', 'c']);
  });
```

- [ ] **Step 2: Correr y verificar que pasa**

Run: `flutter test test/deber_test.dart`
Expected: PASS (3 tests) — `ordenarDeberes` ya está implementada en la Task 1.

- [ ] **Step 3: Commit**

```bash
git add test/deber_test.dart
git commit -m "test: orden de deberes (pendientes por fecha, hechos al final)"
```

---

### Task 3: Almacenamiento (guardar/cargar)

**Files:**
- Create: `lib/services/almacenamiento.dart`
- Test: `test/almacenamiento_test.dart`

- [ ] **Step 1: Escribir el test que falla**

```dart
// test/almacenamiento_test.dart
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
```

- [ ] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/almacenamiento_test.dart`
Expected: FAIL — `almacenamiento.dart` no existe.

- [ ] **Step 3: Escribir el almacenamiento**

```dart
// lib/services/almacenamiento.dart
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
  return lista
      .map((e) => Deber.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Guarda toda la lista de deberes como JSON.
Future<void> guardarDeberes(List<Deber> deberes) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = jsonEncode(deberes.map((d) => d.toJson()).toList());
  await prefs.setString(_clave, raw);
}
```

- [ ] **Step 4: Correr el test para verlo pasar**

Run: `flutter test test/almacenamiento_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/services/almacenamiento.dart test/almacenamiento_test.dart
git commit -m "feat: guardar/cargar deberes con shared_preferences"
```

---

### Task 4: Formulario "Nuevo deber"

**Files:**
- Create: `lib/widgets/formulario_deber.dart`

- [ ] **Step 1: Escribir el formulario (diálogo)**

```dart
// lib/widgets/formulario_deber.dart
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
                        child: Text('Entrega: ${fecha.day}/${fecha.month}/${fecha.year}'),
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
```

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze lib/widgets/formulario_deber.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/formulario_deber.dart
git commit -m "feat: formulario para crear un deber nuevo"
```

---

### Task 5: Pantalla principal (lista + acciones)

**Files:**
- Create: `lib/screens/pantalla_principal.dart`

- [ ] **Step 1: Escribir la pantalla**

```dart
// lib/screens/pantalla_principal.dart
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
                          decoration: d.hecho ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        '${d.materia}  ·  ${DateFormat('EEE d MMM', 'es').format(d.fechaEntrega)}',
                        style: TextStyle(color: d.hecho ? Colors.grey : _color(d)),
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
```

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze lib/screens/pantalla_principal.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/screens/pantalla_principal.dart
git commit -m "feat: pantalla principal con lista, colores, check y borrar"
```

---

### Task 6: main.dart + correr la app

**Files:**
- Modify: `lib/main.dart` (reemplazar el contador de ejemplo)

- [ ] **Step 1: Reemplazar main.dart**

```dart
// lib/main.dart
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
```

- [ ] **Step 2: Analizar todo el proyecto**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 3: Correr todos los tests**

Run: `flutter test`
Expected: All tests passed! (5 tests).

- [ ] **Step 4: Correr la app y probarla a mano**

Run: `flutter run -d web-server --web-port 8095`
Verificar en el navegador (http://localhost:8095):
- Agregar un deber con (+) → aparece en la lista.
- La fecha cercana se ve naranja; una pasada, roja.
- Marcar el check → se tacha y baja al final.
- Borrar (🗑) → desaparece.
- Recargar la página → los deberes siguen ahí.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart
git commit -m "feat: app Mis Deberes funcionando (main + i18n de fechas)"
```

---

## Notas
- `intl` necesita `initializeDateFormatting('es')` antes de usar `DateFormat(..., 'es')` (por eso el `main` es `async`).
- Si `flutter analyze` se queja del `print`/contador de ejemplo, bórralo: lo reemplazamos en la Task 6.
- Versión 1 no edita deberes (solo crear/marcar/borrar), según el spec.
