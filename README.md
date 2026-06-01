# 📚 Mis Deberes

App móvil (Flutter) para apuntar y organizar los deberes del colegio. Hecha por
[Samuel Catalán](https://github.com/samuelcatalanz123).

## ▶️ Pruébala en vivo

👉 **https://samuelcatalanz123.github.io/mis-deberes-web/**

(Se abre en el navegador, también desde el teléfono. Tus deberes se guardan en
tu propio dispositivo.)

## ✨ Qué hace

- ➕ Agregar un deber con **título, materia y fecha de entrega**.
- ✏️ **Editar** un deber (tócalo para cambiarlo).
- ✅ **Marcar como hecho** (se tacha y baja al final).
- 🗑️ **Borrar** con confirmación (para no perder nada por accidente).
- ⏰ **Orden por urgencia** y colores: 🔴 atrasado, 🟠 hoy/mañana.
- 🎨 Cada **materia con su propio color**.
- 🔢 **Contador de pendientes** en el título.
- 💾 **Guardado local**: tus deberes siguen ahí aunque cierres la app.

## 🛠️ Tecnología

- **Flutter** (Dart)
- **shared_preferences** — guardado local (la lista se guarda como JSON)
- **intl** — fechas en español

## 🚀 Cómo correrlo

```bash
flutter pub get
flutter run            # en un dispositivo/emulador
# o en el navegador:
flutter run -d web-server --web-port 8095
```

## 🧪 Pruebas

```bash
flutter test
```

Hay pruebas del modelo (JSON, urgencia, orden) y del guardado.

## 📁 Estructura

```
lib/
  models/deber.dart               # el modelo Deber + urgencia + orden
  services/almacenamiento.dart    # guardar / cargar (shared_preferences)
  widgets/formulario_deber.dart   # formulario para crear/editar
  screens/pantalla_principal.dart # la lista y sus acciones
  main.dart                       # arranque de la app
```

---

Hecho con 💙 aprendiendo Flutter.
