# Perfil y funcionalidades complementarias

Implementación académica para el Taller Práctico 3 de SENATI. Prototipo no oficial
de Burger King Perú. No incluye backend, cuentas reales, almacenamiento de datos
personales, envíos de correo, permisos del sistema ni nuevas dependencias.

## Funcionalidades

- **Perfil:** avatar local, identidad ficticia, 450 coronas demostrativas y acceso
  a las seis opciones del módulo.
- **Registro:** nombre, correo, celular peruano de nueve dígitos iniciado en 9,
  contraseña de ocho caracteres como mínimo, confirmación y términos obligatorios.
  Permite consultar los términos y alternar la visibilidad de ambas contraseñas.
  Tras validar, limpia los campos y presenta una confirmación simulada. Al cerrarla,
  vuelve a la pantalla desde donde se abrió el registro.
- **Guía rápida:** cuatro páginas con deslizamiento, progreso y controles Anterior,
  Siguiente y Finalizar. Finalizar vuelve a Perfil.
- **Contacto:** valida nombre, correo, motivo y mensaje; confirma un envío simulado
  y limpia el formulario.
- **Newsletter:** valida correo y consentimiento voluntario, confirma la suscripción
  simulada y restablece el formulario.
- **Notificaciones:** tres preferencias independientes y vista previa manual.
  Las preferencias se mantienen mientras Perfil permanezca en la pila de navegación;
  al salir a Inicio y abrir Perfil de nuevo se restablecen. No se persisten.
- **Compartir:** diálogo con mensaje de ejemplo, cancelación y confirmación simulada.

## Archivos creados

| Archivo | Responsabilidad |
| --- | --- |
| `lib/profile_screen.dart` | Perfil y navegación del módulo; estado temporal de preferencias |
| `lib/register_screen.dart` | Formulario y confirmación del registro |
| `lib/quick_guide_screen.dart` | Guía interactiva de cuatro pasos |
| `lib/contact_screen.dart` | Formulario de contacto |
| `lib/newsletter_screen.dart` | Suscripción voluntaria simulada |
| `lib/notification_settings_screen.dart` | Modelo de preferencias, interruptores y ejemplo |
| `lib/profile_widgets.dart` | Scaffold adaptable, introducciones, consentimiento y confirmaciones |
| `lib/profile_validators.dart` | Validadores reutilizables sin efectos secundarios |
| `test/profile_module_test.dart` | Pruebas de formularios, navegación, estado y adaptación |
| `test/support/network_images.dart` | Imágenes locales para probar Inicio sin conexiones externas |
| `docs/perfil-funciones-complementarias.md` | Entrega, limitaciones, guía de prueba y texto para PR |

## Archivos modificados

| Archivo | Cambio y motivo |
| --- | --- |
| `lib/app_theme.dart` | Añade `ProfileStyles` reutilizando colores y botón existentes; no cambia los estilos anteriores |
| `lib/home_screen.dart` | Envuelve el avatar existente en un botón accesible con tooltip para abrir Perfil |
| `lib/login_screen.dart` | Sustituye el aviso temporal de registro por navegación a Registro |
| `test/bod_burguer_test.dart` | Usa `flutter_test`, ya declarado, en lugar de `test`, que no estaba declarado |
| `test/widget_test.dart` | Elimina una importación sin uso que impedía un análisis limpio |

No se modifican `main.dart`, dependencias, lógica del carrito, opciones de la barra
inferior ni módulos de otras ramas. Se conserva el diseño anterior de Login e Inicio.

## Navegación

Todas las pantallas se abren con `Navigator.push` y `MaterialPageRoute`:

```text
Login ─ Regístrate aquí → Registro ─ volver / confirmar → Login
Login ─ ingreso existente → Inicio ─ avatar Mi perfil → Perfil
Perfil ─ Registro / Guía rápida / Contacto / Newsletter / Notificaciones
       └ Compartir aplicación → diálogo → Perfil
```

Volver desde una pantalla complementaria conserva Perfil. Volver desde Perfil
conserva Inicio y su carrito. El registro usa la ruta previa, sin reemplazar Login
ni crear una sesión real. Los formularios no transmiten ni persisten su contenido;
las contraseñas se limpian al completar la simulación y sus controladores se liberan
al cerrar la pantalla.

## Verificación

Entorno: Flutter 3.47.9, Dart 3.13.7, Windows. Comandos ejecutados:

```powershell
flutter pub get
flutter analyze
flutter test
```

Resultados finales del 9 de noviembre de 2026:

| Comando | Resultado |
| --- | --- |
| `flutter pub get` | Correcto, sin cambios en dependencias ni lockfile |
| `flutter analyze` | Correcto: `No issues found!` |
| `flutter test` | Correcto: 19 pruebas aprobadas, 0 fallos |
| `git diff --check -- lib test docs` | Correcto, sin errores de whitespace |

La suite contiene dos pruebas anteriores y diecisiete pruebas del módulo. Cubre:

- Inicio → Perfil → Inicio, manteniendo las opciones existentes y el total del carrito.
- Login → Registro → Login y todas las rutas de Perfil con retorno.
- Campos vacíos, correo incorrecto, número peruano incorrecto y de longitud distinta
  a nueve, contraseña corta, confirmación distinta y términos obligatorios.
