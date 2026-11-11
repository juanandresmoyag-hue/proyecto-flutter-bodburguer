# Bod Burguer

Aplicación Flutter con una pantalla de inicio de sesión para Burger King Perú.

## Estructura

- `lib/main.dart`: inicia la aplicación.
- `lib/app_theme.dart`: contiene los colores y estilos compartidos.
- `lib/login_screen.dart`: contiene la pantalla y sus interacciones.
- `lib/promotions_screen.dart`: muestra la sección de cupones, recompensas y
  promociones, con filtros, favoritos y canje de demostración.
- `assets/promotions/`: fotografías de muestra de Unsplash para las tarjetas;
  no son imágenes oficiales del restaurante.

## Ejecutar

Instala el [SDK de Flutter para Windows](https://docs.flutter.dev/install) y
agrega la carpeta `flutter\bin` al `PATH` de Windows. Luego cierra y vuelve a
abrir la terminal de VS Code y verifica la instalación:

```shell
flutter --version
flutter doctor
```

Cuando `flutter --version` funcione, ejecuta desde la raíz del proyecto:

```shell
flutter pub get
flutter run
```

La pantalla permite alternar entre ingreso con celular y correo, mostrar u
ocultar la clave, activar el recordatorio del dispositivo y explorar las
opciones de acceso rápido y como invitado. El ingreso es una demostración:
cualquier celular o correo y contraseña no vacíos abren la sección de
promociones; no hay autenticación conectada a un servidor todavía.
Los cupones, las recompensas, el canje y la validación del código
`PERU-BK-7749` son demostrativos y no aplican descuentos reales.
