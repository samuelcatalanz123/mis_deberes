# Diseño — "Mis Deberes" (app móvil de tareas del colegio)

**Fecha:** 2026-06-01
**Autor:** Samuel
**Tipo:** App móvil (Flutter / Dart)

## Objetivo

Una app de teléfono donde Samuel apunta sus deberes del colegio y ve de un
vistazo qué tiene que entregar y cuándo. De uso personal y diario, funciona
sin internet.

## Para quién

Para Samuel (y cualquier estudiante). Un solo usuario, en su propio teléfono.

## Funciones (alcance)

Incluye (versión 1, mínima útil):

1. **Agregar un deber** con: título, materia y fecha de entrega.
2. **Ordenar por fecha de entrega** (lo más próximo, arriba) y **resaltar la
   urgencia** con color: 🔴 atrasado, 🟠 hoy/mañana, normal si falta más.
3. **Marcar como hecho** (se tacha y baja al final).
4. **Guardado en el teléfono**: los deberes persisten al cerrar la app
   (`shared_preferences`, en formato JSON).

NO incluye (YAGNI — para más adelante si se quiere):

- Sincronización entre dispositivos / servidor (sería la Opción C con backend).
- Notificaciones push, adjuntar archivos, compartir, cuentas de usuario.
- Editar un deber existente (v1 sólo crea, marca hecho y borra).

## Pantallas

1. **Pantalla principal** — lista de deberes:
   - Orden: por fecha de entrega ascendente; los **hechos** al final.
   - Cada fila: título, **materia** (etiqueta/chip de color), fecha de entrega
     formateada, y un **check** para marcar hecho.
   - Color de urgencia según la fecha (ver "Lógica").
   - Botón flotante **(+)** para agregar.
   - Deslizar o un botón para **borrar** un deber.
2. **Formulario "Nuevo deber"** (diálogo o pantalla):
   - Campo título (texto), materia (texto), fecha de entrega (selector de
     fecha nativo de Flutter).
   - Botones Guardar / Cancelar. Validación: título no vacío.

## Modelo de datos

Un **Deber**:

| Campo          | Tipo      | Notas                                  |
|----------------|-----------|----------------------------------------|
| `id`           | String    | identificador único (timestamp/aleatorio) |
| `titulo`       | String    | obligatorio                            |
| `materia`      | String    | ej. "Matemáticas"                      |
| `fechaEntrega` | DateTime  | fecha límite                           |
| `hecho`        | bool      | si ya se entregó                       |

Se serializa a/desde JSON (`toJson` / `fromJson`).

## Lógica clave

- **Orden:** primero los pendientes por `fechaEntrega` ascendente; los hechos
  al final.
- **Urgencia (color):** comparar `fechaEntrega` con hoy:
  - antes de hoy → atrasado (rojo)
  - hoy o mañana → urgente (naranja)
  - después → normal
- **Persistencia:** al cambiar la lista (agregar/marcar/borrar) se guarda toda
  la lista como JSON en `shared_preferences`; al abrir la app se carga.

## Tecnología

- **Flutter** (Dart).
- **`shared_preferences`** — guardado local.
- **`intl`** — formatear fechas (ej. "lun 8 jun").
- Selector de fecha (`showDatePicker`, incluido en Flutter).
- Estado con `setState` (suficiente para esta app).

## Estructura del código

- `lib/models/deber.dart` — clase `Deber` (con `toJson`/`fromJson`).
- `lib/services/almacenamiento.dart` — `cargarDeberes()` / `guardarDeberes()`.
- `lib/screens/pantalla_principal.dart` — la lista + botón (+).
- `lib/widgets/formulario_deber.dart` — formulario de nuevo deber.
- `lib/main.dart` — arranque de la app.

Cada archivo tiene una sola responsabilidad clara, para que sea fácil de
entender y modificar.

## Criterios de éxito

- Puedo agregar un deber con materia y fecha, y aparece en la lista.
- La lista se ordena por fecha y resalta lo urgente con color.
- Puedo marcar un deber como hecho y borrarlo.
- Si cierro y vuelvo a abrir la app, mis deberes siguen ahí.
- La app corre en el navegador/emulador con `flutter run`.
