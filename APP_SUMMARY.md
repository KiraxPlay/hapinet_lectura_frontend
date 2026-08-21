# Resumen de la App - Medidor Hapinet App

## 📋 Descripción General
**Medidor Hapinet App** es una aplicación Flutter para la gestión de abonados y lectura de medidores de agua. Permite a los operadores de acueductos capturar, procesar y administrar lecturas de medidores de forma offline, con sincronización de datos.

**Versión:** 2.0.1  
**Plataformas:** Android, iOS, Web, Windows, Linux  
**Tecnología:** Flutter (Dart)

---

## 🎯 Funcionalidades Principales

### 1. **Autenticación & Gestión de Sesiones**
- Sistema de login/logout
- Soporte multi-acueducto (cada usuario puede tener múltiples organizaciones)
- Cada acueducto tiene su propia base de datos aislada
- Persistencia de sesión activa

### 2. **Captura de Lecturas**
- **Cámara integrada** para fotografiar el medidor
- **OCR offline** (Google ML Kit) para extracción automática de números del medidor
- **Geolocalización GPS** en tiempo real para ubicar las mediciones
- **Guía de encuadre visual** para ayudar al usuario
- **Estado del medidor** (selector para estado/condición)
- **Speech-to-Text (ASR)** para captura por voz
- Validación automática de lecturas

### 3. **Gestión de Datos**
- **Base de datos local (SQLite)** vía Drift ORM
- Base de datos aislada por acueducto
- Sincronización de abonados desde archivos JSON
- Almacenamiento de:
  - Lecturas capturadas
  - Fotografías
  - Coordenadas GPS
  - Resultados OCR

### 4. **Mapa Interactivo**
- **Mapa offline** con flutter_map y tiles cacheados
- Visualización de todos los puntos de lectura
- Marcadores con información del medidor
- Filtros por sector/zona
- Resumen de lecturas en el mapa
- Contador de mediciones
- Búsqueda desde el mapa

### 5. **Historial & Reportes**
- Visualización de lecturas capturadas por día
- Detalles de cada lectura (foto, OCR, GPS, estado)
- Historial completo de lecturas
- Exportación de datos:
  - **Excel** con información detallada
  - **PDF** con reportes formateados
  - **ZIP** con Excel + imágenes
  - **Compartir** archivos vía plataforma

### 6. **Abonados**
- Base de datos de abonados por acueducto
- Búsqueda e información de abonados
- Lectura anterior disponible
- Referencia de ubicación (latitud/longitud)

---

## 🏗️ Arquitectura & Estructura de Carpetas

```
lib/
├── main.dart                 # Punto de entrada, gestión de sesiones
├── screens/                  # Pantallas principales
│   ├── login_screen.dart
│   ├── splash_screen.dart
│   ├── home_screen.dart      # Hub principal (3 tabs)
│   ├── captura_screen.dart   # Captura de lecturas
│   ├── mapa_screen.dart      # Visualización en mapa
│   ├── historial_screen.dart # Historial de lecturas
│   ├── lecturas_dia_screen.dart
│   ├── info_abonado_screen.dart
│   └── descarga_mapa_screen.dart
├── components/               # Componentes UI reutilizables
│   ├── captura/              # Componentes para captura
│   ├── mapa/                 # Componentes para mapa
│   ├── funciones/            # Componentes funcionales
│   └── fondo_gotas.dart      # Diseño decorativo
├── services/                 # Servicios & lógica de negocio
│   ├── camara_service.dart
│   ├── ocr_service.dart
│   ├── geolocalizacion_service.dart
│   ├── asr_service.dart      # Speech-to-Text
│   ├── mapa_service.dart
│   ├── exportar_service.dart
│   ├── exportar_pdf.dart
│   ├── historial_service.dart
│   ├── importar_abonados_service.dart
│   ├── sesion_service.dart
│   ├── tiles_service.dart    # Gestión de tiles del mapa
│   └── abonados_service.dart
├── models/                   # Modelos de datos
│   ├── acueducto.dart
│   ├── abonado.dart
│   ├── foto_result.dart
│   ├── ocr_result.dart
│   ├── posicion_result.dart
│   ├── punto_mapa.dart
│   └── estado_medidor.dart
├── data/                     # Base de datos
│   ├── database.dart         # Definición Drift ORM
│   └── database.g.dart       # Código generado
└── utils/
    └── constantes.dart
```

---

## 📱 Pantallas Principales