- Registro válido, borrado de campos y contraseñas, confirmación y retorno a Perfil.
- Lectura de términos y visibilidad de ambas contraseñas.
- Cuatro pasos de la guía, deslizamiento, retroceso y finalización.
- Contacto y Newsletter: errores, consentimiento cuando corresponde,
  confirmaciones simuladas y restablecimiento de formularios.
- Tres interruptores independientes, persistencia temporal al reabrir ajustes
  y notificación de ejemplo.
- Compartir: cancelar y completar la simulación.
- Las seis pantallas del módulo a 320×568, 390×844, 640×360 y 768×1024,
  con texto al 150 %, sin desbordamientos.
- Registro a 320×568 con texto al 150 %, teclado simulado y errores de validación.

Las imágenes remotas ya existentes en Inicio se sustituyen solo durante su prueba
por un PNG local; no se silencian errores de renderizado en la suite permanente.

## Limitaciones y hallazgos previos

- El checkout estaba en `andre`, con cambios locales previos en `build/` y
  `windows/flutter/`. `andre`, `main` y `origin/main` apuntaban al commit
  `1d61b166547814394bfd424797d60907e91758e3` en la inspección inicial.
  Por la condición de trabajar en una rama nueva solo con un árbol limpio,
  no se cambió de rama ni se creó `feature/perfil-funciones-complementarias`.
  No se hicieron commits, push ni merges de ninguna rama.
- Inicio ya presenta desbordamientos en pruebas de widgets a 390×844. Una
  comparación diagnóstica del archivo de `main` con el actual produjo los mismos
  17 avisos y las mismas magnitudes en ambos. Se conserva ese diseño conforme al
  alcance solicitado; la prueba de navegación de Inicio usa 1000×1000. La
  adaptación a smartphone se verifica por separado para todas las pantallas nuevas.
  La comparación temporal se guardó en `.dart_tool/profile_baseline/`, fuera de la
  entrega versionable.
- Algunos controles anteriores de Inicio siguen siendo placeholders, por ejemplo
  ubicación, premios y cambio de restaurante. No se implementan módulos ajenos ni
  se importan las ramas `Aileen` o `juancito`.
- No se verificó el módulo en un teléfono o emulador Android/iOS. El repositorio
  inspeccionado contiene destinos Web y Windows; no contiene carpetas Android/iOS.
- La primera ejecución de Flutter estuvo restringida por permisos de escritura
  en su caché. Los comandos posteriores se ejecutaron con el acceso permitido por
  el entorno. No se modificó la versión del SDK ni se actualizaron paquetes.
- Flutter genera carpetas de pruebas dentro de `build/`; no incluir esos artefactos
  ni los cambios generados previos al preparar el commit del módulo.

## Cómo probarlo manualmente

Desde la raíz del proyecto:

```powershell
flutter pub get
flutter run -d chrome
```

1. En Login, desplázate hasta **Regístrate aquí**. Envía vacío para ver las
   validaciones; completa con `Alex Parrilla`, `alex@ejemplo.com`, `987654321` y
   `ClaveDemo123` en ambas contraseñas. Lee y acepta los términos, confirma y
   verifica el regreso a Login.
2. Usa el ingreso existente o **Pedir rápido como invitado** y pulsa el avatar
   superior derecho, con tooltip **Mi perfil**.
3. Abre cada opción y utiliza Volver para regresar a Perfil. En la guía, prueba
   Anterior, Siguiente y deslizar; en el cuarto paso pulsa Finalizar.
4. En Contacto, prueba campos vacíos y luego un motivo y mensaje ficticios.
   En Newsletter, prueba correo inválido, falta de consentimiento y envío válido.
5. Cambia los tres interruptores de Notificaciones, abre el ejemplo, vuelve a
   Perfil y reabre Notificaciones para comprobar sus preferencias temporales.
6. Prueba Cancelar y Simular compartir. Vuelve a Inicio para comprobar que mantiene
   su estado. Los desbordamientos anteriores de Inicio pueden requerir una ventana
   amplia para recorrer cómodamente el flujo completo.

## Texto listo para Pull Request

**Título:** `feat: agregar Perfil y funcionalidades complementarias demostrativas`

**Descripción:**

Agrega el módulo académico de Perfil con registro validado, guía de cuatro pasos,
contacto, newsletter con consentimiento, preferencias de notificaciones y diálogo
para compartir. Todos los envíos, datos, coronas y beneficios son demostrativos;
no se agregan servicios externos, persistencia ni dependencias.

Integra Perfil desde el avatar de Inicio y Registro desde «Regístrate aquí» en
Login mediante rutas que conservan la pantalla anterior. Reutiliza la paleta y
los botones existentes con componentes compartidos para formularios y avisos.
Corrige dos importaciones anteriores de pruebas para permitir un análisis limpio.

**Validación:** `flutter pub get`, `flutter analyze` y `flutter test`; pruebas de
formularios, navegación, preferencias temporales y cuatro tamaños con texto al
150 %. Incluye una prueba de formulario con teclado simulado.

**Limitación conocida:** Inicio conserva los desbordamientos móviles ya presentes
en `main`, verificados mediante comparación diagnóstica. Las seis pantallas nuevas
se verifican por separado sin desbordamientos. Falta la comprobación en dispositivo
físico o emulador.

**Preparación del PR:** revisar y separar primero los cambios locales anteriores;
crear la rama solicitada desde `main` cuando el árbol esté limpio e incluir solo
los archivos del módulo enumerados arriba. No incluir `build/` ni archivos
generados de Windows. Este documento no crea ni publica un PR.