1. **Splash Screen** - Pantalla de carga inicial
2. **Login Screen** - Autenticación de usuario
3. **Home Screen** - Panel principal con 3 tabs:
   - Lecturas del día
   - Historial de lecturas
   - Mapa interactivo
4. **Captura Screen** - Captura de medidor (cámara + OCR + GPS)
5. **Mapa Screen** - Visualización geoespacial
6. **Historial Screen** - Historial completo
7. **Info Abonado Screen** - Detalles del abonado

---

## 🔧 Tecnologías & Dependencias Clave

### Cámara & Visión
- `camera: ^0.10.5` - Acceso a cámara del dispositivo
- `google_mlkit_text_recognition: ^0.13.0` - OCR offline para leer números

### Datos & Base de Datos
- `drift: ^2.18.0` - ORM para SQLite
- `sqlite3_flutter_libs: ^0.5.24` - Driver SQLite
- `shared_preferences: ^2.3.2` - Almacenamiento de preferencias

### Localización & Mapas
- `geolocator: ^12.0.0` - GPS en tiempo real
- `flutter_map: ^6.1.0` - Mapa interactivo offline
- `latlong2: ^0.9.0` - Coordenadas geográficas
- `flutter_map_cache: ^1.2.0` - Cache de tiles del mapa

### Permisos
- `permission_handler: ^11.3.1` - Gestión de permisos en runtime

### Audio & Voz
- `speech_to_text: ^7.0.0` - Speech-to-Text (ASR)

### Exportación & Reportes
- `excel: ^4.0.6` - Generación de archivos Excel
- `pdf: ^3.10.8` - Generación de PDF
- `printing: ^5.9.0` - Vista previa de impresión
- `archive: ^3.6.1` - Compresión ZIP
- `share_plus: ^10.0.0` - Compartir archivos

### Utilidades
- `path_provider: ^2.1.3` - Rutas del sistema
- `uuid: ^4.4.0` - Generación de IDs únicos
- `intl: ^0.19.0` - Internacionalización
- `dio: ^5.7.0` - Cliente HTTP

---

## 🎨 Características de Diseño & UX

### Visual
- Orientación **solo vertical** (retrato)
- Material Design 3
- Componente decorativo "fondo de gotas" temático
- Tema con colores de empresa Hapinet

### UX
- Interfaz **offline-first** con sincronización
- Guía visual de encuadre para captura de medidor
- Validación en tiempo real de OCR
- Mapa con zoom/pan para exploración
- Filtros por sector en el mapa
- Búsqueda de abonados

### Accesibilidad
- Soporte multi-acueducto/multi-usuario
- Manejo de permisos en tiempo de ejecución
- Procesamiento offline para zonas sin conexión

---

## 📊 Flujo Principal de Usuario

1. **Splash Screen** → Verificar sesión activa
2. **Login** → Seleccionar acueducto
3. **Home Screen** (hub principal)
   - **Tab 1 (Lecturas):** Ver lecturas del día
   - **Tab 2 (Historial):** Historial completo, exportar reportes
   - **Tab 3 (Mapa):** Visualizar en mapa, filtrar, buscar
4. **Captura Screen** → Fotografiar medidor → OCR extrae número → GPS registra ubicación
5. **Almacenamiento** → Se guarda en BD local con timestamp
6. **Exportación** → Generar Excel/PDF/ZIP con datos

---

## 🔄 Sincronización & Offline

- **Totalmente offline** - Toda la funcionalidad funciona sin internet
- Base de datos SQLite para persistencia local
- Datos de abonados cargados desde JSON local
- OCR (Google ML Kit) funciona offline
- GPS registra coordenadas offline
- Exportación genera archivos locales
- Tiles de mapa cacheados para consulta offline

---

## ⚙️ Configuración Actual

- **SDK Flutter:** ^3.7.2
- **Versión App:** 2.0.1
- **Min API Android:** 21
- **Orientación:** Solo vertical
- **Compilación:** Soporta APK release

---

## 🎯 Áreas Potenciales de Mejora de Diseño

1. **UI/UX de Captura** - Simplificar flujo de captura
2. **Mapa** - Mejorar visualización y controles
3. **Historial** - Mejor presentación de datos
4. **Exportación** - Opciones más intuitivas
5. **Temas visuales** - Diseño moderno y coherente
6. **Navegación** - Mejorar flujo entre pantallas
7. **Feedback visual** - Estados de carga y errores más claros

---

**Nota:** Esta es una app de producción en versión 2.0.1, actualmente compilada a APK release.
